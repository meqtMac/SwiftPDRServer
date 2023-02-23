//
//  Running.swift
//  PDRClient
//
//  Created by 蒋艺 on 2023/2/23.
//

import Foundation

struct Running: Codable, Identifiable{
    var id: UUID?
    var accx: Double
    var accy: Double
    var accz: Double
    var gyroscopex: Double
    var gyroscopey: Double
    var gyroscopez: Double
    var stay: Bool
    var sampleTime: Date
    var sampleBatch: Int
    var timestamp: Int
    
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
    

}
