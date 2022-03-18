
import Foundation

public enum FirestoreCollectionReference: String {
  case users = "Users"
  case conversations = "Conversations"
  case messages = "Messages"
  case categories = "Categories"
  case orders = "Orders"
  case products = "Products"
}

public enum FirestoreResponse {
  case success
  case failure
}
