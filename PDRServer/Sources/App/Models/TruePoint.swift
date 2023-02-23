//
//  File.swift
//  
//
//  Created by 蒋艺 on 2023/2/23.
//

import Foundation
import Fluent
import Vapor

final class TruePoint: Model, Content {
    
    static let schema = "truepoints"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "x")
    var x: Double
    
    @Field(key: "y")
    var y: Double
    
    @Field(key: "step")
    var step: Int
    
    @Field(key: "batch")
    var batch: Int
    
    init() { }
    
    init(id: UUID? = nil, x: Double, y: Double, step: Int, batch: Int) {
        self.id = id
        self.x = x
        self.y = y
        self.step = step
        self.batch = batch
    }
    
    static func load(on database: Database) async throws{
        
        let truepoints = [
            TruePoint(id: UUID(), x: -1, y: 3.4, step: 0, batch: 0),
            TruePoint(id: UUID(), x: -1, y: 2.2, step: 1, batch: 0),
            TruePoint(id: UUID(), x: -1, y: 1, step: 2, batch: 0),
            TruePoint(id: UUID(), x: -1, y: -0.2, step: 3, batch: 0),
            TruePoint(id: UUID(), x: -1, y: -1.4, step: 4, batch: 0),
            TruePoint(id: UUID(), x: -1, y: -2.6, step: 5, batch: 0),
            TruePoint(id: UUID(), x: -0.6, y: -3.2, step: 6, batch: 0),
            TruePoint(id: UUID(), x: 0.2, y: -3.2, step: 7, batch: 0),
            TruePoint(id: UUID(), x: 1.2, y: -3.2, step: 8, batch: 0),
            TruePoint(id: UUID(), x: 1.5, y: -2.6, step: 9, batch: 0),
            TruePoint(id: UUID(), x: 1.5, y: -1.4, step: 10, batch: 0),
            TruePoint(id: UUID(), x: 1.5, y: -0.2, step: 11, batch: 0),
            TruePoint(id: UUID(), x: 1.5, y: 1.0, step: 12, batch: 0),
            TruePoint(id: UUID(), x: 1.5, y: 2.2, step: 13, batch: 0),
            TruePoint(id: UUID(), x: 1.5, y: 3.4, step: 14, batch: 0),
        ]
        
        for truepoint in truepoints {
            try await truepoint.save(on: database)
        }
    }
}


