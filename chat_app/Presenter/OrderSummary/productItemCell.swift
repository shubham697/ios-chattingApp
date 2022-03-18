import UIKit

class productItemCell: UITableViewCell {
  
    //MARK: IBOutlets
    @IBOutlet weak var product_name: UILabel!
    @IBOutlet weak var product_count: UILabel!
    @IBOutlet weak var product_unit: UILabel!
    
    //MARK: Private properties
    private var productItem = ObjectProduct()
    
    //MARK: Public methods
    func set(_ product: ObjectProduct) {
        //    timeLabel.text = DateService.shared.format(Date(timeIntervalSince1970: TimeInterval(conversation.timestamp)))
        product_name.text = product.name
        product_count.text = product.cases?.description
        product_unit.text = product.unit
        productItem = product
    }

    //MARK: Lifecycle
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
}


