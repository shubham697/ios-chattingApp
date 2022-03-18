import UIKit

class ConversationsViewController: UIViewController {
  
  //MARK: IBOutlets
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profile_leading_space: NSLayoutConstraint!
    @IBOutlet weak var profile_img_leading_space: NSLayoutConstraint!
    @IBOutlet weak var profile_btn: UIButton!
    @IBOutlet weak var add_contact_btn: UIButton!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
    return .default
  }
  
  //MARK: Private properties
  private var conversations = [ObjectConversation]()
  private let manager = ConversationManager()
  private let userManager = UserManager()
  private var currentUser: ObjectUser?
  
  var profile_btn_hidden_flag = false
    
  //MARK: Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    fetchProfile()
    
    profile_btn.isHidden = profile_btn_hidden_flag
    profileImageView.isHidden = profile_btn_hidden_flag
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(true)
    fetchProfile()
    
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
extension ConversationsViewController {
  @IBAction func goBack(_ sender: Any) {
//    self.dismiss(animated: true, completion: nil)
    let vc = UIStoryboard.initial(storyboard: .supplier_dash)
    vc.modalPresentationStyle = .fullScreen
    self.show(vc, sender: sender)
   }
    
  @IBAction func profilePressed(_ sender: Any) {
    let vc: ProfileViewController = UIStoryboard.initial(storyboard: .profile)
    vc.delegate = self
    vc.user = currentUser
    vc.logout_btn_show_flag = true
    present(vc, animated: false)
  }
  
  @IBAction func composePressed(_ sender: Any) {
//    let vc: ContactsPreviewController = UIStoryboard.controller(storyboard: .previews)
//    vc.delegate = self
//    present(vc, animated: true, completion: nil)
    let alert = UIAlertController(title: "Add a contact", message: "Enter phone number", preferredStyle: .alert)

    alert.addTextField { (textField) in
        textField.borderColor = UIColor.lightGray
        textField.borderWidth = 1
        textField.borderStyle = .roundedRect
        textField.placeholder = "Phone number or email address"
    }
    alert.addTextField { (textField) in
        textField.borderColor = UIColor.lightGray
        textField.borderWidth = 1
        textField.borderStyle = .roundedRect
        textField.placeholder = "Contact Name"
    }
    alert.addTextField { (textField) in
        textField.borderColor = UIColor.lightGray
        textField.borderWidth = 1
        textField.borderStyle = .roundedRect
        textField.placeholder = "Company Name"
    }
    alert.view.tintColor = UIColor.init(red: 0.33, green: 0.33, blue: 0.37, alpha: 1)
    alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { [weak alert] (_) in
        let phone_or_email = alert?.textFields![0].text
        let contact_name = alert?.textFields![1].text
        let company_name = alert?.textFields![2].text
        if phone_or_email == "" || contact_name == "" || company_name == "" {
            self.showAlert(title: "Warning!", message: "Please fill out all the fields", completion: nil)
            return
        }
        if phone_or_email!.isValidEmail() == true {
            self.add_contact_email(email: phone_or_email!, contact_name: contact_name!, company_name: company_name!)
        }
        else {
            self.add_contact(phone_number: phone_or_email!, contact_name: contact_name!, company_name: company_name!)
        }
        
    }))
    alert.addAction(UIAlertAction(title: "Close", style: .default, handler: { [weak alert] (_) in
        alert?.dismiss(animated: false)
    }))
    self.present(alert, animated: true, completion: nil)
  }
}

//MARK: Private methods
extension ConversationsViewController {
  
  func fetchConversations() {
    
    manager.currentConversations {[weak self] conversations in
      self?.conversations = conversations.sorted(by: {$0.timestamp > $1.timestamp})
//        conversations[0].
        print("fetch conversation \(conversations.count)")
        self?.tableView.reloadData()
    }
  }
  
