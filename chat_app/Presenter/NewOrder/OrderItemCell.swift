import UIKit

class OrderItemCell: UITableViewCell {
  
    //MARK: IBOutlets
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var stepper: UIStepper!
    @IBOutlet weak var caseNumLabel: UILabel!
    @IBOutlet weak var case_unit: UILabel!
    
    //MARK: Private properties
    let order_manager = OrderdataManager()
    let userID = UserManager().currentUserID() ?? ""

    private var productItem = ObjectProduct()
    var conversation = ObjectConversation()
    
    //MARK: Public methods
    func set(_ product: ObjectProduct) {
        //    timeLabel.text = DateService.shared.format(Date(timeIntervalSince1970: TimeInterval(conversation.timestamp)))
        messageLabel.text = product.name
        caseNumLabel.text = product.cases?.description
        case_unit.text = product.unit
        stepper.value = Double.init(product.cases ??  0)
        stepper.transform = CGAffineTransform(scaleX: 1.5, y: 1.5);
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
        productItem.cases = cases
//        print("update id \(productItem.id)")
        order_manager.create_product(productItem, conversation: conversation) { result in
            if result == .success {
                self.caseNumLabel.text = Int(cases).description
            }
        }
    }
}

