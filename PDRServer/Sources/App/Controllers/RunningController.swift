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
    
    func create(req: Request) async throws -> [Running] {
        let runnings = try req.content.decode([Running].self)
        for running in runnings {
            try await running.save(on: req.db)
        }
        return runnings
    }
    
    func pdr(req: Request) async throws -> [PDRStep] {
        if let batch: Int = req.query["batch"] {
            
            let runnings = try await Running.query(on: req.db)
                .filter(\.$sampleBatch == batch)
                .sort(\.$timestamp)
                .all()
            // get ground_true
            var groundTruth: [TruePoint] = try await getGroundTruth(by: batch, on: req.db)
            
            let pdrEngine = PDREngine(k: 0.4, m: 0.08, ground_Truth: groundTruth, willTrain: true, dk: 0.01, dm: 0.002, eta: 0.000002, epochs: 200, testRunnings: [runnings])
            // print("batch:\(batch),k:\(pdrEngine.k),m:\(pdrEngine.m)")
            return pdrEngine.predict(from: runnings)
        }else{
            return []
        }
    }
    
    // get ground truth
    private func getGroundTruth(by batch: Int, on database: Database) async throws -> [TruePoint] {
        
        var groundTruth: [TruePoint] = []
        var truthBatch = batch
        if [27, 28, 29, 30, 31, 32].contains(batch) {
            // default ground truth
            truthBatch = 0
        }
        
        groundTruth = try await getGroundTruthHelper(by: truthBatch, on: database)
        if groundTruth.count == 0 {
            groundTruth = try await getGroundTruthHelper(by: 1, on: database)
        }
        
        if groundTruth.count == 0 {
            // default ground truth
            groundTruth = try await getGroundTruthHelper(by: 0, on: database)
        }
        
        return groundTruth
    }
    
    private func getGroundTruthHelper(by batch: Int, on database: Database) async throws -> [TruePoint] {
        let groundTruth = try await TruePoint.query(on: database)
            .filter(\.$batch == batch)
            .sort(\.$step)
            .all()
        return groundTruth
    }
    
}