  func fetchProfile() {
    userManager.currentUserData {[weak self] user in
 
        self?.currentUser = user
        if user?.role == "Customer" {
            self?.backBtn.isHidden = true
            self?.profile_leading_space.constant = -20
            self?.profile_img_leading_space.constant = -20
        }
        if user?.role == "TechSupport" {
            self?.backBtn.isHidden = true
            self?.profile_leading_space.constant = -20
            self?.profile_img_leading_space.constant = -20
//            self?.add_contact_btn.isHidden = true
        }
        if let urlString = user?.profilePicLink {
            self?.profileImageView.setImage(url: URL(string: urlString))
        }
        self!.fetchConversations()
    }
  }

    func del_contact(conv_del: ObjectConversation)
    {
        ThemeService.showLoading(true)
        manager.delete_conversation(conv_del) { result in
            ThemeService.showLoading(false)
            if result == .failure {
                self.showAlert()
            }
            else {
                self.tableView.reloadData()
            }
        }
    }
  
    func add_contact (phone_number : String, contact_name : String, company_name : String) {
        userManager.find_user(phone_number : phone_number) {[weak self] user in
            if user == nil {
//                self?.showAlert(title: "Faild", message: "We could not find that phone number.", completion: {})
                let currentID = self!.userManager.currentUserID()
                let conversation = ObjectConversation()
                conversation.userIDs.append(contentsOf: [currentID!, phone_number])
                conversation.isRead = [currentID!: true, phone_number : true]
                conversation.timestamp = Int(Date().timeIntervalSince1970)
                conversation.lastMessage = ""
                conversation.total_msg_count = 0
                conversation.contact_name = contact_name
                conversation.company_name = company_name
                
                self!.manager.create(conversation) { result in
                    print("created")
                }
            }
            else
            {
                if let conversation = self!.conversations.filter({$0.userIDs.contains(user!.id)}).first {
                    self?.showAlert(title: "Faild", message: "This contact already exists.", completion: {})
                    return
                }
                else
                {
                    let currentID = self!.userManager.currentUserID()
                    if currentID != user!.id {
                        let conversation = ObjectConversation()
                        conversation.userIDs.append(contentsOf: [currentID!, user!.id])
                        conversation.isRead = [currentID!: true, user!.id: true]
                        conversation.timestamp = Int(Date().timeIntervalSince1970)
                        conversation.lastMessage = ""
                        conversation.total_msg_count = 0
                        conversation.contact_name = contact_name
                        conversation.company_name = company_name
                        self!.manager.create(conversation){ result in
                            print("created")
                        }
                    }
                    else {
                        self?.showAlert(title: "Faild", message: "You can not add yourself.", completion: {})
                    }
                }
            }
        }
    }
    
    func add_contact_email (email : String, contact_name : String, company_name : String) {
        userManager.find_user_email(email : email) {[weak self] user in
            if user == nil {
//                self?.showAlert(title: "Faild", message: "We could not find that phone number.", completion: {})
                let currentID = self!.userManager.currentUserID()
                let conversation = ObjectConversation()
                conversation.userIDs.append(contentsOf: [currentID!, email])
                conversation.isRead = [currentID!: true, email : true]
                conversation.timestamp = Int(Date().timeIntervalSince1970)
                conversation.lastMessage = ""
                conversation.total_msg_count = 0
                conversation.contact_name = contact_name
                conversation.company_name = company_name
                
                self!.manager.create(conversation) { result in
                    print("created")
                }
            }
            else
            {
                if let conversation = self!.conversations.filter({$0.userIDs.contains(user!.id)}).first {
                    self?.showAlert(title: "Faild", message: "This contact already exists.", completion: {})
                    return
                }
                else
                {
                    let currentID = self!.userManager.currentUserID()
                    if currentID != user!.id {
                        let conversation = ObjectConversation()
                        conversation.userIDs.append(contentsOf: [currentID!, user!.id])
                        conversation.isRead = [currentID!: true, user!.id: true]
                        conversation.timestamp = Int(Date().timeIntervalSince1970)
                        conversation.lastMessage = ""
                        conversation.total_msg_count = 0
                        conversation.contact_name = contact_name
                        conversation.company_name = company_name
                        self!.manager.create(conversation){ result in
                            print("created")
                        }
                    }
                    else {
                        self?.showAlert(title: "Faild", message: "You can not add yourself.", completion: {})
                    }
                }
            }
        }
    }
}

