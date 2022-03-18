import UIKit
import iOSDropDown

class ProductsManageViewController: UIViewController , UITextFieldDelegate , UISearchBarDelegate    {

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var searchbar: UISearchBar!
    @IBOutlet weak var category_dropdown: DropDown!
    @IBOutlet weak var share_btn: UIButton!
    
    var product_manager = ProductManager()
    let order_manager = OrderdataManager()
    var user_manager = UserManager()
    var all_saved_products = [ObjectProduct]()
    var saved_products = [ObjectProduct]()
    var categories = [ObjectCategory]()
    var shared_flag = false
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableview.delegate = self
        tableview.dataSource = self
        searchbar.autocapitalizationType = .none
        searchbar.delegate = self
        
        category_dropdown.text = "All"
        category_dropdown.didSelect{(selectedText , index ,id) in
            print("Selected String: \(selectedText) \n index: \(index)")
            var cur_category = selectedText
            if cur_category == "All" {
                cur_category = ""
            }
            self.getSortedOrder(filter_category: cur_category, filter_product_name: self.searchbar.text!)
            self.tableview.reloadData()
        }
        fetchCategories()
        
        user_manager.userData(for: user_manager.currentUserID()!) { cur_user in
            if cur_user == nil { return }
            if cur_user!.shared_catalog == nil || cur_user!.shared_catalog == false {
                self.shared_flag = false
            }
            else {
                self.shared_flag = true
            }
            let title = self.shared_flag ? "Hide my catalog" : "Share my catalog"
            self.share_btn.setTitle(title, for: [])
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.setNavigationBarHidden(true, animated: true)
        
        product_manager.get_products() { results in
            print("products \(results.count)")
            self.all_saved_products = results
            
            var cur_category = self.category_dropdown.text
            if cur_category == "All" {
                cur_category = ""
            }
            self.getSortedOrder(filter_category: cur_category!, filter_product_name: self.searchbar.text!)
            self.tableview.reloadData()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
         view.endEditing(true)
     }
    
    @IBAction func onBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil);
    }
    @IBAction func onAddProduct(_ sender: Any) {
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        var cur_category = self.category_dropdown.text
        if cur_category == "All" {
            cur_category = ""
        }
        self.getSortedOrder(filter_category: cur_category!, filter_product_name: searchText)
        self.tableview.reloadData()
    }
    
    @IBAction func shareCatalog(_ sender: UIButton) {
        if user_manager.currentUserID() == nil  { return }
        user_manager.userData(for: user_manager.currentUserID()!) { cur_user in
            if cur_user == nil { return }
            cur_user!.shared_catalog = cur_user!.shared_catalog == nil || cur_user!.shared_catalog == false ? true : false
            self.user_manager.update(user: cur_user!) { results in
                if results == .failure {
                    self.showAlert()
                }
                else {
                    self.shared_flag = !self.shared_flag
                    self.updateBtnText()
                }
            }
            
        }
    }
    
    private func updateBtnText () {
        let title = shared_flag ? "Hide my catalog" : "Share my catalog"
        if shared_flag {
            showAlert(title: "Warning", message: "All your ModProd contacts will now have access to your products", completion: {
                self.share_btn.setTitle(title, for: [])
            })
        }
        else {
            showAlert(title: "Warning", message: "Your ModProd contacts will no longer have access to your product catalog", completion: {
                self.share_btn.setTitle(title, for: [])
            })
        }
    }
}


//MARK: private
extension ProductsManageViewController {
  private func fetchCategories() {
      product_manager.get_categories() {[weak self] categories in
          print("category count \(categories.count)")
          var tmp_arr = ["All"]
          for category in categories {
              tmp_arr.append(category.name!)
          }
          self!.categories = categories
          self!.category_dropdown.optionArray = tmp_arr
      }
  }
    
    private func getSortedOrder (filter_category : String, filter_product_name : String) {
        let lowercase_filtered_product_name = filter_product_name.lowercased()
        var filtered_products = [ObjectProduct]()
        if filter_category == "" {
            for product in all_saved_products {
                if filter_product_name == "" {
                    filtered_products.append(product)
                }
                else {
                    if product.name!.lowercased().contains(lowercase_filtered_product_name) || product.product_id!.lowercased().contains(lowercase_filtered_product_name) {
                        filtered_products.append(product)
                    }
                }
            }
        }
        else {
            for product in all_saved_products {
                if product.category == filter_category {
                    if filter_product_name == "" {
                        filtered_products.append(product)
                    }
                    else {
                        if product.name!.lowercased().contains(lowercase_filtered_product_name) ||
                            product.product_id!.lowercased().contains(lowercase_filtered_product_name){
                            filtered_products.append(product)
                        }
                    }
                }
            }
        }
        
        saved_products = filtered_products
    }
}


//MARK: UITableView Delegate & DataSource
extension ProductsManageViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return saved_products.count;
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "product_cell_item") as! product_cellview
        cell.set(saved_products[indexPath.row] as! ObjectProduct)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc: EditViewController = UIStoryboard.controller(storyboard: .product_view)
        vc.product_item = saved_products[indexPath.row]
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if saved_products.isEmpty {
          return tableView.bounds.height - 50 //header view height
        }
        return 50
    }
}

