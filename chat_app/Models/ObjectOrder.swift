import UIKit

class ObjectOrder : FireCodable {
  
    var id =  Int.random(in: 1000 ..< 100000).description  //UUID().uuidString
  var title: String?
  var comment: String?
  var status = "Active"
  var create_date = Int(Date().timeIntervalSince1970)
  var delivery_date = Int(Date().timeIntervalSince1970)
  var date : String?
  var owner_id : String?
  var products = [ObjectProduct]()

   enum CodingKeys: String, CodingKey {
       case id
       case title
       case comment
       case status
       case date
       case owner_id
       case create_date
       case delivery_date
   }
}
