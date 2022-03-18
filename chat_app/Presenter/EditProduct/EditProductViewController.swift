import UIKit
import iOSDropDown

class EditProductViewController: UIViewController , UITextFieldDelegate     {

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    var productItem = ObjectProduct()
    var conversation = ObjectConversation()
    
    @IBOutlet weak var category_dropdown: DropDown!
    @IBOutlet weak var product_name: UITextField!
    @IBOutlet weak var product_unit: UITextField!
    @IBOutlet weak var product_id: UITextField!
    @IBOutlet weak var product_count: UITextField!
    
    let order_manager = OrderdataManager()
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for category in AppdataManager.sharedInstance.categories {
            category_dropdown.optionArray.append(category.name!)
        }
        
        product_name.text = productItem.name
        product_unit.text = productItem.unit
        product_id.text = productItem.product_id
        product_count.text = productItem.count?.description
        category_dropdown.text = productItem.category
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
extension EditProductViewController {
    
    @IBAction func backBtnPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func EditProduct(_ sender: Any) {
        
        productItem.name = product_name.text
        productItem.unit = product_unit.text
        productItem.product_id = product_id.text
        productItem.count = Int(product_count.text!)
        productItem.category = category_dropdown.text
        order_manager.create_product(productItem, conversation: conversation) { result in
            if result == .success {
                self.dismiss(animated: true, completion: nil)
            }
            else {
                self.showAlert(title: "Error", message: "Something went wrong!") {}
            }
        }
        
    }

    @IBAction func deleteProduct(_ sender: Any) {
        order_manager.delete_product(productItem, conversation: conversation) { result in
            if result == .success {
                self.dismiss(animated: true, completion: nil)
            }
            else {
                self.showAlert(title: "Error", message: "Something went wrong!") {}
            }
        }
    }
}

