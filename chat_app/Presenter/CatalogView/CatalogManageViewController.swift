import UIKit
import iOSDropDown

class CatalogManageViewController: UIViewController , UITextFieldDelegate , UISearchBarDelegate    {

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var searchbar: UISearchBar!
    @IBOutlet weak var category_dropdown: DropDown!
   
    
    var catalog_manager = CatalogManager()
    var all_saved_products = [ObjectProduct]()
    var saved_products = [ObjectProduct]()
    var categories = [ObjectCategory]()
    var supplier_id = ""
    
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
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.setNavigationBarHidden(true, animated: true)
        
        catalog_manager.get_products(supplier_id) { results in
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

    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        var cur_category = self.category_dropdown.text
        if cur_category == "All" {
            cur_category = ""
        }
        self.getSortedOrder(filter_category: cur_category!, filter_product_name: searchText)
        self.tableview.reloadData()
    }

}


//MARK: private
extension CatalogManageViewController {
  private func fetchCategories() {
      catalog_manager.get_categories(supplier_id) {[weak self] categories in
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
extension CatalogManageViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return saved_products.count;
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "catalog_product_cell_item") as! catalog_product_cellview
        cell.set(saved_products[indexPath.row] as! ObjectProduct)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if saved_products.isEmpty {
          return tableView.bounds.height - 50 //header view height
        }
        return 50
    }
}

