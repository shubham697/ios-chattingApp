import Foundation
import FirebaseFirestore

class OrderdataManager {
  
  let service = FirestoreService()
  
}


// category management
extension OrderdataManager {

    func categories(conversation : ObjectConversation, _ completion: @escaping CompletionObject<[ObjectCategory]>) {
        let reference = FirestoreService.Reference(first: .conversations, second: .categories, id: conversation.id)
        service.objectWithListener(ObjectCategory.self, reference: reference) { results in
            completion(results)
        }
    }

    func create_category(_ category: ObjectCategory, _ conversation : ObjectConversation, _ completion: @escaping CompletionObject<FirestoreResponse>) {
        
        if category.name == nil {
            completion(.failure)
            return
        }
        category.name = category.name?.trimmingCharacters(in: .whitespacesAndNewlines)
        if category.name == "" {
            completion(.failure)
            return
        }
        let reference = FirestoreService.Reference(first: .conversations, second: .categories, id: conversation.id)
        FirestoreService().update(category, reference: reference) { result in
            completion(result)
        }
    }
}



// products ( saved list )  management
extension OrderdataManager {

    
    func getProductList(conversation : ObjectConversation, _ completion: @escaping CompletionObject<[ObjectProduct]>) {
        let reference = FirestoreService.Reference(first: .conversations, second: .products, id: conversation.id)
        guard let userID = UserManager().currentUserID() else { return }
        let query = FirestoreService.DataQuery(key: "owner_id", value: userID, mode: .equal)
        service.objects(ObjectProduct.self, reference: reference, parameter: query) { results in
            completion(results)
        }
    }
    

    func create_product(_ product: ObjectProduct, conversation : ObjectConversation, _ completion: @escaping CompletionObject<FirestoreResponse>) {
        let reference = FirestoreService.Reference(first: .conversations, second: .products, id: conversation.id)
        FirestoreService().update(product, reference: reference) { result in
            completion(result)
        }
    }
    
    func delete_product(_ product: ObjectProduct, conversation : ObjectConversation, _ completion: @escaping CompletionObject<FirestoreResponse>) {
        let reference = FirestoreService.Reference(first: .conversations, second: .products, id: conversation.id)
        let query = FirestoreService.DataQuery(key: "id", value: product.id, mode: .equal)
        FirestoreService().delete(ObjectProduct.self, reference: reference, parameter: query) { result in
            completion(result)
        }
    }
}

// order management
extension OrderdataManager {

    func create_order(_ order: ObjectOrder, _ completion: @escaping CompletionObject<FirestoreResponse>) {
        let reference = FirestoreService.Reference(location: .orders)
        print("order data manager reference \(order.id)")
        FirestoreService().update(order, reference: reference) { result in
            switch result {
            case .failure :
                completion(.failure)
            case .success :
                for product in order.products {
                    let product_ref = FirestoreService.Reference(first: .orders, second: .products, id: order.id)
                    FirestoreService().update(product, reference: product_ref) { result in
                    }
                }
                print("order managmanager success")
                completion(.success)
            }
            
        }
    }
    
    func change_order_product(_ order_ref: String, order_product : ObjectProduct, _ completion: @escaping CompletionObject<FirestoreResponse>) {
        let reference = FirestoreService.Reference(first: .orders, second: .products, id: order_ref)
        FirestoreService().update(order_product, reference: reference) { result in
            completion(result)
        }
    }
    
    func cancel_order(_ order: ObjectOrder, message : ObjectMessage, conversation_id : String, _ completion: @escaping CompletionObject<FirestoreResponse>) {
        
        let reference = FirestoreService.Reference(location: .orders)
        let msg_order_reference = FirestoreService.Reference(first: .conversations, second: .messages, id: conversation_id)
        
        order.status = "Cancelled"
        FirestoreService().update(order, reference: reference) { result in
            if result == .failure {
                completion(result)
            }
            else{
                for product in order.products {
                    let product_ref = FirestoreService.Reference(first: .orders, second: .products, id: order.id)
                    product.cases = 0
                    FirestoreService().update(product, reference: product_ref) { result in
                    }
                }
                
                message.orderStatus = "Cancelled"
                FirestoreService().update(message, reference: msg_order_reference) { result in
                  completion(result)
                }
            }
        }
    }
    
    func get_order(_ order_id: String, _ completion: @escaping CompletionObject<ObjectOrder>) {
        
        let order = ObjectOrder()
        let orderRef = Firestore.firestore().collection("Orders").document(order_id)
        let group = DispatchGroup() // initialize
        group.enter()
        orderRef.getDocument { (document, error) in
            if let document = document, document.exists {
        //                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
        //                print("Document data: \(dataDescription)")
                let docData = document.data()
                order.id = order_id
                order.comment =  docData!["comment"] as? String ?? ""
                order.date =  docData!["date"] as? String ?? ""
                order.title =  docData!["title"] as? String ?? ""
                group.leave()
            } else {
                group.leave()
                completion(order)
                return
            }
        }
        
        group.notify(queue: .main)
        {
            orderRef.collection("Products").getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                    completion(order)
                } else {
                    for document in querySnapshot!.documents {
//                        print("\(document.documentID) => \(document.data())")
                        let docData = document.data()
                        let product = ObjectProduct()
                        product.id = docData["id"] as? String ?? ""
                        product.category = docData["category"] as? String ?? ""
                        product.name = docData["name"] as? String ?? ""
                        product.product_id = docData["product_id"] as? String ?? ""
                        product.unit = docData["unit"] as? String ?? ""
                        product.count = docData["count"] as? Int ?? 0
                        product.cases = docData["cases"] as? Int ?? 0
                        order.products.append(product)
                    }
                    
                    completion(order)
                }
            }
            
        }
    }
}
