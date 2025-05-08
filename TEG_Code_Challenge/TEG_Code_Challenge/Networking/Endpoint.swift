//
//  Endpoint.swift
//  TEG_Code_Challenge
//
//  Created by Ray on 5/8/25.
//

import Foundation

enum HTTPMethod: String {
    case get = "GET", post = "POST"
}

protocol Endpoint {
    var baseURL: URL { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String]? { get }
    var body: Data? { get }
    
    var queryItems: [URLQueryItem]? { get }
    
    var urlRequest: URLRequest { get }
}

extension Endpoint {
    var urlRequest: URLRequest {
        if let queryItems = queryItems {
            var components = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: true)!
            components.queryItems = queryItems
            
            var request = URLRequest(url: components.url!)
            request.allHTTPHeaderFields = headers
            request.httpMethod = method.rawValue
            request.timeoutInterval = 15
            return request
        } else {
            var request = URLRequest(url: baseURL.appendingPathComponent(path))
            request.httpMethod = method.rawValue
            request.allHTTPHeaderFields = headers
            request.httpBody = body
            request.timeoutInterval = 15
            return request
        }
    }
}
