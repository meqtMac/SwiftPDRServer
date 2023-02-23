import Fluent
import Vapor

struct PositionsController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let subroute = routes.grouped("positions")
        subroute.get(use: index).description("get position dataset with a query of batch")
        subroute.post(use: create).description("upload postions dataset")
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
        for position in positions{
             try await position.save(on: req.db)
        }
        return positions
    }

}

