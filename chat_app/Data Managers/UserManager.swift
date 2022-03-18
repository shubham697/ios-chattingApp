import FirebaseAuth

class UserManager {
  
  private let service = FirestoreService()
  
  func currentUserID() -> String? {
//    return Auth.auth().currentUser?.email
    return UserDefaults.standard.string(forKey: "user_phone")
  }
  
    func currentUserEmail() -> String? {
        return UserDefaults.standard.string(forKey: "user_email")
    }
    
  func currentUserData(_ completion: @escaping CompletionObject<ObjectUser?>) {
//    guard let id = Auth.auth().currentUser?.email else { completion(nil); return }
    guard let id = UserDefaults.standard.string(forKey: "user_phone") else { completion(nil); return }
    let query = FirestoreService.DataQuery(key: "id", value: id, mode: .equal)
    service.objectWithListener(ObjectUser.self, parameter: query, reference: .init(location: .users), completion: { users in
      completion(users.first)
    })
  }
    
  //    currently not using
  func login(user: ObjectUser, completion: @escaping CompletionObject<FirestoreResponse>) {
    guard let email = user.phone_email, let password = user.password else { completion(.failure); return }
    Auth.auth().signIn(withEmail: email, password: password) { (_, error) in
      if error.isNone {
        completion(.success)
        return
      }
      completion(.failure)
    }
  }
  
  //    currently not using
  func register(user: ObjectUser, completion: @escaping CompletionObject<FirestoreResponse>) {
    guard let email = user.phone_email, let password = user.password else { completion(.failure); return }
    Auth.auth().createUser(withEmail: email, password: password) {[weak self] (reponse, error) in
      guard error.isNone else { completion(.failure); return }
        user.id = reponse?.user.email ?? UUID().uuidString
      self?.update(user: user, completion: { result in
        completion(result)
      })
    }
  }
  
  func update(user: ObjectUser, completion: @escaping CompletionObject<FirestoreResponse>) {
    FirestorageService().update(user, reference: .users) { response in
      switch response {
      case .failure: completion(.failure)
      case .success:
        FirestoreService().update(user, reference: .init(location: .users), completion: { result in
          completion(result)
        })
      }
    }
  }
    
    func find_user(phone_number : String, completion: @escaping CompletionObject<ObjectUser?>) {
        let query = FirestoreService.DataQuery(key: "phone", value: phone_number, mode: .equal)
        service.objects(ObjectUser.self, reference: .init(location: .users), parameter: query) { users in
          completion(users.first)
        }
    }
    
    func find_user_email(email : String, completion: @escaping CompletionObject<ObjectUser?>) {
        let query = FirestoreService.DataQuery(key: "email", value: email, mode: .equal)
        service.objects(ObjectUser.self, reference: .init(location: .users), parameter: query) { users in
          completion(users.first)
        }
    }

    func contacts(_ completion: @escaping CompletionObject<[ObjectUser]>) {
        FirestoreService().objects(ObjectUser.self, reference: .init(location: .users)) { results in
        completion(results)
        }
    }

    func userData(for id: String, _ completion: @escaping CompletionObject<ObjectUser?>) {
        let query = FirestoreService.DataQuery(key: "id", value: id, mode: .equal)
        FirestoreService().objects(ObjectUser.self, reference: .init(location: .users), parameter: query) { users in
        completion(users.first)
        }
    }

    @discardableResult func logout() -> Bool {
        UserDefaults.standard.removeObject(forKey: "user_phone")
        UserDefaults.standard.removeObject(forKey: "user_email")
        return true
        //    do {
        //      try Auth.auth().signOut()
        //      return true
        //    } catch {
        //      return false
        //    }
    }
}
