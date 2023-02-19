import Fluent
import Vapor

struct PositionsController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let subroute = routes.grouped("positions")
        subroute.get(use: index).description("get position dataset with a query of batch")
        subroute.post(use: create).description("not yet verified")
        // subroute.get("load", use: load)
        // todos.group(":todoID") { todo in
        //     todo.delete(use: delete)
        // }
    }

    func index(req: Request) async throws -> [Position] {
        if let batch: Int = req.query["batch"] {
            let positions = try await Position.query(on: req.db)
                .filter(\.$sampleBatch == batch)
                .sort(\.$timestamp)
                .all()
            return positions
        }else{
            return []
        }
    }

    func create(req: Request) async throws -> [Position] {
        let positions = try req.content.decode([Position].self)
        // for position in positions{
        //     try await position.save(on: req.db)
        // }
        return positions
    }

    // func load(req: Request) async throws -> [Position] {
    //     guard let positionPath = Bundle.module.path(forResource: "position", ofType: "csv") else {
    //         return []
    //     }
    //     guard let positionData = FileManager.default.contents(atPath: positionPath) else{
    //         return []
    //     }
    //     let positions = try Position.parsePositionCSV(from: String(data: positionData, encoding: .utf8)!)
    //     for position in positions {
    //         try await position.save(on: req.db)
    //     }
    //     return positions
    // }

    // func delete(req: Request) async throws -> HTTPStatus {
    //     guard let todo = try await Todo.find(req.parameters.get("todoID"), on: req.db) else {
    //         throw Abort(.notFound)
    //     }
    //     try await todo.delete(on: req.db)
    //     return .noContent
    // }
}

