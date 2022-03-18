
import UIKit

extension UIStoryboard {
  
  class func controller<T: UIViewController>(storyboard: StoryboardEnum) -> T {
    return UIStoryboard(name: storyboard.rawValue, bundle: nil).instantiateViewController(withIdentifier: T.className) as! T
  }
  
  class func initial<T: UIViewController>(storyboard: StoryboardEnum) -> T {
    return UIStoryboard(name: storyboard.rawValue, bundle: nil).instantiateInitialViewController() as! T
  }
  
  enum StoryboardEnum: String {
    case initial = "Initial"
    case auth = "Auth"
    case conversations = "Conversations"
    case profile = "Profile"
    case previews = "Previews"
    case messages = "Messages"
    case order = "NewOrder"
    case product = "AddProduct"
    case edit_product = "EditProduct"
    case order_summary = "OrderSummary"
    case order_detail = "OrderView"
    case login = "Login"
    case register = "Register"
    case supplier_dash = "SupplierDash"
    case add_shipping = "AddShipping"
    case product_view = "ProductsView"
    case user_info = "UserInfo"
    case catalog_view = "CatalogView"
  }
}
