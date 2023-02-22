//
//  File.swift
//  
//
//  Created by 蒋艺 on 2023/2/21.
//
import Foundation
import Fluent
import Vapor

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
    
    static func parser(from csvStr: String) throws -> [Position] {
        let strs = csvStr.split(separator: "\n")
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
    
    
    // loas postions database locally, used exclusively for data preparing
    static func load(on database: Database) async throws{
        guard let positionPath = Bundle.module.path(forResource: "position", ofType: "csv") else {
            return
        }
        guard let positionData = FileManager.default.contents(atPath: positionPath) else{
            return
        }
        let positions = try Position.parser(from: String(data: positionData, encoding: .utf8)!)
        for position in positions {
            try await position.save(on: database)
        }
    }
    
    
}
