//
//  File.swift
//  
//
//  Created by 蒋艺 on 2023/2/22.
//
import Fluent
import FluentMySQLDriver
import Vapor

final class PDREngine: Content{
    var k: Double
    var m: Double
    
    init(k: Double, m: Double) {
        self.k = k
        self.m = m
    }
    
    // error of pdr point
    func calerror(x: Double, y: Double, percent: Double) -> Double {
        var realx = 0.0;
        var realy = 0.0;
        if percent < (6.6/15.7) {
            realx = -1.0
            realy = 3.4 - percent * 15.7
        }else if percent < (9.1/15.7) {
            realx = -1.0 + percent * 15.7 - 6.6
            realy = -3.2
        }else{
            realx = 1.5
            realy = -3.2 + percent * 15.7 - 9.1
        }
        return sqrt( (x-realx) * (x-realx) + (y-realy) * (y-realy))
    }
    
    // total error of a sequence of pdr steps
    func calerror(of pdrSteps: [PDRStep]) -> Double {
        var error = 0.0
        for step in pdrSteps {
            error += step.error
        }
        return error
    }
    
    // total error of a set of runnings's prediction
    func calerror(of runningSet: Array<[Running]>) -> Double {
        var error = 0.0
        for runnings in runningSet {
            error += calerror(of: predict(from: runnings))
        }
        return error
    }
    
    //MARK: PDR algorithms
    func predict(from runnings: [Running]) -> [PDRStep] {
        if runnings.count == 0 {
            return []
        }
        
        var pdrSteps: [PDRStep] = []
        
        var acczMin = runnings[0].accz
        var acczMax = runnings[0].accz
        var x: Double = -1.0
        var y: Double = 3.4
        var theta: Double = 180.0
        var error: Double = 0
        
        pdrSteps.append(PDRStep(running: runnings[0], x: x, y: y, theta: theta, error: error))
        
        for index in 1..<runnings.count-2 {
            acczMin = min(runnings[index].accz, acczMin)
            acczMax = max(runnings[index].accz, acczMax)
            
            let ax = runnings[index].accx
            let ay = runnings[index].accy
            let az = runnings[index].accz
            let a = sqrt(ax*ax+ay*ay+az*az)
            let gx = runnings[index].gyroscopex
            let gy = runnings[index].gyroscopey
            let gz = runnings[index].gyroscopez

            theta -=  m * (ax*gx+ay*gy+az*gz)/a * Double(runnings[index].timestamp - runnings[index-1].timestamp) / 1000
            
            if  index > 1 && runnings[index].accz > runnings[index-1].accz && runnings[index].accz > runnings[index-2].accz && runnings[index].accz > runnings[index+1].accz && runnings[index].accz > runnings[index+2].accz {
                
                let length: Double = k * pow((acczMax-acczMin)*10.0/16384.0, 0.25)
                y += length * cos(theta * Double.pi/180.0)
                x += length * sin(theta * Double.pi/180.0)
                // calculate error
                error = calerror(x: x, y: y, percent: Double(index)/Double(runnings.count-1))
                
                pdrSteps.append(PDRStep(running: runnings[index], x: x, y: y, theta: theta, error: error))
                acczMax = runnings[index].accz
                acczMin = runnings[index].accz
            }
        }
        return pdrSteps
    }
    
    func train(runningSet: Array<[Running]>, dk: Double, dm: Double, eta: Double, epochs: Int) {
        var error: Double = calerror(of: runningSet)
        
        for _ in 0..<epochs {
            error = self.calerror(of: runningSet)
            // print("Epoch: \(epoch), E: \(error), k: \(k), m: \(m)")
            // error with k+dk, m
            let ek = PDREngine(k: k+dk, m: m).calerror(of: runningSet)
            // error with k, m+dm
            let em = PDREngine(k: k, m: m+dm).calerror(of: runningSet)
            // partial e over partial k & m
            let epk = (ek-error) / dk
            let epm = (em-error) / dm
            
            k += -eta * epk
            m += -eta * epm
        }
    }
    
}

final class PDRStep: Content{
    var id: UUID?
    var accx: Double
    var accy: Double
    var accz: Double
    var gyroscopex: Double
    var gyroscopey: Double
    var gyroscopez: Double
    var timestamp: Int
    var x: Double
    var y: Double
    var theta: Double
    var error: Double
    
    init(id: UUID? = nil, accx: Double, accy: Double, accz: Double,
         gyroscopex: Double, gyroscopey: Double, gyroscopez: Double, timestamp: Int,
         x: Double, y: Double, theta: Double, error: Double) {
        self.id = id
        self.accx = accx
        self.accy = accy
        self.accz = accz
        self.gyroscopex = gyroscopex
        self.gyroscopey = gyroscopey
        self.gyroscopez = gyroscopez
        
        self.timestamp = timestamp
        self.x = x
        self.y = y
        self.theta = theta
        self.error = error
    }
    
    // initialize while copying running's data
    init(running: Running, x: Double, y: Double, theta: Double, error: Double) {
        self.id = running.id
        self.accx = running.accx
        self.accy = running.accy
        self.accz = running.accz
        self.gyroscopex = running.gyroscopex
        self.gyroscopey = running.gyroscopey
        self.gyroscopez = running.gyroscopez
        self.timestamp = running.timestamp
        
        self.x = x
        self.y = y
        self.theta = theta
        self.error = error
    }
    
}
