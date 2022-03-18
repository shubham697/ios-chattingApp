import UIKit
import iOSDropDown
import FirebaseFirestore

class OrderSummaryViewController: UIViewController , UITextFieldDelegate , UISearchBarDelegate    {

    //MARK: IBOutlets
    @IBOutlet weak var productTable: UITableView!
    @IBOutlet weak var order_title: UITextField!
    @IBOutlet weak var order_date: UITextField!
    @IBOutlet weak var order_comment: UITextField!
    
    //MARK: Private properties
    var orderData = [String : [Any]]()
    var manager = OrderdataManager()
    var msg_manager = MessageManager()
    var user_manager = UserManager()
    var sms_service = SMSservice()
    var http_service = Httpservice()
    var conversation = ObjectConversation()
    var delivery_date = Int(Date().timeIntervalSince1970)
    var saved_products = [ObjectProduct]()
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.productTable.delegate = self
        self.productTable.dataSource = self
        
        productTable.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
    }

    @objc func hideKeyboard() {
      view.endEditing(true)
      //textField.resignFirstResponder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        manager.getProductList(conversation: conversation) {[weak self] products in
            for product in products {
                if product.cases! > 0 {
                    self!.saved_products.append(product)
                }
            }
            print("order view \(self!.saved_products.count)")
            self!.productTable.reloadData()
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
}

