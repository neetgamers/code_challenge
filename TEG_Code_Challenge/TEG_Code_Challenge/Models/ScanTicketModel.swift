//
//  ScanTicketModel.swift
//  TEG_Code_Challenge
//
//  Created by Ray on 5/8/25.
//

import Foundation

class ScanTicketModel:Codable {
    
    var status:String = ""
    var action:String = ""
    var result:String = ""
    var concession:Int = 0
    
    enum CodingKeys:String, CodingKey {
        case status
        case action
        case result
        case concession
    }
    
    init() {}
    
    init(realm: AnyClass) {}
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        status = try values.decodeIfPresent(String.self, forKey: .status) ?? ""
        action = try values.decodeIfPresent(String.self, forKey: .action) ?? ""
        result = try values.decodeIfPresent(String.self, forKey: .result) ?? ""
        
        do {
            let consStr = try values.decodeIfPresent(String.self, forKey: .concession) ?? "0"
            let val = Int(consStr)
            concession = val ?? 0
        } catch {
            concession = try values.decodeIfPresent(Int.self, forKey: .concession) ?? 0
        }
    }
}
