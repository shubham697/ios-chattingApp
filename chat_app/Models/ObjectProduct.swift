import UIKit

class ObjectProduct : FireCodable{
  
    var id = UUID().uuidString
    var name: String?
    var product_id: String?
    var category: String?
    var unit: String?
    var price : String?
    var count : Int?
    var cases : Int?
    var owner_id : String?
    var status : String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case product_id
        case category
        case unit
        case price
        case count
        case cases
        case owner_id
        case status
    }
}
