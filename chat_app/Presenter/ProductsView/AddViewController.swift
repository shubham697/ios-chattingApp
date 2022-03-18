import UIKit
import iOSDropDown

class AddViewController: UIViewController , UITextFieldDelegate     {

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    @IBOutlet weak var product_id: UITextField!
    @IBOutlet weak var product_name: UITextField!
    @IBOutlet weak var product_unit: UITextField!
    @IBOutlet weak var product_price: UITextField!
    @IBOutlet weak var product_category: DropDown!
    @IBOutlet weak var product_status: DropDown!
    
    private var categories = [ObjectCategory]()
    var product_manager = ProductManager()
    let order_manager = OrderdataManager()
    
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        product_status.text = "active"
        product_status.optionArray = ["active", "inactive"]
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        product_manager.get_categories() {[weak self] categories in
            print("category count \(categories.count)")
            var tmp_arr = [String]()
            for category in categories {
                tmp_arr.append(category.name!)
            }
            self!.categories = categories
            self!.product_category.optionArray = tmp_arr
        }
        
        navigationController?.setNavigationBarHidden(true, animated: true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
         view.endEditing(true)
     }
    
    @IBAction func onAddCategory(_ sender: Any) {
        let alert = UIAlertController(title: "Add new category", message: "Enter name of new category", preferredStyle: .alert)

        alert.addTextField { (textField) in
//            textField.text = "Some default text"
        }
        alert.view.tintColor = UIColor.init(red: 0.33, green: 0.33, blue: 0.37, alpha: 1)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]
            print("Text field: \(textField?.text)")
            let new_category = ObjectCategory()
            new_category.name = textField?.text
            self.create_category(new_category)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { [weak alert] (_) in
            alert?.dismiss(animated: false)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func onDone(_ sender: Any) {
        product_id.borderWidth = 0
        product_name.borderWidth = 0
        product_unit.borderWidth = 0
        product_price.borderWidth = 0
        product_category.borderWidth = 0
        
        guard let _id = product_id.text, let _name = product_name.text, let _unit = product_unit.text, let _price = product_price.text, let _category = product_category.text, let _status = product_status.text  else {
          return
        }
        guard !_id.isEmpty else {
            product_id.borderWidth = 1
            product_id.borderColor = .red
            return
        }
        guard !_name.isEmpty else {
            product_name.borderWidth = 1
            product_name.borderColor = .red
            return
        }
        guard !_unit.isEmpty else {
            product_unit.borderWidth = 1
            product_unit.borderColor = .red
            return
        }
        guard !_price.isEmpty else {
            product_price.borderWidth = 1
            product_price.borderColor = .red
            return
        }
//        guard !_category.isEmpty else {
//            product_category.borderWidth = 1
//            product_category.borderColor = .red
//            return
//        }
        view.endEditing(true)
        
        let new_product = ObjectProduct()
        new_product.product_id = _id
        new_product.name = _name
        new_product.unit = _unit
        new_product.price = _price
        new_product.category = _category
        new_product.status = _status
        
        ThemeService.showLoading(true)
        product_manager.create_product(new_product) { result in
            ThemeService.showLoading(false)
            switch result {
            case .failure :
                 self.showAlert()
            case .success :
                 self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @IBAction func onCancel(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    

    private func create_category(_ category: ObjectCategory) {
        for category_item in categories {
            if category_item.name == category.name {
                showAlert(title: "Warning", message: "This category already exist!", completion: nil)
                return
            }
        }

        product_manager.create_category(category) {[weak self] response in
            guard let weakSelf = self else { return }
            if response == .failure {
                weakSelf.showAlert()
                return
            }
        }
   }
}




//MARK: IBActions
extension AddViewController {
  
}

