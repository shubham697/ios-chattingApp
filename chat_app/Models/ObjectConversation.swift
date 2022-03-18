import Foundation

class ObjectConversation: FireCodable {
  
  var id = UUID().uuidString
  var userIDs = [String]()
  var timestamp = Int(Date().timeIntervalSince1970)
  var lastMessage: String?
  var isRead = [String: Bool]()
  var total_msg_count : Int?
  var contact_name : String?
  var company_name : String?
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(id, forKey: .id)
    try container.encode(userIDs, forKey: .userIDs)
    try container.encode(timestamp, forKey: .timestamp)
    try container.encodeIfPresent(lastMessage, forKey: .lastMessage)
    try container.encode(isRead, forKey: .isRead)
    try container.encode(total_msg_count, forKey: .total_msg_count)
    try container.encodeIfPresent(contact_name, forKey: .contact_name)
    try container.encodeIfPresent(company_name, forKey: .company_name)
  }
  
  init() {}
  
  public required convenience init(from decoder: Decoder) throws {
    self.init()
    let container = try decoder.container(keyedBy: CodingKeys.self)
    id = try container.decode(String.self, forKey: .id)
    userIDs = try container.decode([String].self, forKey: .userIDs)
    timestamp = try container.decode(Int.self, forKey: .timestamp)
    lastMessage = try container.decodeIfPresent(String.self, forKey: .lastMessage)
    isRead = try container.decode([String: Bool].self, forKey: .isRead)
    total_msg_count = try container.decode(Int.self, forKey: .total_msg_count)
    contact_name = try container.decodeIfPresent(String.self, forKey: .contact_name)
    company_name = try container.decodeIfPresent(String.self, forKey: .company_name)
  }
}

extension ObjectConversation {
  private enum CodingKeys: String, CodingKey {
    case id
    case userIDs
    case timestamp
    case lastMessage
    case isRead
    case total_msg_count
    case contact_name
    case company_name
  }
}
