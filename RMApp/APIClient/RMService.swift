//
//  RMService.swift
//  RMApp
//
//  Created by Albert Garipov on 12.12.2023.
//

import Foundation

/// Primary API service to get Rick and Morty data
final class RMService {
    static let shared = RMService()
    
    private let cacheManger = APICacheManager()
    
    private init() {}
    
    enum RMServiceError: Error {
        case failedToCreateRequest
        case failedToGetData
    }
    
    /// Send Rick and Morty API Calls
    /// - Parameters:
    ///   - request: Request instance
    ///   - type: The type of object we expect to get back
    ///   - completion: Callback with data or error
    public func execute<T: Codable>(
        _ request: RMRequest,
        expecting type: T.Type,
        completion: @escaping(Result<T, Error>) -> Void) {
            if let cachedData = cacheManger.readCache(for: request.endpoint, url: request.url) {
                do {
                    let result = try JSONDecoder().decode(type.self, from: cachedData) // Read from cache
                    completion(.success(result))
                }
                catch {
                    completion(.failure(error))
                }
                return
            }
            
            guard let urlRequest = self.request(from: request) else {
                completion(.failure(RMServiceError.failedToCreateRequest))
                return
            }
            
            let task = URLSession.shared.dataTask(with: urlRequest) { [weak self] data, _, error in
                guard let data = data, error == nil  else {
                    completion(.failure(error ?? RMServiceError.failedToGetData))
                    return
                }
                // Decode response
                do {
                    let result = try JSONDecoder().decode(type.self, from: data)
                    self?.cacheManger.setCache(for: request.endpoint, url: request.url, data: data) // Write into cache
                    completion(.success(result))
                }
                catch {
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    
    private func request( from rmRequest: RMRequest) -> URLRequest? {
        guard let url = rmRequest.url else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = rmRequest.httpMethod
        return request
    }
}
