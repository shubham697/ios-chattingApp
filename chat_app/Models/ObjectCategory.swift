import UIKit

class ObjectCategory : FireCodable {
  
  var id = UUID().uuidString
  var name: String?
 
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(id, forKey: .id)
    try container.encodeIfPresent(name, forKey: .name)
  }
  
  init() {}
  
  public required convenience init(from decoder: Decoder) throws {
    self.init()
    let container = try decoder.container(keyedBy: CodingKeys.self)
    id = try container.decode(String.self, forKey: .id)
    name = try container.decodeIfPresent(String.self, forKey: .name)
  }
}

extension ObjectCategory {
  private enum CodingKeys: String, CodingKey {
    case id
    case name
  }
}
