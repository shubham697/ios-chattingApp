import Foundation
import FirebaseFirestore

class CatalogManager {
  
    let service = FirestoreService()
 
    func get_products(_ user_id : String,  completion: @escaping CompletionObject<[ObjectProduct]>) {
       
        let reference = FirestoreService.Reference(first: .users, second: .products, id: user_id)
        service.objects(ObjectProduct.self, reference: reference, parameter: nil) { results in
            completion(results)
        }
    }

   
    
    // category
    func get_categories(_ user_id : String, completion: @escaping CompletionObject<[ObjectCategory]>) {
        
        let reference = FirestoreService.Reference(first: .users, second: .categories, id: user_id)
        service.objectWithListener(ObjectCategory.self, reference: reference) { results in
           completion(results)
        }
    }

}

