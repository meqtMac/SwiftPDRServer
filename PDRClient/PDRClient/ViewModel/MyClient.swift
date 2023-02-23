//
//  MyClient.swift
//  PDRClient
//
//  Created by 蒋艺 on 2023/2/23.
//

import Foundation

class MyClient{
    let baseURL = URL(string: "http://120.79.209.43:8080")!
    
    func loadposition(with batch: Int) async throws -> [Position] {
        var url = baseURL.appendingPathComponent("positions")
        url.append(queryItems: [URLQueryItem(name: "batch", value: "\(batch)")])
        let (data, _) = try await URLSession.shared.data(for: URLRequest(url: url))
        guard String(data: data, encoding: .utf8) != nil else {
            throw Errors.invalidResponseEncoding
        }
        let positions = try JSONDecoder().decode([Position].self, from: data)
        return positions
    }
    
    func loadRunnings(with batch: Int) async throws -> [Running] {
        var url = baseURL.appendingPathComponent("runnings")
        url.append(queryItems: [URLQueryItem(name: "batch", value: "\(batch)")])
        let (data, _) = try await URLSession.shared.data(for: URLRequest(url: url))
        guard String(data: data, encoding: .utf8) != nil else {
            throw Errors.invalidResponseEncoding
        }
        let runnings = try JSONDecoder().decode([Running].self, from: data)
        return runnings
    }
    
    func loadPDR(with batch: Int) async throws -> [PDRStep] {
        var url = baseURL.appendingPathComponent("runnings/pdr")
        url.append(queryItems: [URLQueryItem(name: "batch", value: "\(batch)")])
        let (data, _) = try await URLSession.shared.data(for: URLRequest(url: url))
        guard String(data: data, encoding: .utf8) != nil else {
            throw Errors.invalidResponseEncoding
        }
        let pdrSteps = try JSONDecoder().decode([PDRStep].self, from: data)
        return pdrSteps
        
    }
    
    func loadbatchs() async throws -> [Int] {
        let url = baseURL.appendingPathComponent("batchs")
        let (data, _) = try await URLSession.shared.data(for: URLRequest(url: url))
        guard String(data: data, encoding: .utf8) != nil else {
            throw Errors.invalidResponseEncoding
        }
        let batchs = try JSONDecoder().decode([Int].self, from: data)
        return batchs
        
    }
    
    
    enum Errors: Error {
        case invalidResponseEncoding
    }
}
