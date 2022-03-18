import UIKit

class ItemCell: UITableViewCell {
  
    //MARK: IBOutlets
    @IBOutlet weak var product_count: UILabel!
    @IBOutlet weak var product_unit: UILabel!
    @IBOutlet weak var product_name: UILabel!
    @IBOutlet weak var stepper: UIStepper!
    
    //MARK: Private properties
    let order_manager = OrderdataManager()
    private var productItem = ObjectProduct()
    var conversation = ObjectConversation()
    var order_ref_id = ""
    
    
    //MARK: Public methods
    func set(_ product: ObjectProduct, flag : Bool, edit_flag : Bool) {
        //    timeLabel.text = DateService.shared.format(Date(timeIntervalSince1970: TimeInterval(conversation.timestamp)))
        product_name.text = product.name
        product_count.text = product.cases?.description
        product_unit.text = product.unit
        stepper.maximumValue = Double.init(product.cases ??  0)
        if flag == true {
            stepper.isHidden = true
        }
        stepper.isEnabled = edit_flag
        stepper.transform = CGAffineTransform(scaleX: 1.5, y: 1.5);
        stepper.value = Double.init(product.cases ??  0)
        print("order detail product cases \(product.cases)")
        productItem = product
    }

    @IBAction func stepperValueChanged(_ sender: Any) {
        updateProduct(Int(stepper.value))
    }
    //MARK: Lifecycle
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
     func updateProduct (_ cases : Int) {
        
        for i in 1...AppdataManager.sharedInstance.tmp_order_data.products.count {
            if AppdataManager.sharedInstance.tmp_order_data.products[i - 1].id == productItem.id {
                AppdataManager.sharedInstance.tmp_order_data.products[i - 1].cases = cases
                self.product_count.text = Int(cases).description
                break
            }
        }
//            productItem.cases = cases
//            order_manager.change_order_product(order_ref_id, order_product: productItem){ result in
//                if result == .success {
//                    self.product_count.text = Int(cases).description
//                }
//            }
    }
    
    
}

