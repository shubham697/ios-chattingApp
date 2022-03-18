import Foundation
import Alamofire

class SMSservice {
    
    func sendSMS(_ to: String, user : ObjectUser, order : ObjectOrder, confirm_link : String, completion: @escaping CompletionObject<Bool>) {
        let accountSID = "ACa2fe8aedf382aa23d78b1e4d96e16f11"
        let authToken = "83091c52cc70bb51e82b255ce281171e"

        let url = "https://api.twilio.com/2010-04-01/Accounts/\(accountSID)/Messages"
        var body_sms = "\nNEW ORDER\n\n\n" +
//            "You received a new order from \n \"\(user.name!)\" " + "\n\n" +
            "Order ID : \(order.id) \n" +
            "Company name : \(user.company_name!) \n" +
            "Contact person : \(user.phone!) \n" +
            "Delivery address : \(user.street_address!) \(user.city!) \(user.state!) \(user.zipcode!) \n\n" +
            "Delivery notes : \(order.comment!) \n" +
            "Requested delivery date : \(order.date!) \n\n"
        for product in order.products {
            body_sms = body_sms + "\(product.cases!) \(product.unit!) \(product.name!) (ID: \(product.product_id!)) \n"
        }
        body_sms = body_sms + "\n Total ordered products : \(order.products.count) \n"
        body_sms = body_sms + "\n Confirm the order by clicking this link: \n \(confirm_link) \n"
        body_sms = body_sms + "\nThe Modular Product Group \n"
        
        let parameters =
            ["From": "13342068961", // from twillo phone number
             "To": to,
             "Body": body_sms
            ]

        AF.request(url, method: .post, parameters: parameters).authenticate(username: accountSID, password: authToken).responseJSON { response in
            print("sms \(response)")
            completion(true)
//            debugPrint(response)
        }
    }
    
    func sendUpdateSMS(_ to: String, user : ObjectUser, order : ObjectOrder, confirm_link : String, completion: @escaping CompletionObject<Bool>) {
        let accountSID = "ACa2fe8aedf382aa23d78b1e4d96e16f11"
        let authToken = "83091c52cc70bb51e82b255ce281171e"

        let url = "https://api.twilio.com/2010-04-01/Accounts/\(accountSID)/Messages"
        var body_sms = "\nUpdate to existing order\n\n\n" +
            "Please rely on this latest update for order fulfillment.  This is the current state of the order.\n\n" +
            "Order ID : \(order.id) \n" +
            "Company name : \(user.company_name!) \n" +
            "Contact person : \(user.phone!) \n" +
            "Delivery address : \(user.street_address!) \(user.city!) \(user.state!) \(user.zipcode!) \n\n" +
            "Delivery notes : \(order.comment!) \n" +
            "Requested delivery date : \(order.date!) \n\n"
        for product in order.products {
            body_sms = body_sms + "\(product.cases!) \(product.unit!) \(product.name!) (ID: \(product.product_id!)) \n"
        }
        body_sms = body_sms + "\n Total ordered products : \(order.products.count) \n"
        body_sms = body_sms + "\n Confirm the order by clicking this link: \n \(confirm_link) \n"
        body_sms = body_sms + "\nThe Modular Product Group \n"
        
        let parameters =
            ["From": "13342068961", // from twillo phone number
             "To": to,
             "Body": body_sms
            ]

        AF.request(url, method: .post, parameters: parameters).authenticate(username: accountSID, password: authToken).responseJSON { response in
            print("sms \(response)")
            completion(true)
//            debugPrint(response)
        }
    }
    
    func sendCancelSMS(_ to: String, user : ObjectUser, order : ObjectOrder, confirm_link : String, completion: @escaping CompletionObject<Bool>) {
            let accountSID = "ACa2fe8aedf382aa23d78b1e4d96e16f11"
            let authToken = "83091c52cc70bb51e82b255ce281171e"

            let url = "https://api.twilio.com/2010-04-01/Accounts/\(accountSID)/Messages"
            var body_sms = "\nOrder Cancelled\n\n\n" +
                "Please cancel all the items in the Order Id: \(order.id)\n\n" +
                "Order ID : \(order.id) \n" +
                "Company name : \(user.company_name!) \n" +
                "Contact person : \(user.phone!) \n"
            body_sms = body_sms + "\n Confirm the order by clicking this link: \n \(confirm_link) \n"
            body_sms = body_sms + "\nThe Modular Product Group \n"
            
            let parameters =
                ["From": "13342068961", // from twillo phone number
                 "To": to,
                 "Body": body_sms
                ]

            AF.request(url, method: .post, parameters: parameters).authenticate(username: accountSID, password: authToken).responseJSON { response in
                print("sms \(response)")
                completion(true)
    //            debugPrint(response)
            }
    }
    
    func sendNewRegisterSMS(phone_number : String,  completion: @escaping CompletionObject<Bool>) {
        let accountSID = "ACa2fe8aedf382aa23d78b1e4d96e16f11"
        let authToken = "83091c52cc70bb51e82b255ce281171e"

        let url = "https://api.twilio.com/2010-04-01/Accounts/\(accountSID)/Messages"
        var body_sms = "\nNEW REGISTER\n\n\nPlease activate the following account \(phone_number) \n"
        body_sms = body_sms + "\nThe Modular Product Group \n"

        let parameters1 = [
            "From": "13342068961", // from twillo phone number
            "To": "3126109698",
            "Body": body_sms
        ]
        let parameters2 = [
            "From": "13342068961", // from twillo phone number
            "To": "3122031488",
            "Body": body_sms
        ]

        let group = DispatchGroup() // initialize
        group.enter()
        AF.request(url, method: .post, parameters: parameters1).authenticate(username: accountSID, password: authToken).responseJSON { response in
            print("register sms1 \(response)")
            group.leave()
        }
        
        group.notify(queue: .main)
        {
            AF.request(url, method: .post, parameters: parameters2).authenticate(username: accountSID, password: authToken).responseJSON { response in
                print("register sms2 \(response)")
                completion(true)
            }
        }
    }
    
    func sendLoginPhoneVerifySMS(to: String, verify_code : String,  completion: @escaping CompletionObject<Bool>) {
        let accountSID = "ACa2fe8aedf382aa23d78b1e4d96e16f11"
        let authToken = "83091c52cc70bb51e82b255ce281171e"

        let url = "https://api.twilio.com/2010-04-01/Accounts/\(accountSID)/Messages"
        var body_sms = "\nPhone Verification Code\n\n\n\(verify_code) \n"
        body_sms = body_sms + "\nThe Modular Product Group \n"

        let parameters = [
            "From": "13342068961", // from twillo phone number
            "To": to,
            "Body": body_sms
        ]
      
        AF.request(url, method: .post, parameters: parameters).authenticate(username: accountSID, password: authToken).responseJSON { response in
            print("login verify sms \(response)")
            completion(true)
        }
    }
}
