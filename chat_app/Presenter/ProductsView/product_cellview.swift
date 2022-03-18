import UIKit

class product_cellview: UITableViewCell {
  
    //MARK: IBOutlets
    @IBOutlet weak var product_id: UILabel!
    @IBOutlet weak var product_category: UILabel!
    @IBOutlet weak var product_name: UILabel!
    @IBOutlet weak var product_status: UILabel!
    
    
    //MARK: Private properties
    private var productItem = ObjectProduct()
    
    //MARK: Public methods
    func set(_ product: ObjectProduct) {
        productItem = product
        
        product_id.text = product.product_id
        product_name.text = product.name
        product_status.text = product.status
        product_category.text = product.category
    }

    //MARK: Lifecycle
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
}

