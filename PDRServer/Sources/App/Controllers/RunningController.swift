import Foundation
import Fluent
import Vapor

struct RunningController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let subroute = routes.grouped("runnings")
        subroute.get(use: index).description("get running dataset with a query of batch")
        subroute.post(use: create).description("not yet verified")
        subroute.get("pdr", use: pdr).description("get pdr results with a query of batch")
        subroute.get("train", use: train).description("train k and m")
        // subroute.get("load", use: load)
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
            let k = 0.2
            let m = 0.05
            let runnings = try await Running.query(on: req.db)
                .filter(\.$sampleBatch == batch)
                .sort(\.$timestamp)
                .all()
            return PDRStep.pdr(from: runnings, k: k, m: m)
        }else{
            return []
        }
    }

    // a help function to calculate error of a set with k and m
    private func calerror(of runningSet: Array<[Running]>, k: Double, m: Double) -> Double {
        var error = 0.0
        for runnings in runningSet {
            error += PDRStep.pdrError(from: runnings, k: k, m: m) 
        }
        return error
    }

    func train(req: Request) async throws -> String {
        var result = ""
        if var k: Double = req.query["k"], var m: Double = req.query["m"], let dk: Double = req.query["dk"], let dm: Double = req.query["dm"], let eta: Double = req.query["eta"], let epochs: Int = req.query["epochs"] {
            result += "k: \(k), m: \(m), dk: \(dk), dm: \(dm), eta: \(eta), epoch: \(epochs), batch: \(27)\n"
            let batchs = [27]
            var runningSet = Array<[Running]>()
            for batch in batchs {
                let runnings = try await Running.query(on: req.db)
                .filter(\.$sampleBatch == batch)
                .sort(\.$timestamp)
                .all()
                runningSet.append(runnings)
            }

            var error: Double = calerror(of: runningSet, k: k, m: m)
            for epoch in 0..<epochs {
                result += "Epoch: \(epoch), E: \(error), k: \(k), m: \(m)\n"
                // error with k+dk, m
                let ek = calerror(of: runningSet, k: k+dk, m: m)
                // error with k, m+dm
                let em = calerror(of: runningSet, k: k, m: m+dm)

                // partial e over partial k & m
                let epk = (ek-error) / dk
                let epm = (em-error) / dm

                k += -eta * epk
                m += -eta * epm
                error = calerror(of: runningSet, k: k, m: m)
            }
            return result
        }else{
            return "fail"
        }
    }

    func create(req: Request) async throws -> [Running] {
        let runnings = try req.content.decode([Running].self)
        for running in runnings {
            try await running.save(on: req.db)
        }
        return runnings 
    }

    // func load(req: Request) async throws -> [Running] {
    //     guard let runningPath = Bundle.module.path(forResource: "running", ofType: "csv") else {
    //         return []
    //     }
    //     guard let runningData = FileManager.default.contents(atPath: runningPath) else{
    //         return []
    //     }
    //     let runnings = try Running.parseRunningCSV(from: String(data: runningData, encoding: .utf8)!)
    //     for running in runnings {
    //         try await running.save(on: req.db)
    //     }
    //     return runnings
    // }

    // func delete(req: Request) async throws -> HTTPStatus {
    //     guard let todo = try await Todo.find(req.parameters.get("todoID"), on: req.db) else {
    //         throw Abort(.notFound)
    //     }
    //     try await todo.delete(on: req.db)
    //     return .noContent
    // }
}