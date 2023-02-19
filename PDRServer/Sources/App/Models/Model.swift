import Foundation
import Fluent
import Vapor

// final class Todo: Model, Content {
//     static let schema = "todos"
    
//     @ID(key: .id)
//     var id: UUID?

//     @Field(key: "title")
//     var title: String

//     init() { }

//     init(id: UUID? = nil, title: String) {
//         self.id = id
//         self.title = title
//     }
// }

final class Position: Model, Content {
    static let schema = "positions"
    @ID(key: .id)
    var id: UUID?

    @Field(key: "x")
    var x: Double

    @Field(key: "y")
    var y: Double

    @Field(key: "z")
    var z: Double
    
    @Field(key: "stay")
    var stay: Bool

    @Field(key: "timestamp")
    var timestamp: Int

    @Field(key: "sampleTime")
    var sampleTime: Date

    @Field(key: "sampleBatch")
    var sampleBatch: Int
    
    init() { }

    init(id: UUID? = nil, x: Double, y: Double, z: Double, stay: Bool, timestamp: Int, sampleTime: Date, sampleBatch: Int) {
        self.id = id
        self.x = x
        self.y = y
        self.z = z
        self.stay = stay
        self.timestamp = timestamp
        self.sampleTime = sampleTime
        self.sampleBatch = sampleBatch
    }
    static func parsePositionCSV(from str: String) throws -> [Position] {
        let strs = str.split(separator: "\n")
        var positions: [Position] = []
        let dateformer = DateFormatter()
        dateformer.dateFormat = "\"yyyy-MM-dd,HH:mm:ss\""
        
        for line in strs[1..<strs.count] {
            let parts = line.split(separator: ",")
            // let id = Int(parts[0])
            let x = Double(parts[2])
            let y = Double(parts[3])
            let z = Double(parts[4])
            let stay:Bool = (Int(parts[5]) == 1) ? true : false
            let timestamp = Int(parts[6])
            let sampleTime = dateformer.date(from: String(parts[8]+","+parts[9]) )
            let sampleBatch = Int(parts[10])
            
            let position = Position(id: UUID(), x: x!, y: y!, z: z!, stay: stay, timestamp: timestamp!, sampleTime: sampleTime!, sampleBatch: sampleBatch!)
            
            positions.append(position)
        }
        return positions
    }
}

final class Running: Model, Content{
    static let schema = "runnings"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "accx")
    var accx: Double

    @Field(key: "accy")
    var accy: Double

    @Field(key: "accz")
    var accz: Double

    @Field(key: "gyroscopex")
    var gyroscopex: Double

    @Field(key: "gyroscopey")
    var gyroscopey: Double

    @Field(key: "gyroscopez")
    var gyroscopez: Double

    @Field(key: "stay")
    var stay: Bool

    @Field(key: "timestamp")
    var timestamp: Int

    @Field(key: "sampleTime")
    var sampleTime: Date

    @Field(key: "sampleBatch")
    var sampleBatch: Int

    init() { }

    init(id: UUID? = nil, accx: Double, accy: Double, accz: Double, gyroscopex: Double, gyroscopey: Double
    , gyroscopez: Double, stay: Bool, timestamp: Int, sampleTime: Date, sampleBatch: Int) {
        self.id = id
        self.accx = accx
        self.accy = accy
        self.accz = accz
        self.gyroscopex = gyroscopex
        self.gyroscopey = gyroscopey
        self.gyroscopez = gyroscopez
        self.stay = stay
        self.timestamp = timestamp
        self.sampleTime = sampleTime
        self.sampleBatch = sampleBatch
    }

    static func parseRunningCSV(from str: String) throws -> [Running] {
        let strs = str.split(separator: "\n")
        var runnings: [Running] = []
        let dateformer = DateFormatter()
        dateformer.dateFormat = "\"yyyy-MM-dd,HH:mm:ss\""
        
        for line in strs[1..<strs.count] {
            let parts = line.split(separator: ",")
            // let id = Int(parts[0])
            let accx = Double(parts[8])
            let accy = Double(parts[9])
            let accz = Double(parts[10])
            let gyroscopex = Double(parts[11])
            let gyroscopey = Double(parts[12])
            let gyroscopez = Double(parts[13])
            
            let stay:Bool = (Int(parts[14]) == 1) ? true : false
            let timeStamp = Int(parts[17])
            let sampleTime = dateformer.date(from: String(parts[19]+","+parts[20]) )
            let sampleBatch = Int(parts[21])
            let running = Running(id: UUID(), accx: accx!, accy: accy!, accz: accz!, gyroscopex: gyroscopex!, gyroscopey: gyroscopey!, gyroscopez: gyroscopez!, stay: stay, timestamp: timeStamp!, sampleTime: sampleTime!, sampleBatch: sampleBatch!)
            
            runnings.append(running)
        }
        return runnings
    }
}

