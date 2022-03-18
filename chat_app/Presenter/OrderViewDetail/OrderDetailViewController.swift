import UIKit
import iOSDropDown
import FirebaseFirestore

class OrderDetailViewController: UIViewController , UITextFieldDelegate , UISearchBarDelegate    {

    //MARK: IBOutlets
    @IBOutlet weak var order_date: UITextField!
    @IBOutlet weak var productTable: UITableView!
    @IBOutlet weak var order_id_label: UILabel!
    @IBOutlet weak var order_comment_label: UILabel!
    @IBOutlet weak var order_cancel_btn: UIButton!
    @IBOutlet weak var order_save_btn: UIButton!
    
    //MARK: Private properties
    var orderData = ObjectOrder()
    var manager = OrderdataManager()
    var user_manager = UserManager()
    var msg_manager = MessageManager()
    var conversation = ObjectConversation()
    var message = ObjectMessage()
    var sms_service = SMSservice()
    var http_service = Httpservice()
    
    var order_ref_id = ""
    var edit_flag = true
    var flag = false
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchOrder(order_id: order_ref_id)
        self.productTable.delegate = self
        self.productTable.dataSource = self
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        fetchOrder(order_id: order_ref_id)
        if flag == true {
            order_cancel_btn.isHidden = true
            order_save_btn.isHidden = true
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
extension OrderDetailViewController {
    @IBAction func backBtnPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func onSave(_ sender: Any) {
        if(self.message.orderStatus == "Cancelled")
        {
            self.showAlert(title: "Warning", message: "You can not save cancelled order.", completion: nil)
            return
        }
        ThemeService.showLoading(true)
        manager.create_order(AppdataManager.sharedInstance.tmp_order_data) { result in
            if result == .failure {
                ThemeService.showLoading(false)
                self.showAlert(title: "Warning", message: "Error while saving the order", completion: nil)
            }
            else {
                // send changed order message
                var new_order_msg = self.message
                new_order_msg.id = ObjectMessage().id
                
                self.msg_manager.create(new_order_msg, conversation: self.conversation) {[weak self] response in
                    
                    if response == .failure {
                        ThemeService.showLoading(false)
                        self!.showAlert()
                        return
                    }
                    else
                    {
                        
                        let info_msg = ObjectMessage()
                        info_msg.contentType = .none
                        info_msg.ownerID = self!.user_manager.currentUserID()
                        info_msg.message = "We made changes to order \(AppdataManager.sharedInstance.tmp_order_data.id), please review and confirm"
                        
                        self!.msg_manager.create(info_msg, conversation: self!.conversation) {[weak self] response in
                        
                            if response == .failure {
                                ThemeService.showLoading(false)
                                self!.showAlert()
                                return
                            }
                            else{
                                self!.conversation.timestamp = Int(Date().timeIntervalSince1970)
                                self!.conversation.lastMessage = info_msg.message
                                self!.conversation.isRead[info_msg.ownerID!] = true
                                
                                ConversationManager().create(self!.conversation)
//                                ThemeService.showLoading(false)
                                self!.sendUpdateSMS(order_item: AppdataManager.sharedInstance.tmp_order_data)
                                
                            }
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func onCancelOrder(_ sender: Any) {
        if(self.message.orderStatus == "Cancelled")
        {
            self.showAlert(title: "Warning", message: "This order was cancelled already", completion: nil)
            return
        }
        ThemeService.showLoading(true)
        manager.cancel_order(orderData, message: message, conversation_id: conversation.id) { result in
            if result == .failure {
                ThemeService.showLoading(false)
                self.showAlert(title: "Warning", message: "Error while cancelling the order", completion: nil)
            }
            else {
                let info_msg = ObjectMessage()
                info_msg.contentType = .none
                info_msg.ownerID = self.user_manager.currentUserID()
                info_msg.message = "I canceled the order \(AppdataManager.sharedInstance.tmp_order_data.id), i no longer need it"
                
                self.msg_manager.create(info_msg, conversation: self.conversation) {[weak self] response in
                    if response == .failure {
                        ThemeService.showLoading(false)
                        self!.showAlert()
                        return
                    }
                    else{
                        self!.conversation.timestamp = Int(Date().timeIntervalSince1970)
                        self!.conversation.lastMessage = info_msg.message
                        self!.conversation.isRead[info_msg.ownerID!] = true
                        
                        ConversationManager().create(self!.conversation)
                        
                        self!.sendCancelSMS(order_item: AppdataManager.sharedInstance.tmp_order_data)
                    }
                }
            }
        }
    }
}

//MARK: Private methods
extension OrderDetailViewController {

    func fetchOrder(order_id : String) {
          manager.get_order(order_id) { result in
              self.order_id_label.text = "ORDER ID : " + result.id
              self.order_date.text = result.date
              self.order_comment_label.text = result.comment != nil && result.comment != "" ? result.comment : "N/A"
              self.orderData = result
              
            AppdataManager.sharedInstance.tmp_order_data = self.orderData
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "eee, MMM dd, yyyy"
            dateFormatter.timeZone = TimeZone.current
            dateFormatter.locale = Locale.current
            let date = dateFormatter.date(from: result.date!)
            if date != nil {
                if date! < Date() {
                    print("edit disabled")
                    self.order_cancel_btn.isEnabled = false
                    self.order_save_btn.isEnabled = false
                    self.edit_flag = false
                }
            }
            
            self.productTable.reloadData()
          }
    }

    func sendSMS(order_item : ObjectOrder)
    {
       let my_user_id = user_manager.currentUserID()
       let partner_userid = conversation.userIDs.filter({$0 != my_user_id}).first
       let partner_phone = partner_userid
       var confirm_link = "https://us-central1-modularproddata.cloudfunctions.net/AppApi/confirm/?conv_id=\(conversation.id)&owner_phone=\(partner_phone!)"
       confirm_link = confirm_link.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
       user_manager.currentUserData() { cur_user in
           self.user_manager.find_user(phone_number : partner_phone!) {[weak self] user in
               if user == nil {
                   self!.sms_service.sendSMS(partner_phone!, user: cur_user!, order: order_item, confirm_link: confirm_link) { result in
                       ThemeService.showLoading(false)
                       self!.showAlert(title: "Success", message: "SMS is sent to \(partner_phone!)", completion: {
                           self!.dismiss(animated: true, completion: nil)
                       })
                   }
               }
               else
               {
                   ThemeService.showLoading(false)
                   self!.dismiss(animated: true, completion: nil)
               }
           }
       }
    }
    
    func sendUpdateSMS(order_item : ObjectOrder)
    {
       let my_user_id = user_manager.currentUserID()
       let partner_userid = conversation.userIDs.filter({$0 != my_user_id}).first
        
        if partner_userid == nil {
            return
        }

        if partner_userid!.isValidEmail() == false { // if phone
            let partner_phone = partner_userid
            var confirm_link = "https://us-central1-modularproddata.cloudfunctions.net/AppApi/confirm/?conv_id=\(conversation.id)&owner_phone=\(partner_phone!)"
            confirm_link = confirm_link.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            user_manager.currentUserData() { cur_user in
                self.user_manager.find_user(phone_number : partner_phone!) {[weak self] user in
                    if user == nil {
                     self!.sms_service.sendUpdateSMS(partner_phone!, user: cur_user!, order: order_item, confirm_link: confirm_link) { result in
                            ThemeService.showLoading(false)
                            self!.showAlert(title: "Success", message: "SMS is sent to \(partner_phone!)", completion: {
                                self!.dismiss(animated: true, completion: nil)
                            })
                        }
                    }
                    else
                    {
                        ThemeService.showLoading(false)
                        self!.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
        else {
            let partner_email = partner_userid
            var confirm_link = "https://us-central1-modularproddata.cloudfunctions.net/AppApi/confirm/?conv_id=\(conversation.id)&owner_phone=\(partner_email!)"
            confirm_link = confirm_link.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            user_manager.currentUserData() { cur_user in
                self.user_manager.find_user_email(email: partner_email!){[weak self] user in
                    if user == nil {
                        self!.http_service.sendOrderEmail(email : partner_email!, user: cur_user!, order: order_item, confirm_link: confirm_link, status: "update") { result in
                            ThemeService.showLoading(false)
                            self!.showAlert(title: "Success", message: "Email is sent to \(partner_email!)", completion: {
                                self!.dismiss(animated: true, completion: nil)
                            })
                        }
                    }
                    else
                    {
                        ThemeService.showLoading(false)
                        self!.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    func sendCancelSMS(order_item : ObjectOrder)
    {
       let my_user_id = user_manager.currentUserID()
       let partner_userid = conversation.userIDs.filter({$0 != my_user_id}).first
        
        if partner_userid == nil {
            return
        }
        if partner_userid!.isValidEmail() == false { // if phone
            let partner_phone = partner_userid
            var confirm_link = "https://us-central1-modularproddata.cloudfunctions.net/AppApi/confirm/?conv_id=\(conversation.id)&owner_phone=\(partner_phone!)&cancel=true"
            confirm_link = confirm_link.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            user_manager.currentUserData() { cur_user in
                self.user_manager.find_user(phone_number : partner_phone!) {[weak self] user in
                    if user == nil {
                        self!.sms_service.sendCancelSMS(partner_phone!, user: cur_user!, order: order_item, confirm_link: confirm_link) { result in
                            ThemeService.showLoading(false)
                            self!.showAlert(title: "Success", message: "SMS is sent to \(partner_phone!)", completion: {
                                self!.dismiss(animated: true, completion: nil)
                            })
                        }
                    }
                    else
                    {
                        ThemeService.showLoading(false)
                        self!.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
        else {
            let partner_email = partner_userid
            var confirm_link = "https://us-central1-modularproddata.cloudfunctions.net/AppApi/confirm/?conv_id=\(conversation.id)&owner_phone=\(partner_email!)&cancel=true"
            confirm_link = confirm_link.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            user_manager.currentUserData() { cur_user in
                self.user_manager.find_user_email(email: partner_email!){[weak self] user in
                    if user == nil {
                        self!.http_service.sendOrderEmail(email : partner_email!, user: cur_user!, order: order_item, confirm_link: confirm_link, status: "cancel") { result in
                            ThemeService.showLoading(false)
                            self!.showAlert(title: "Success", message: "Email is sent to \(partner_email!)", completion: {
                                self!.dismiss(animated: true, completion: nil)
                            })
                        }
                    }
                    else
                    {
                        ThemeService.showLoading(false)
                        self!.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
    }
}

//MARK: UITableView Delegate & DataSource
extension OrderDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if orderData.products.isEmpty {
          return 1
        }
        
        return orderData.products.count;
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard !orderData.products.isEmpty else {
            return tableView.dequeueReusableCell(withIdentifier: "EmptyCell")!
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "productItemCell") as! ItemCell
        cell.conversation = conversation
        cell.order_ref_id = order_ref_id
        cell.set(orderData.products[indexPath.row] as! ObjectProduct, flag : flag, edit_flag : edit_flag)
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
        if orderData.products.isEmpty {
          return tableView.bounds.height - 65 //header view height
        }
        return 65
    }
}

