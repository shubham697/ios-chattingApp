import Foundation

class ConversationManager {
  
  let service = FirestoreService()
  
  func currentConversations(_ completion: @escaping CompletionObject<[ObjectConversation]>) {
  
    guard let userID = UserManager().currentUserID() else { return }
   
    let query = FirestoreService.DataQuery(key: "userIDs", value: userID, mode: .contains)
    service.objectWithListener(ObjectConversation.self, parameter: query, reference: .init(location: .conversations)) { results in
      completion(results)
    }
  }
  
  func create(_ conversation: ObjectConversation, _ completion: CompletionObject<FirestoreResponse>? = nil) {
    FirestoreService().update(conversation, reference: .init(location: .conversations)) { completion?($0) }
  }
  
  func markAsRead(_ conversation: ObjectConversation, _ completion: CompletionObject<FirestoreResponse>? = nil) {
    guard let userID = UserManager().currentUserID() else { return }
    guard conversation.isRead[userID] == false else { return }
    conversation.isRead[userID] = true
    FirestoreService().update(conversation, reference: .init(location: .conversations)) { completion?($0) }
  }
    
    func delete_conversation(_ conversation: ObjectConversation, _ completion: @escaping CompletionObject<FirestoreResponse>) {
        let query = FirestoreService.DataQuery(key: "id", value: conversation.id, mode: .equal)
        service.delete(ObjectConversation.self, reference: .init(location: .conversations), parameter: query) { result in
            completion(result)
        }
    }
}
