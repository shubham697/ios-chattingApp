import UIKit

class ObjectUser: FireStorageCodable {
  
    var id = UUID().uuidString
    var name: String?
    var email: String?
    var phone : String?
    var phone_email : String?
    var profilePicLink: String?
    var profilePic: UIImage?
    var password: String?
    var role : String?
    var company_name : String?
    var street_address : String?
    var state : String?
    var city : String?
    var zipcode : String?
    var account_status : String?
    var shared_catalog : Bool?

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encodeIfPresent(email, forKey: .email)
        try container.encodeIfPresent(phone, forKey: .phone)
        try container.encodeIfPresent(role, forKey: .role)
        try container.encodeIfPresent(phone_email, forKey: .phone_email)
        try container.encodeIfPresent(profilePicLink, forKey: .profilePicLink)
        
        try container.encodeIfPresent(company_name, forKey: .company_name)
        try container.encodeIfPresent(street_address, forKey: .street_address)
        try container.encodeIfPresent(state, forKey: .state)
        try container.encodeIfPresent(city, forKey: .city)
        try container.encodeIfPresent(zipcode, forKey: .zipcode)
        
        try container.encodeIfPresent(account_status, forKey: .account_status)
        
        try container.encodeIfPresent(shared_catalog, forKey: .shared_catalog)
    }

    init() {}

    public required convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        email = try container.decodeIfPresent(String.self, forKey: .email)
        phone = try container.decodeIfPresent(String.self, forKey: .phone)
        role = try container.decodeIfPresent(String.self, forKey: .role)
        phone_email = try container.decodeIfPresent(String.self, forKey: .phone_email)
        profilePicLink = try container.decodeIfPresent(String.self, forKey: .profilePicLink)
        
        company_name = try container.decodeIfPresent(String.self, forKey: .company_name)
        street_address = try container.decodeIfPresent(String.self, forKey: .street_address)
        state = try container.decodeIfPresent(String.self, forKey: .state)
        city = try container.decodeIfPresent(String.self, forKey: .city)
        zipcode = try container.decodeIfPresent(String.self, forKey: .zipcode)
        
        account_status = try container.decodeIfPresent(String.self, forKey: .account_status)
        
        shared_catalog = try container.decodeIfPresent(Bool.self, forKey: .shared_catalog)
    }
}

extension ObjectUser {
  private enum CodingKeys: String, CodingKey {
    case id
    case email
    case name
    case phone
    case phone_email
    case profilePicLink
    case role
    case company_name
    case street_address
    case state
    case city
    case zipcode
    case account_status
    case shared_catalog
  }
}
