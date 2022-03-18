import UIKit

class ObjectMessage: FireStorageCodable {
  
  var id = UUID().uuidString
  var message: String?
  var content: String?
  var contentType = ContentType.none
  var timestamp = Int(Date().timeIntervalSince1970)
  var ownerID: String?
  var profilePicLink: String?
  var profilePic: UIImage?
  var uniqueCount = Int(0)
    
/// order message
  var orderRefString : String?
  var orderTitle : String?
  var orderdate : String?
  var orderProductCount = Int(0)
  var orderComment : String?
  var orderStatus = "Active"

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(id, forKey: .id)
    try container.encodeIfPresent(message, forKey: .message)
    try container.encodeIfPresent(timestamp, forKey: .timestamp)
    try container.encodeIfPresent(ownerID, forKey: .ownerID)
    try container.encodeIfPresent(profilePicLink, forKey: .profilePicLink)
    try container.encodeIfPresent(contentType.rawValue, forKey: .contentType)
    try container.encodeIfPresent(content, forKey: .content)
    try container.encodeIfPresent(uniqueCount, forKey: .uniqueCount)
    try container.encodeIfPresent(orderRefString, forKey: .orderRefString)
    try container.encodeIfPresent(orderTitle, forKey: .orderTitle)
    try container.encodeIfPresent(orderdate, forKey: .orderdate)
    try container.encodeIfPresent(orderProductCount, forKey: .orderProductCount)
    try container.encodeIfPresent(orderComment, forKey: .orderComment)
    try container.encodeIfPresent(orderStatus, forKey: .orderStatus)
  }
  
  init() {}
  
  public required convenience init(from decoder: Decoder) throws {
    self.init()
    let container = try decoder.container(keyedBy: CodingKeys.self)
    id = try container.decode(String.self, forKey: .id)
    message = try container.decodeIfPresent(String.self, forKey: .message)
    timestamp = try container.decodeIfPresent(Int.self, forKey: .timestamp) ?? Int(Date().timeIntervalSince1970)
    ownerID = try container.decodeIfPresent(String.self, forKey: .ownerID)
    profilePicLink = try container.decodeIfPresent(String.self, forKey: .profilePicLink)
    content = try container.decodeIfPresent(String.self, forKey: .content)
    uniqueCount = try container.decodeIfPresent(Int.self, forKey: .uniqueCount) ?? Int(0)
    orderRefString = try container.decodeIfPresent(String.self, forKey: .orderRefString)
    orderTitle = try container.decodeIfPresent(String.self, forKey: .orderTitle)
    orderdate = try container.decodeIfPresent(String.self, forKey: .orderdate)
    orderComment = try container.decodeIfPresent(String.self, forKey: .orderComment)
    orderStatus = try container.decodeIfPresent(String.self, forKey: .orderStatus)!
    orderProductCount = try container.decodeIfPresent(Int.self, forKey: .orderProductCount) ?? Int(0)
   
    if let contentTypeValue = try container.decodeIfPresent(Int.self, forKey: .contentType) {
      contentType = ContentType(rawValue: contentTypeValue) ?? ContentType.unknown
    }
  }
}

extension ObjectMessage {
  private enum CodingKeys: String, CodingKey {
    case id
    case message
    case timestamp
    case ownerID
    case profilePicLink
    case contentType
    case content
    case uniqueCount
    case orderRefString
    case orderTitle
    case orderdate
    case orderProductCount
    case orderComment
    case orderStatus
  }
  
  enum ContentType: Int {
    case none
    case photo
    case location
    case product
    case unknown
  }
}
