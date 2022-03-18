import Foundation
import FirebaseFirestore

class ProductManager {
  
    let service = FirestoreService()
 
    func get_products(_ completion: @escaping CompletionObject<[ObjectProduct]>) {
        guard let userID = UserManager().currentUserID() else { return }
        let reference = FirestoreService.Reference(first: .users, second: .products, id: userID)
        service.objects(ObjectProduct.self, reference: reference, parameter: nil) { results in
            completion(results)
        }
    }

    func create_product(_ product: ObjectProduct,  _ completion: @escaping CompletionObject<FirestoreResponse>) {
        guard let userID = UserManager().currentUserID() else { return }
        let reference = FirestoreService.Reference(first: .users, second: .products, id: userID)
        service.update(product, reference: reference) { result in
            completion(result)
        }
    }
    
    func delete_product(_ product: ObjectProduct, _ completion: @escaping CompletionObject<FirestoreResponse>) {
        guard let userID = UserManager().currentUserID() else { return }
        let reference = FirestoreService.Reference(first: .users, second: .products, id: userID)
        let query = FirestoreService.DataQuery(key: "id", value: product.id, mode: .equal)
        service.delete(ObjectProduct.self, reference: reference, parameter: query) { result in
            completion(result)
        }
    }
    
    // category
    func get_categories(_ completion: @escaping CompletionObject<[ObjectCategory]>) {
        guard let userID = UserManager().currentUserID() else { return }
        let reference = FirestoreService.Reference(first: .users, second: .categories, id: userID)
        service.objectWithListener(ObjectCategory.self, reference: reference) { results in
           completion(results)
        }
    }

    func create_category(_ category: ObjectCategory,  _ completion: @escaping CompletionObject<FirestoreResponse>) {
        if category.name == nil {
           completion(.failure)
           return
        }
        category.name = category.name?.trimmingCharacters(in: .whitespacesAndNewlines)
        if category.name == "" {
           completion(.failure)
           return
        }

        guard let userID = UserManager().currentUserID() else { return }
        let reference = FirestoreService.Reference(first: .users, second: .categories, id: userID)
        service.update(category, reference: reference) { result in
            completion(result)
        }
    }
}

