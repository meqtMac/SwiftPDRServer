import Foundation
import Fluent
import Vapor

struct RunningController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let subroute = routes.grouped("runnings")
        subroute.get(use: index).description("get running dataset with a query of batch")
        subroute.post(use: create).description("not yet verified")
        subroute.get("pdr", use: pdr).description("get pdr results with a query of batch")
        // subroute.get("train", use: train).description("train k and m")
        // todos.group(":todoID") { todo in
        //     todo.delete(use: delete)
        // }
    }

    func index(req: Request) async throws -> [Running] {
        if let batch: Int = req.query["batch"] {
            let runnings = try await Running.query(on: req.db)
                .filter(\.$sampleBatch == batch)
                .sort(\.$timestamp)
                .all()
            return runnings
        }else{
            return []
        }
    }

    func pdr(req: Request) async throws -> [PDRStep] {
        if let batch: Int = req.query["batch"] {
            // print("batch: \(batch), k: \(k), m: \(m)")
            // trained result
            let k = 0.40
            let m = 0.08 
            let dk = 0.01
            let dm = 0.001
            let eta = 0.000002
            let epochs = 200

            let runnings = try await Running.query(on: req.db)
                .filter(\.$sampleBatch == batch)
                .sort(\.$timestamp)
                .all()

            let pdrEngine = PDREngine(k: k, m: m)
            pdrEngine.train(runningSet: [runnings], dk: dk, dm: dm, eta: eta, epochs: epochs)
            print("batch:\(batch),k:\(pdrEngine.k),m:\(pdrEngine.m)")
            return pdrEngine.predict(from: runnings)
        }else{
            return []
        }
    }

    // func train(req: Request) async throws -> PDREngine {
    //     if let k: Double = req.query["k"], let m: Double = req.query["m"], let dk: Double = req.query["dk"], let dm: Double = req.query["dm"], let eta: Double = req.query["eta"], let epochs: Int = req.query["epochs"] {
            
    //         let batchs = [29]
    //         var runningSet = Array<[Running]>()
    //         for batch in batchs {
    //             let runnings = try await Running.query(on: req.db)
    //             .filter(\.$sampleBatch == batch)
    //             .sort(\.$timestamp)
    //             .all()
    //             runningSet.append(runnings)
    //         }

    //         let pdrEngine = PDREngine(k: k, m: m)
    //         pdrEngine.train(runningSet: runningSet, dk: dk, dm: dm, eta: eta, epochs: epochs)
            
    //         return pdrEngine
    //     }else{
    //         return PDREngine(k: 0.2, m: 0.06) // Default Engine
    //     }
    // }

    func create(req: Request) async throws -> [Running] {
        let runnings = try req.content.decode([Running].self)
        for running in runnings {
             try await running.save(on: req.db)
         }
        return runnings 
    }
    
    // func delete(req: Request) async throws -> HTTPStatus {
    //     guard let todo = try await Todo.find(req.parameters.get("todoID"), on: req.db) else {
    //         throw Abort(.notFound)
    //     }
    //     try await todo.delete(on: req.db)
    //     return .noContent
    // }
}
