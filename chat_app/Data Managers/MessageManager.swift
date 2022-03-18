import Foundation
import FirebaseFirestore

class MessageManager {
  
  let service = FirestoreService()
  
  func messages(for conversation: ObjectConversation, _ completion: @escaping CompletionObject<[ObjectMessage]>) {
    let reference = FirestoreService.Reference(first: .conversations, second: .messages, id: conversation.id)
    service.objectWithListener(ObjectMessage.self, reference: reference) { results in
        
      completion(results)
    }
  }
  
  func create(_ message: ObjectMessage, conversation: ObjectConversation, _ completion: @escaping CompletionObject<FirestoreResponse>) {
    FirestorageService().update(message, reference: .messages) { response in
      switch response {
      case .failure: completion(response)
      case .success:
        
        let group = DispatchGroup() // initialize
        var total_msg_count = 0;
        let docRef = Firestore.firestore().collection("Conversations").document(conversation.id)

        group.enter()
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
//                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
//                print("Document data: \(dataDescription)")
                let docData = document.data()
                total_msg_count = docData!["total_msg_count"] as? Int ?? 0
                print("total msg count : \(total_msg_count)")
                group.leave()
            } else {
                total_msg_count = 0
                group.leave()
            }
        }
        group.notify(queue: .main)
        {
            let reference = FirestoreService.Reference(first: .conversations, second: .messages, id: conversation.id)
            message.uniqueCount = total_msg_count
            FirestoreService().update(message, reference: reference) { result in
              completion(result)
            }
            if let id = conversation.isRead.filter({$0.key != UserManager().currentUserID() ?? ""}).first {
              conversation.isRead[id.key] = false
            }
            conversation.total_msg_count = total_msg_count + 1
            ConversationManager().create(conversation)
        }
        
      }
    }
  }
}
