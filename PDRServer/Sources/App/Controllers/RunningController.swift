import Foundation
import Fluent
import Vapor

struct RunningController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let subroute = routes.grouped("runnings")
        subroute.get(use: index).description("get running dataset with a query of batch")
        subroute.post(use: create).description("upload runnings dataset")
        subroute.get("pdr", use: pdr).description("get pdr results with a query of batch")
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

            let k = 0.40
            let m = 0.08
            let dk = 0.01
            let dm = 0.002
            let eta = 0.000002
            let epochs = 200
            
            let runnings = try await Running.query(on: req.db)
                .filter(\.$sampleBatch == batch)
                .sort(\.$timestamp)
                .all()
            
            var ground_true: [TruePoint] = []
            if [27, 28, 29, 30, 31, 32].contains(batch) {
                ground_true = try await TruePoint.query(on: req.db)
                    .filter(\.$magic == 0)
                    .sort(\.$step)
                    .all()
            }else{
                 ground_true = try await TruePoint.query(on: req.db)
                    .filter(\.$magic == batch)
                    .sort(\.$step)
                    .all()
                if ground_true.count == 0 {
	                ground_true = try await TruePoint.query(on: req.db)
                    	.filter(\.$magic == 1)
                    	.sort(\.$step)
                    	.all()
                }
				if ground_true.count == 0 {
	                ground_true = try await TruePoint.query(on: req.db)
                    	.filter(\.$magic == 0)
                    	.sort(\.$step)
                    	.all()
				}
            }
            
            let pdrEngine = PDREngine(k: k, m: m, ground_Truth: ground_true)
            pdrEngine.train(runningSet: [runnings], dk: dk, dm: dm, eta: eta, epochs: epochs)
            print("batch:\(batch),k:\(pdrEngine.k),m:\(pdrEngine.m)")
            return pdrEngine.predict(from: runnings)
        }else{
            return []
        }
    }
    
    func create(req: Request) async throws -> [Running] {
        let runnings = try req.content.decode([Running].self)
        for running in runnings {
            try await running.save(on: req.db)
        }
        return runnings
    }
    
}
