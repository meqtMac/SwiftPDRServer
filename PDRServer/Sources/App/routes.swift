import Fluent
import Vapor

func routes(_ app: Application) throws {
    
    // register /batchs api
    app.get("batchs") {req async throws -> [Int] in
        let batchs = try await Running.query(on: req.db).all(\.$sampleBatch) 
        return Array<Int>(Set<Int>(batchs)).sorted()
    }.description("get all available batchs")

    // register /runnings api
    try app.register(collection: RunningController())
    
    // register /positions pit
    try app.register(collection: PositionsController())
    
    // register /truePoint apit
    try app.register(collection: TruePointController())
}
