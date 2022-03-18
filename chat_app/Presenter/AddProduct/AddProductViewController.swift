import UIKit
import iOSDropDown

class AddProductViewController: UIViewController , UITextFieldDelegate     {

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    
    @IBOutlet weak var category_dropdown: DropDown!
    @IBOutlet weak var product_name: UITextField!
    @IBOutlet weak var product_unit: UITextField!
    @IBOutlet weak var product_id: UITextField!
    @IBOutlet weak var product_count: UITextField!
    
    var conversation = ObjectConversation()
    let order_manager = OrderdataManager()
    var categories = [ObjectCategory]()
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for category in categories {
            category_dropdown.optionArray.append(category.name!)
        }
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
         view.endEditing(true)
     }
}


//MARK: IBActions
extension AddProductViewController {
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func AddProduct(_ sender: Any) {
        var new_product = ObjectProduct()
        new_product.name = product_name.text
        new_product.unit = product_unit.text
        new_product.product_id = product_id.text
        new_product.count = Int(product_count.text!)
        new_product.category = category_dropdown.text
        new_product.cases = 0
        new_product.owner_id = UserManager().currentUserID()
        
        order_manager.create_product(new_product, conversation: conversation) { result in
            if result == .failure {
                self.showAlert(title: "Error", message: "We could not create this product.") {}
            }
            else {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
}