final class PDRStep: Content{
    // static let schema = "pdrsteps"

    // @ID(key: .id)
    var id: UUID?

    // @Field(key: "accx")
    var accx: Double

    // @Field(key: "accy")
    var accy: Double

    // @Field(key: "accz")
    var accz: Double

    // @Field(key: "gyroscopex")
    var gyroscopex: Double

    // @Field(key: "gyroscopey")
    var gyroscopey: Double

    // @Field(key: "gyrosocpez")
    var gyroscopez: Double

    // @Field(key: "timestamp")
    var timestamp: Int

    // @Field(key: "x")
    var x: Double

    // @Field(key: "y")
    var y: Double

    // @Field(key: "theta")
    var theta: Double

    // @Field(key: "error")
    var error: Double

    // init() { }
    // initialize from scratch
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

    //
    static func calError(x: Double, y: Double, percent: Double) -> Double {
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

    //MARK: PDR algorithms
    static func pdr(from runnings: [Running], k: Double, m: Double) -> [PDRStep] {
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
        
        for index in 1..<runnings.count-1 {
            acczMin = min(runnings[index].accz, acczMin)
            acczMax = max(runnings[index].accz, acczMax)
            theta += runnings[index].gyroscopez * m * Double(runnings[index].timestamp - runnings[index-1].timestamp) / 1000
            
            if runnings[index].accz > runnings[index-1].accz && runnings[index].accz > runnings[index+1].accz {
                
                let length: Double = k * pow((acczMax-acczMin)*10.0/16384.0, 0.25)
                y += length * cos(theta * Double.pi/180.0)
                x += length * sin(theta * Double.pi/180.0)
                // calculate error
                error = calError(x: x, y: y, percent: Double(index)/Double(runnings.count-1))
                
               pdrSteps.append(PDRStep(running: runnings[index], x: x, y: y, theta: theta, error: error))
                acczMax = runnings[index].accz
                acczMin = runnings[index].accz
            }
        }
        
        return pdrSteps
    }

    /// calculating sum of error in one samplebatch with k and m specified, which is a simplied version of pdf to reduce pdr storage overhead
    static func pdrError(from runnings: [Running], k: Double, m: Double) -> Double {
        var acczMin = runnings[0].accz
        var acczMax = runnings[0].accz
        var x: Double = -1.0
        var y: Double = 3.4
        var theta: Double = 180.0
        var error: Double = 0
        var count: Double = 1

        for index in 1..<runnings.count-1 {
            acczMin = min(runnings[index].accz, acczMin)
            acczMax = max(runnings[index].accz, acczMax)
            theta += runnings[index].gyroscopez * m * Double(runnings[index].timestamp - runnings[index-1].timestamp) / 1000
            
            if runnings[index].accz > runnings[index-1].accz && runnings[index].accz > runnings[index+1].accz {
                count += 1
                let length: Double = k * pow((acczMax-acczMin)*10.0/16384.0, 0.25)
                y += length * cos(theta * Double.pi/180.0)
                x += length * sin(theta * Double.pi/180.0)
                // calculate error
                error += pow( calError(x: x, y: y, percent: Double(index)/Double(runnings.count-1)), 1)
 
            //    pdrSteps.append(PDRStep(running: runnings[index], x: x, y: y, theta: theta, error: error))
                acczMax = runnings[index].accz
                acczMin = runnings[index].accz
            }
        }

        return error / count
    }
}