//MARK: UITableView Delegate & DataSource
extension ConversationsViewController: UITableViewDelegate, UITableViewDataSource {

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if conversations.isEmpty {
      return 1
    }
    return conversations.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    print("current user \(currentUser)")
    guard !conversations.isEmpty else {
      return tableView.dequeueReusableCell(withIdentifier: "EmptyCell")!
    }
    if currentUser == nil {
        return tableView.dequeueReusableCell(withIdentifier: "EmptyCell")!
    }
    let cell = tableView.dequeueReusableCell(withIdentifier: ConversationCell.className) as! ConversationCell
    cell.userID = currentUser!.id
    cell.set(conversations[indexPath.row])
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if conversations.isEmpty {
      composePressed(self)
      return
    }
    let vc: MessagesViewController = UIStoryboard.initial(storyboard: .messages)
    vc.modalPresentationStyle = .fullScreen
    vc.conversation = conversations[indexPath.row]
    manager.markAsRead(conversations[indexPath.row])
    show(vc, sender: self)
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    if conversations.isEmpty {
      return tableView.bounds.height - 50 //header view height
    }
    return 80
  }
  

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
            self.isEditing = false
            
            let conv_name = (self.conversations[indexPath.row].contact_name == nil ? "" : self.conversations[indexPath.row].contact_name!) + "-" + (self.conversations[indexPath.row].company_name == nil ? "" : self.conversations[indexPath.row].company_name!)
            let msg = "Are you sure you want to delete this contact : \(conv_name), Yes or No?"
            let alert = UIAlertController(title: "Warning", message: msg, preferredStyle: .alert)
            alert.view.tintColor = UIColor.init(red: 0.33, green: 0.33, blue: 0.37, alpha: 1)
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { [weak alert] (_) in
                self.del_contact(conv_del: self.conversations[indexPath.row])
            }))
            alert.addAction(UIAlertAction(title: "No", style: .default, handler: { [weak alert] (_) in
                alert?.dismiss(animated: false)
            }))
            self.present(alert, animated: true, completion: nil)
        }
        delete.backgroundColor = UIColor.lightGray

//        let favorite = UITableViewRowAction(style: .normal, title: "Favorite") { action, index in
//            //self.isEditing = false
//            print("favorite button tapped")
//        }
//        favorite.backgroundColor = UIColor.orange
//
//        let share = UITableViewRowAction(style: .normal, title: "Share") { action, index in
//            //self.isEditing = false
//            print("share button tapped")
//        }
//        share.backgroundColor = UIColor.blue

//        return [share, favorite, more]
        return [delete]
    }
}

//MARK: ProfileViewController Delegate
extension ConversationsViewController: ProfileViewControllerDelegate {
  func profileViewControllerDidLogOut() {
    userManager.logout()
    navigationController?.dismiss(animated: true)
    let vc: AuthViewController = UIStoryboard.initial(storyboard: .auth)
    vc.modalPresentationStyle = .fullScreen
    show(vc, sender: self)
  }
}

//MARK: ContactsPreviewController Delegate
extension ConversationsViewController: ContactsPreviewControllerDelegate {
  func contactsPreviewController(didSelect user: ObjectUser) {
    guard let currentID = userManager.currentUserID() else { return }
    let vc: MessagesViewController = UIStoryboard.initial(storyboard: .messages)
    vc.navigationController?.isNavigationBarHidden = true
    vc.modalPresentationStyle = .fullScreen
    if let conversation = conversations.filter({$0.userIDs.contains(user.id)}).first {
      vc.conversation = conversation
      show(vc, sender: self)
      return
    }
    let conversation = ObjectConversation()
    conversation.userIDs.append(contentsOf: [currentID, user.id])
    conversation.isRead = [currentID: true, user.id: true]
    vc.conversation = conversation
    show(vc, sender: self)
  }
}