//MARK: IBActions
extension OrderSummaryViewController {
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

    
    @IBAction func open_datepicker(_ sender: Any) {
        let myDatePicker: UIDatePicker = UIDatePicker()
        myDatePicker.timeZone = .current
        myDatePicker.frame = CGRect(x: 0, y: 15, width: 270, height: 200)
        let alertController = UIAlertController(title: "\n\n\n\n\n\n\n\n", message: nil, preferredStyle: .alert)
        alertController.view.addSubview(myDatePicker)
        myDatePicker.datePickerMode = .date
        myDatePicker.minimumDate =  Date()
        let dateFormater: DateFormatter = DateFormatter()
        alertController.view.tintColor = UIColor.init(red: 0.33, green: 0.33, blue: 0.37, alpha: 1)
        let selectAction = UIAlertAction(title: "Ok", style: .default, handler: { _ in
            
            self.delivery_date = Int(myDatePicker.date.timeIntervalSince1970)
            dateFormater.dateFormat = "yyyy"
            let year: String = dateFormater.string(from: myDatePicker.date)
            dateFormater.dateFormat = "MMM"
            let month: String = dateFormater.string(from: myDatePicker.date)
            dateFormater.dateFormat = "dd"
            let day: String = dateFormater.string(from: myDatePicker.date)
            dateFormater.dateFormat = "eee" // "eeee" -> Friday
            let weekDay = dateFormater.string(from: myDatePicker.date)
            
            let stringFromDate = weekDay + ", " + month + " " + day + ", " + year
            
            print("Selected Date: \(stringFromDate)")
            self.order_date.text = stringFromDate
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(selectAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }

    
    @IBAction func swipeupOrder(_ sender: Any) {
       
        var order = ObjectOrder()
        
        order.title = order_title.text
        order.comment = order_comment.text
        order.date = order_date.text
        order.products = saved_products
        order.delivery_date = delivery_date
        order.owner_id =  user_manager.currentUserID()
        ThemeService.showLoading(true)
        
        manager.create_order(order) { [weak self] response in
            guard let weakSelf = self else { return }
            if response == .failure {
                ThemeService.showLoading(false)
                weakSelf.showAlert()
                return
            }
            
            print("create order ====")
            let message = ObjectMessage()
            message.contentType = .product
            message.orderRefString = order.id
            message.ownerID = self!.user_manager.currentUserID()
            message.orderTitle = order.title
            message.orderdate = order.date
            message.orderComment = order.comment
            message.orderProductCount = order.products.count
            
            self!.msg_manager.create(message, conversation: self!.conversation) {[weak self] response in
                
                
                guard let weakSelf = self else {
                    ThemeService.showLoading(false)
                    return
                }
                if response == .failure {
                    ThemeService.showLoading(false)
                    weakSelf.showAlert()
                    return
                }
                weakSelf.conversation.timestamp = Int(Date().timeIntervalSince1970)
                weakSelf.conversation.lastMessage = "Order"
                if let currentUserID = self!.user_manager.currentUserID() {
                    weakSelf.conversation.isRead[currentUserID] = true
                }
                ConversationManager().create(weakSelf.conversation)
                
                weakSelf.sendOrder_SMS_Email(order_item: order)
              
            }
        }
      
    }
}

//MARK: Private methods
extension OrderSummaryViewController {
    func goMessage() {
        let vc: MessagesViewController = UIStoryboard.initial(storyboard: .messages)
        vc.modalPresentationStyle = .fullScreen
        vc.conversation = conversation
        show(vc, sender: self)
    }
    
    func sendOrder_SMS_Email(order_item : ObjectOrder)
    {
        let my_user_id = user_manager.currentUserID()
        let partner_userid = conversation.userIDs.filter({$0 != my_user_id}).first
        if partner_userid == nil {
            ThemeService.showLoading(false)
            return
        }
        
        if partner_userid!.isValidEmail() == false { // if phone
            let partner_phone = partner_userid
            var confirm_link =
            "https://us-central1-modularproddata.cloudfunctions.net/AppApi/confirm/?conv_id=\(conversation.id)&owner_phone=\(partner_phone!)"
            confirm_link = confirm_link.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            user_manager.currentUserData() { cur_user in
                self.user_manager.find_user(phone_number : partner_phone!) {[weak self] user in
                    if user == nil {
                        self!.sms_service.sendSMS(partner_phone!, user: cur_user!, order: order_item, confirm_link: confirm_link) { result in
                            ThemeService.showLoading(false)
                            self!.showAlert(title: "Success", message: "SMS is sent to \(partner_phone!)", completion: {
                                self?.goMessage()
                            })
                        }
                    }
                    else
                    {
                        ThemeService.showLoading(false)
                        self?.goMessage()
                    }
                }
            }
        }
        else {
            let partner_email = partner_userid
            var confirm_link =
            "https://us-central1-modularproddata.cloudfunctions.net/AppApi/confirm/?conv_id=\(conversation.id)&owner_phone=\(partner_email!)"
            confirm_link = confirm_link.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            user_manager.currentUserData() { cur_user in
                self.user_manager.find_user_email(email: partner_email!){[weak self] user in
                    if user == nil {
                        self!.http_service.sendOrderEmail(email : partner_email!, user: cur_user!, order: order_item, confirm_link: confirm_link, status: "new") { result in
                            ThemeService.showLoading(false)
                            self!.showAlert(title: "Success", message: "Email is sent to \(partner_email!)", completion: {
                                self?.goMessage()
                            })
                        }
                    }
                    else
                    {
                        ThemeService.showLoading(false)
                        self?.goMessage()
                    }
                }
            }
        }
    }
}

//MARK: UITableView Delegate & DataSource
extension OrderSummaryViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if saved_products.isEmpty {
          return 1
        }
        return saved_products.count;
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard !saved_products.isEmpty else {
            return tableView.dequeueReusableCell(withIdentifier: "EmptyCell")!
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "productItemCell") as! productItemCell
        cell.set(saved_products[indexPath.row] as! ObjectProduct)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//
//        let vc: MessagesViewController = UIStoryboard.initial(storyboard: .messages)
//        vc.conversation = conversations[indexPath.row]
//        manager.markAsRead(conversations[indexPath.row])
//        show(vc, sender: self)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if saved_products.isEmpty {
          return tableView.bounds.height - 50 //header view height
        }
        return 50
    }
    
    
}

