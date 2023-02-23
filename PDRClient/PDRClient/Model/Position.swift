//
//  Positions.swift
//  PDRClient
//
//  Created by 蒋艺 on 2023/2/23.
//

import Foundation

struct Position: Codable, Identifiable {
    var id: UUID
    var x: Double
    var y: Double
    var z: Double
    var stay: Bool
    var timestamp: Int
    var sampleTime: Date
    var sampleBatch: Int
    
    init(id: UUID, x: Double, y: Double, z: Double, stay: Bool, timestamp: Int, sampleTime: Date, sampleBatch: Int) {
        self.id = id
        self.x = x
        self.y = y
        self.z = z
        self.stay = stay
        self.timestamp = timestamp
        self.sampleTime = sampleTime
        self.sampleBatch = sampleBatch
    }
    
}
