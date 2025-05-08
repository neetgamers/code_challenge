//
//  NetworkError.swift
//  TEG_Code_Challenge
//
//  Created by Ray on 5/8/25.
//

import Foundation
import UIKit

enum NetworkError: Error {
    case noInternet
    case timeout
    case serverError(statusCode: Int)
    case decodingError
    case invalidRequest
    case custom(message:String)
    case unknown
    
    var errorDescription: String {
        switch self {
        case .noInternet:
            return "No internet connection"
        case .timeout:
            return "Request timed out"
        case .serverError(statusCode: let code):
            return "Server error (\(code))"
        case .decodingError:
            return "Error decoding data"
        case .invalidRequest:
            return "Invalid request"
        case .custom(let message):
            return message
        case .unknown:
            return "Error unknown"
        }
    }
}
