import Foundation
class AppdataManager {
    static let sharedInstance = AppdataManager()
    
    var orderItem = ObjectOrder()
    var categories = [ObjectCategory]()
    var tmp_order_data = ObjectOrder()
    private init() { }
}
