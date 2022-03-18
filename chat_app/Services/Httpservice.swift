import Foundation
import Alamofire

class Httpservice {
    
    func sendNewRegister(_ phone: String, completion: @escaping CompletionObject<Bool>) {
        let url = "https://us-central1-modularproddata.cloudfunctions.net/AppApi/new_register?phone=\(phone)"
        AF.request(url, method: .get, encoding: JSONEncoding.default).responseJSON { response in
            switch response.result {
            case .success(let json):
                print(json)
                completion(true)
            case .failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    // status : new, update, cancel
    func sendOrderEmail( email : String, user: ObjectUser, order: ObjectOrder, confirm_link: String, status : String, completion: @escaping CompletionObject<Bool>) {
        let url = "https://us-central1-modularproddata.cloudfunctions.net/AppApi/send_order_email"
        
        var subject = ""
        var body_email = ""
        if status == "new" {
            subject = "NEW ORDER"
            body_email = "<h3>NEW ORDER</h3>" +
                        "<b>Order ID  : </b>\(order.id) <br/>" +
                        "<b>Company name : </b>\(user.company_name!) <br/>" +
                        "<b>Contact person : </b>\(user.phone!) <br/>" +
                        "<b>Delivery address : </b>\(user.street_address!) \(user.city!) \(user.state!) \(user.zipcode!) <br/>" +
                        "<b>Delivery notes : </b>\(order.comment!) <br/>" +
                        "<b>Requested delivery date : </b>\(order.date!) <br/><br/>"
            for product in order.products {
                body_email = body_email + "\(product.cases!) \(product.unit!) \(product.name!) (ID: \(product.product_id!)) <br/>"
            }
            body_email = body_email + "<br/> <b> Total ordered products </b>: \(order.products.count) <br/>"
            body_email = body_email + "<br/> <b> Confirm the order by clicking this link: </b> <br/> \(confirm_link) <br/>"
            body_email = body_email + "<br/> The Modular Product Group <br/>"
        }
        else if status == "update" {
            subject = "Update to existing order"
            body_email = "<h3>Update to existing order</h3>" +
                        "<b>Please rely on this latest update for order fulfillment.  This is the current state of the order.</b> <br/><br/>" +
                        "<b>Order ID  : </b>\(order.id) <br/>" +
                        "<b>Company name : </b>\(user.company_name!) <br/>" +
                        "<b>Contact person : </b>\(user.phone!) <br/>" +
                        "<b>Delivery address : </b>\(user.street_address!) \(user.city!) \(user.state!) \(user.zipcode!) <br/>" +
                        "<b>Delivery notes : </b>\(order.comment!) <br/>" +
                        "<b>Requested delivery date : </b>\(order.date!) <br/><br/>"
            for product in order.products {
                body_email = body_email + "\(product.cases!) \(product.unit!) \(product.name!) (ID: \(product.product_id!)) <br/>"
            }
            body_email = body_email + "<br/> <b> Total ordered products </b>: \(order.products.count) <br/>"
            body_email = body_email + "<br/> <b> Confirm the order by clicking this link: </b> <br/> \(confirm_link) <br/>"
            body_email = body_email + "<br/> The Modular Product Group <br/>"
        }
        else if status == "cancel" {
            subject = "Order Cancelled"
            body_email = "<h3>Order Cancelled</h3>" +
                        "<b>Please cancel all the items in the Order Id: \(order.id) </b><br/><br/>" +
                        "<b>Order ID  : </b>\(order.id) <br/>" +
                        "<b>Company name : </b>\(user.company_name!) <br/>" +
                        "<b>Contact person : </b>\(user.phone!) <br/>"
            
            body_email = body_email + "<br/> <b> Confirm the order by clicking this link: </b> <br/> \(confirm_link) <br/>"
            body_email = body_email + "<br/> The Modular Product Group <br/>"
        }
        
        let parameters = [
            "to_email": email,
            "subject" : subject,
            "body_email"  : body_email
        ]
        
        AF.request(url, method: .post, parameters: parameters).responseJSON { response in
            switch response.result {
            case .success(let json):
                print(json)
                completion(true)
            case .failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    func updateConversations(_ email: String, phone : String, completion: @escaping CompletionObject<Bool>) {
        let url = "https://us-central1-modularproddata.cloudfunctions.net/AppApi/update_conversations?phone=\(phone)&email=\(email)"
        AF.request(url, method: .get, encoding: JSONEncoding.default).responseJSON { response in
            switch response.result {
            case .success(let json):
                print(json)
                completion(true)
            case .failure(let error):
                print(error)
                completion(false)
            }
        }
    }
}
