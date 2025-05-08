//
//  VenueService.swift
//  TEG_Code_Challenge
//
//  Created by Ray on 5/8/25.
//

import Foundation

typealias VenueResponse = Result<[VenueModel], NetworkError>
typealias ScanTicketResponse = Result<ScanTicketModel, NetworkError>

protocol VenueService {
    func fetchVenues(lat:Double, lng:Double) async throws -> VenueResponse
    func scanTicket(code:String, barcode:String) async throws -> ScanTicketResponse
}

final class TEGVenueService: VenueService {
    private let client: APIClient
    
    init(client: APIClient) {
        self.client = client
    }
    
    func scanTicket(code: String, barcode: String) async throws -> ScanTicketResponse {
        do {
            let result = try await client.send(VenueEndpoint.verifyCode(code: code, barcode: barcode), responseModel: ScanTicketModel.self)
            return ScanTicketResponse.success(result)
        } catch let error {
            return ScanTicketResponse.failure(error as! NetworkError)
        }
    }
    
    func fetchVenues(lat: Double, lng: Double) async throws -> VenueResponse {
        do {
            let result = try await client.send(VenueEndpoint.fetchVenues(lat: lat, lon: lng), responseModel: VenueResult.self)
            return VenueResponse.success(result.venues)
        } catch let error {
            return VenueResponse.failure(error as! NetworkError)
        }
    }
}
