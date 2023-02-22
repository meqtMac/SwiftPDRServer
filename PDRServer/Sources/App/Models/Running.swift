import Foundation
import Fluent
import Vapor

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

    static func parser(from str: String) throws -> [Running] {
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
    
    // loas postions database locally, used exclusively for data preparing
    static func load(on database: Database) async throws{
        guard let runningPath = Bundle.module.path(forResource: "running", ofType: "csv") else {
            return
        }
        guard let runningData = FileManager.default.contents(atPath: runningPath) else{
            return
        }
        let runnings = try Running.parser(from: String(data: runningData, encoding: .utf8)!)
        for running in runnings {
            try await running.save(on: database)
        }
    }
    
}

