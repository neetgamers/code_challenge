//
//  VenueModel.swift
//  TEG_Code_Challenge
//
//  Created by Ray on 5/8/25.
//

import Foundation

class VenueResult:Codable {
    var venues:[VenueModel] = []
    
    enum CodingKeys:String, CodingKey {
        case venues
    }
    
    init() {}
    
    init(realm: AnyClass) {}
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        venues = try values.decode([VenueModel].self, forKey: .venues)
    }
}

class VenueModel:Codable {
    
    var code:String = ""
    var name:String = ""
    var address:String = ""
    var city:String = ""
    var state:String = ""
    var postcode:String = ""
    var latitude:Double = 0
    var longitude:Double = 0
    var timezone:String = ""
    var pax_locations:[VenuePaxLocation] = []
    
    enum CodingKeys:String, CodingKey {
        case code
        case name
        case address
        case city
        case state
        case postcode
        case latitude
        case longitude
        case timezone
        case pax_locations
    }
    
    init() {}
    
    init(realm: AnyClass) {}
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        code = try values.decodeIfPresent(String.self, forKey: .code) ?? ""
        name = try values.decodeIfPresent(String.self, forKey: .name) ?? ""
        address = try values.decodeIfPresent(String.self, forKey: .address) ?? ""
        city = try values.decodeIfPresent(String.self, forKey: .city) ?? ""
        state = try values.decodeIfPresent(String.self, forKey: .state) ?? ""
        postcode = try values.decodeIfPresent(String.self, forKey: .postcode) ?? ""
        latitude = try values.decodeIfPresent(Double.self, forKey: .latitude) ?? 0
        longitude = try values.decodeIfPresent(Double.self, forKey: .longitude) ?? 0
        timezone = try values.decodeIfPresent(String.self, forKey: .timezone) ?? ""
        pax_locations = try values.decodeIfPresent([VenuePaxLocation].self, forKey: .pax_locations) ?? []
    }
}

class VenuePaxLocation:Codable {
    var name:String = ""
    var gates: [VenuePaxLocationGate] = []
    
    enum CodingKeys:String, CodingKey {
        case name
        case gates
    }
    
    init() {}
    
    init(realm: AnyClass) {}
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        name = try values.decodeIfPresent(String.self, forKey: .name) ?? ""
        gates = try values.decodeIfPresent([VenuePaxLocationGate].self, forKey: .gates) ?? []
    }
}

class VenuePaxLocationGate:Codable {
    var name:String = ""
    
    enum CodingKeys:String, CodingKey {
        case name
    }
    
    init() {}
    
    init(realm: AnyClass) {}
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        name = try values.decodeIfPresent(String.self, forKey: .name) ?? ""
    }
}
