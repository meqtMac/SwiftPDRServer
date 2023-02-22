import Fluent
import Vapor

func routes(_ app: Application) throws {
    
    app.get("batchs") {req async throws -> [Int] in
        let batchs = try await Running.query(on: req.db).all(\.$sampleBatch) 
        return Array<Int>(Set<Int>(batchs)).sorted()
    }.description("get all available batchs")

    try app.register(collection: RunningController())
    try app.register(collection: PositionsController())
}
