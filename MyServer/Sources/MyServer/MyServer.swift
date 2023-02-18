import Foundation
import Vapor
import Fluent
import FluentMySQLDriver

@main
public struct MyServer {
    public static func main() async throws {
        // initialize the server
        let pdrServer = PDRServer()
        try await pdrServer.bootstrap()
        // initialize the web framework and configure the http routes
        let webapp = Application()
        webapp.get("batchs", use: pdrServer.listBatchs)
        webapp.get("positions", use: pdrServer.listPositions)
        webapp.get("runnings", use: pdrServer.listRunnings)
        webapp.get("pdr", use: pdrServer.listPDRresult )
        webapp.http.server.configuration.hostname = "0.0.0.0"
        webapp.http.server.configuration.port = 8000
        try webapp.run()
    }
}

struct PDRServer{
    private let storage = Storage()
    
    func bootstrap() async throws {
        try await self.storage.load()
    }
    
    // MARK: Server Response
    func listPositions(request: Request) async -> [Model.Position] {
        if let batch: Int = request.query["batch"], await storage.batchs.contains(batch) {
            let positions = await self.storage.listPositions(of: batch)
            return positions
        }else{
//            let positions = await self.storage.listPositions()
            return []
        }
    }
    
    func listRunnings(request: Request) async -> [Model.Running] {
        if let batch: Int = request.query["batch"], await storage.batchs.contains(batch) {
            let runnings = await self.storage.listRunnings(of: batch)
            return runnings
        }else{
//            let runnings = await self.storage.listRunnings()
            return []
        }
    }
    
    func listBatchs(request: Request) async -> [Int] {
        let batchs = await self.storage.listBatchs()
        return Array<Int>(batchs)
    }
    
    func listPDRresult(request: Request) async -> [Model.PDRStep] {
        if let batch: Int = request.query["batch"], await storage.batchs.contains(batch) {
            let runnings = await self.storage.listRunnings(of: batch)
//            print(pdr(from: runnings, with: 0.5))
            return pdr(from: runnings, with: 0.5)
        }else{
            return []
        }
    }
    //MARK: PDR algorithms
    func pdr(from runnings: [Model.Running], with k: Double) -> [Model.PDRStep] {
        if runnings.count == 0 {
            return []
        }
        
        var pdrSteps: [Model.PDRStep] = []
        
        var acczMin = runnings[0].accz
        var acczMax = runnings[0].accz
        var x: Double = -1.0
        var y: Double = 3.4
        var theta: Double = 180.0
        
        pdrSteps.append(Model.PDRStep(running: runnings[0], x: x, y: y, theta: theta))
        
        for index in 1..<runnings.count-1 {
            acczMin = min(runnings[index].accz, acczMin)
            acczMax = max(runnings[index].accz, acczMax)
            theta += runnings[index].gyroscopez * 0.07 * Double(runnings[index].timestamp - runnings[index-1].timestamp) / 1000
            
            if runnings[index].accz > runnings[index-1].accz && runnings[index].accz > runnings[index+1].accz {
                
                let length: Double = 0.3 * pow((acczMax-acczMin)*10.0/16384.0, 0.25)
                y += length * cos(theta * Double.pi/180.0)
                x += length * sin(theta * Double.pi/180.0)
                
               pdrSteps.append(Model.PDRStep(running: runnings[index], x: x, y: y, theta: theta))
                acczMax = runnings[index].accz
                acczMin = runnings[index].accz
            }
        }
        
        return pdrSteps
    }
}

actor Storage{
    let jsonDecoder: JSONDecoder
    var positions = [Model.Position]()
    var runnings = [Model.Running]()
    var batchs: Set<Int> {
        var batchs = Set<Int>()
        for running in runnings {
            if !batchs.contains(running.sampleBatch) {
                batchs.insert(running.sampleBatch)
            }
        }
        return batchs
    }
    
    init() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd,HH:mm:ss"
        jsonDecoder = JSONDecoder()
        jsonDecoder.dateDecodingStrategy = .formatted(dateFormatter)
    }
    
    func load() throws {
        guard let positionPath = Bundle.module.path(forResource: "position", ofType: "csv") else {
            throw Errors.FileNotFound
        }
        guard let positionData = FileManager.default.contents(atPath: positionPath) else {
            throw Errors.failedLoading
        }
        self.positions = try Model.parsePositionCSV(from: String(data: positionData, encoding: .utf8)!)
        
        guard let runningPath = Bundle.module.path(forResource: "running", ofType: "csv") else {
            throw Errors.FileNotFound
        }
        guard let runningData = FileManager.default.contents(atPath: runningPath) else {
            throw Errors.failedLoading
        }
        self.runnings = try Model.parseRunningCSV( from: String(data: runningData, encoding: .utf8)!)
    }
    
    enum Errors: Error {
        case FileNotFound
        case failedLoading
    }
    
    // MARK: response
    func listPositions() -> [Model.Position] {
        return self.positions
    }
    
    func listPositions(of batch: Int) -> [Model.Position] {
        return self.positions.filter({$0.sampleBatch == batch})
    }
    
    func listRunnings() -> [Model.Running] {
        return self.runnings
    }
    
    func listRunnings(of batch: Int) -> [Model.Running] {
        return self.runnings.filter({$0.sampleBatch == batch})
    }
    
    func listBatchs() -> Set<Int> {
        return self.batchs
    }
    
}

// MARK: Model
enum Model{
    
    // Postion Structure
    struct Position: Identifiable, Hashable, Codable, Content {
        var id: UUID
        var x: Double
        var y: Double
        var z: Double
        var stay: Bool
        var timestamp: Int
        var sampleTime: Date
        var sampleBatch: Int
    }
    
    // Running Structure
    struct Running: Identifiable, Hashable, Codable, Content {
        var id: UUID
        var accx: Double
        var accy: Double
        var accz: Double
        var gyroscopex: Double
        var gyroscopey: Double
        var gyroscopez: Double
        var stay: Bool
        var timestamp: Int
        var sampleTime: Date
        var sampleBatch: Int
    }
    
    // PDRStep Structure
    struct PDRStep: Identifiable, Hashable, Codable, Content{
        init(accx: Double, accy: Double, accz: Double,
             gyroscopex: Double, gyroscopey: Double, gyroscopez: Double, timestamp: Int,
             x: Double, y: Double, theta: Double) {
            self.id = UUID()
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
        }
        init(running: Model.Running, x: Double, y: Double, theta: Double) {
            self.id = UUID()
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
        }
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
    }
    
}

extension Model {
    // position parser
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
            let timeStamp = Int(parts[6])
            let sampleTime = dateformer.date(from: String(parts[8]+","+parts[9]) )
            let sampleBatch = Int(parts[10])
            
            let position = Position(id: UUID(), x: x!, y: y!, z: z!, stay: stay, timestamp: timeStamp!, sampleTime: sampleTime!, sampleBatch: sampleBatch!)
            
            positions.append(position)
        }
        return positions
    }
    
    // running parser
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
