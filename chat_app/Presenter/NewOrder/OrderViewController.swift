import UIKit
import iOSDropDown

class OrderViewController: UIViewController , UITextFieldDelegate , UISearchBarDelegate, UIGestureRecognizerDelegate  {

    //MARK: IBOutlets
    @IBOutlet weak var searchProductBar: UISearchBar!
    @IBOutlet weak var category_dropdown: DropDown!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var profileImageView: UIImageView!
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }

    //MARK: Private properties
    private let manager = OrderdataManager()
    private var saved_products = [ObjectProduct]()
    private var categories = [ObjectCategory]()
    
    var orderData = [String : [Any]]()
    var conversation = ObjectConversation()
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        print("new order view did load")
        searchProductBar.autocapitalizationType = .none
        searchProductBar.delegate = self
        category_dropdown.text = "All"
        category_dropdown.didSelect{(selectedText , index ,id) in
            print("Selected String: \(selectedText) \n index: \(index)")
            var cur_category = selectedText
            if cur_category == "All" {
                cur_category = ""
            }
            self.getSortedOrder(filter_category: cur_category, filter_product_name_txt: self.searchProductBar.text!)
            self.tableView.reloadData()
        }
        
        fetchCategories()
        
        let tabRecognizer = UITapGestureRecognizer(target: self, action: #selector(onBaseTapOnly))
        tabRecognizer.delegate = self
        self.tableView.addGestureRecognizer(tabRecognizer)
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.searchProductBar.delegate = self
    }

    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
         if gestureRecognizer is UITapGestureRecognizer {
            let location = touch.location(in: tableView)
            if(tableView.indexPathForRow(at: location) != nil)
            {
                searchProductBar.becomeFirstResponder()
                view.endEditing(true)
//                goEdit(indexPath: tableView.indexPathForRow(at: location)!)
            }
            return (tableView.indexPathForRow(at: location) == nil)
         }
         return true
    }
    
    @objc func onBaseTapOnly(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            view.endEditing(true)
        }
    }
  
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        print("new order appear")
        self.searchProductBar.text = ""
        
        manager.getProductList(conversation: conversation) {[weak self] products in
            var tmp_products = [ObjectProduct]()
            for item in products {
                item.cases = 0
                tmp_products.append(item)
            }
            self!.saved_products = tmp_products
            print("fetched product count \(products.count)")
            var cur_category = self!.category_dropdown.text
            if cur_category == "All" {
                cur_category = ""
            }
            self!.getSortedOrder(filter_category: cur_category!, filter_product_name_txt: "")
            self!.tableView.reloadData()
        }
        
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
  
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        print("new order disappear")
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}

//MARK: IBActions
extension OrderViewController {
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func goOrderSummary(_ sender: UIButton) {
        let vc: OrderSummaryViewController = UIStoryboard.initial(storyboard: .order_summary)
        vc.conversation = conversation
        vc.modalPresentationStyle = .fullScreen
        show(vc, sender: self)
    }

    @IBAction func addCategoryBtnPressed(_ sender: Any) {
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
    
    @IBAction func openAddProduct(_ sender: Any) {
        let vc: AddProductViewController = UIStoryboard.initial(storyboard: .product)
        vc.modalPresentationStyle = .fullScreen
        vc.categories = self.categories
        vc.conversation = conversation
        show(vc, sender: self)
//        self.present(vc, animated: true)
    }
}

//MARK: Private methods
extension OrderViewController {
    private func fetchCategories() {
        manager.categories(conversation: conversation) {[weak self] category_list in
            print("category count \(category_list.count)")
            var arr = ["All"]
            for category in category_list {
                arr.append(category.name!)
            }
            self!.category_dropdown.optionArray = arr
            
            var tmp_categories = category_list
            let new_blank_categ = ObjectCategory()
            new_blank_categ.name = ""
            tmp_categories.append(new_blank_categ)
            self!.categories = tmp_categories
        }
    }
    
    
    private func create_category(_ category: ObjectCategory) {
        for category_item in categories {
            if category_item.name == category.name {
                showAlert(title: "Warning", message: "This category already exist!", completion: nil)
                return
            }
        }
        manager.create_category(category, conversation) {[weak self] response in
            guard let weakSelf = self else { return }
            if response == .failure {
              weakSelf.showAlert()
              return
            }
        }
    }
    
    private func getSortedOrder (filter_category : String, filter_product_name_txt : String) {
        let filter_product_name = filter_product_name_txt.lowercased()
        orderData = [String : [Any]]()
        if filter_category == "" {
            for category in categories {
                for product in saved_products {
                    if product.category == category.name {
                        if filter_product_name == "" {
                            if orderData[category.name!] == nil {
                                orderData[category.name!] = [product]
                            }
                            else {
                                orderData[category.name!]!.append(product)
                            }
                        }
                        else {
                            if product.name!.lowercased().contains(filter_product_name) {
                                if orderData[category.name!] == nil {
                                    orderData[category.name!] = [product]
                                }
                                else {
                                    orderData[category.name!]!.append(product)
                                }
                            }
                        }
                    }
                }
            }
        }
        else {
            for product in saved_products {
                if product.category == filter_category {
                    if filter_product_name == "" {
                        if orderData[filter_category] == nil {
                            orderData[filter_category] = [product]
                        }
                        else {
                            orderData[filter_category]!.append(product)
                        }
                    }
                    else {
                        if product.name!.lowercased().contains(filter_product_name) {
                            if orderData[filter_category] == nil {
                                orderData[filter_category] = [product]
                            }
                            else {
                                orderData[filter_category]!.append(product)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        var cur_category = category_dropdown.text!
        if cur_category == "All" {
            cur_category = ""
        }
        getSortedOrder(filter_category: cur_category, filter_product_name_txt: searchText.lowercased())
        self.tableView.reloadData()
    }
    
    func goEdit(indexPath : IndexPath ) {
        let vc: EditProductViewController = UIStoryboard.initial(storyboard: .edit_product)
        
        let key = Array(orderData.keys)[indexPath.section]
        vc.conversation = conversation
        vc.productItem = orderData[key]![indexPath.row] as! ObjectProduct
        vc.modalPresentationStyle = .fullScreen
        show(vc, sender: self)
    }
}

//MARK: UITableView Delegate & DataSource
extension OrderViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        print("section count", orderData.count)
        return orderData.count;
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Array(orderData.keys)[section]
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if orderData.isEmpty {
          return 1
        }
        
        let key = Array(orderData.keys)[section]
        return orderData[key]!.count;
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard !orderData.isEmpty else {
            return tableView.dequeueReusableCell(withIdentifier: "EmptyCell")!
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "productItemCell") as! OrderItemCell
        
        let key = Array(orderData.keys)[indexPath.section]
        cell.conversation = conversation
        cell.set(orderData[key]![indexPath.row] as! ObjectProduct)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        goEdit(indexPath: indexPath)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if orderData.isEmpty {
          return tableView.bounds.height - 50 //header view height
        }
        return 80
    }
}
