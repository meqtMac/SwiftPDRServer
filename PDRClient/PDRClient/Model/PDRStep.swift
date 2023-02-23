//
//  PDRStep.swift
//  PDRClient
//
//  Created by 蒋艺 on 2023/2/23.
//

import Foundation

struct PDRStep: Codable, Identifiable {
    var id: UUID
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
    
    init(id: UUID, accx: Double, accy: Double, accz: Double,
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
    
}
