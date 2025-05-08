//
//  VenueEndpoint.swift
//  TEG_Code_Challenge
//
//  Created by Ray on 5/8/25.
//

import Foundation

enum VenueEndpoint: Endpoint {
    case fetchVenues(lat:Double, lon:Double)
    case verifyCode(code:String, barcode:String)
    
    var baseURL: URL { URL(string: "https://ignition.qa.ticketek.net")! }
    
    var path: String {
        switch self {
        case .fetchVenues: return "/venues/"
        case .verifyCode(let code, _):
            return "/venues/\(code)/pax/entry/scan"
        }
    }
    
    var queryItems: [URLQueryItem]? {
        switch self {
        case .fetchVenues(lat: let lat, lon: let lon):
            return [
                URLQueryItem(name: "latitude", value: "\(lat)"),
                URLQueryItem(name: "longitude", value: "\(lon)")
            ]
        default:
            return nil
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .fetchVenues: return .get
        case .verifyCode: return .post
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .fetchVenues, .verifyCode:
            return [
                "content-type": "application/json",
                "x-api-key": "TEq5Mddna23xSNsoDeYt8aP02BJHrvoa6X07nEuD",
                "accept-language": "en",
                "authorization": "Basic Yhd9X=38D88!"
            ]
        }
    }
    
    var body: Data? {
        switch self {
        case .verifyCode(_, barcode: let barcode):
            return try? JSONSerialization.data(withJSONObject: ["barcode": barcode], options: [])
        default:
            return nil
        }
    }
}
