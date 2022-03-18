
import UIKit

class MessagesViewController: UIViewController, KeyboardHandler {
  
  //MARK: IBOutlets
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var inputTextField: UITextField!
  @IBOutlet weak var expandButton: UIButton!
  @IBOutlet weak var backButton: UIButton!
  @IBOutlet weak var shoppingButton: UIButton!
    @IBOutlet weak var title_btn: UIButton!
    @IBOutlet weak var view_btn: UIButton!
    
  @IBOutlet weak var barBottomConstraint: NSLayoutConstraint!
  @IBOutlet weak var stackViewWidthConstraint: NSLayoutConstraint!
  @IBOutlet var actionButtons: [UIButton]!

  //MARK: Private properties
  private let manager = MessageManager()
  private let imageService = ImagePickerService()
  private var messages = [ObjectMessage]()
  private let user_manager = UserManager()
  
  //MARK: Public properties
  var conversation = ObjectConversation()
  var bottomInset: CGFloat {
    return view.safeAreaInsets.bottom + 50
  }
  
  //MARK: Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    addKeyboardObservers() {[weak self] state in
      guard state else { return }
      self?.tableView.scroll(to: .bottom, animated: true)
    }
    
//    tableView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
    
    fetchMessages()
    fetchUserName()
  }
//    @objc func hideKeyboard() {
//      view.endEditing(true)
//      //textField.resignFirstResponder()
//    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

    @IBAction func onViewCatalog(_ sender: Any) {
        guard let currentUserID = user_manager.currentUserID() else { return }
        guard let userID = conversation.userIDs.filter({$0 != currentUserID}).first else { return }
        
        user_manager.userData(for: userID) {[weak self] user in
            if user == nil { return }
            if user!.shared_catalog == true {
                let vc : CatalogManageViewController = UIStoryboard.initial(storyboard: .catalog_view)
                vc.modalPresentationStyle = .fullScreen
                vc.supplier_id = userID
                self!.present(vc, animated: true)
            }
            else {
                self!.showAlert(title: "Warning", message: "This Supplier has not yet shared their product catalog", completion: nil)
            }
        }
    }
    
}

//MARK: Private methods
extension MessagesViewController {
  
  private func fetchMessages() {
    manager.messages(for: conversation) {[weak self] messages in
       
      self?.messages = messages.sorted(by: {$0.uniqueCount < $1.uniqueCount})
      self?.tableView.reloadData()
      self?.tableView.scroll(to: .bottom, animated: true)
    }
  }
  
  private func send(_ message: ObjectMessage) {
    manager.create(message, conversation: conversation) {[weak self] response in
      guard let weakSelf = self else { return }
      if response == .failure {
        weakSelf.showAlert()
        return
      }
      weakSelf.conversation.timestamp = Int(Date().timeIntervalSince1970)
      switch message.contentType {
          case .none: weakSelf.conversation.lastMessage = message.message
          case .photo: weakSelf.conversation.lastMessage = "Attachment"
          case .location: weakSelf.conversation.lastMessage = "Location"
          default: break
      }
        if let currentUserID = self!.user_manager.currentUserID() {
        weakSelf.conversation.isRead[currentUserID] = true
      }
      ConversationManager().create(weakSelf.conversation)
    }
  }
  
  private func fetchUserName() {
    guard let currentUserID = user_manager.currentUserID() else { return }
    guard let userID = conversation.userIDs.filter({$0 != currentUserID}).first else { return }
    
    user_manager.currentUserData(){ cur_user in
        if cur_user != nil {
            if cur_user!.role == "TechSupport" {
                self.shoppingButton.isHidden = true
                self.view_btn.isHidden = true
            }
        }
    }
    user_manager.userData(for: userID) {[weak self] user in
        var name_label_txt = ""
        if user != nil {
            name_label_txt = (user!.name == nil ? "" : user!.name!) + "-" + (user!.company_name == nil ? "" : user!.company_name!)
            if user!.role == "TechSupport" {
                name_label_txt = "Technical Support"
                self!.shoppingButton.isHidden = true
            }
            if user!.role != "Supplier" {
                self!.view_btn.isHidden = true
            }
        }
        else {
            self!.view_btn.isHidden = true
            name_label_txt = (self!.conversation.contact_name == nil ? "" : self!.conversation.contact_name!) + "-" +
                (self!.conversation.company_name == nil ? "" :  self!.conversation.company_name!)
        }
        self?.title_btn.setTitle(name_label_txt, for: [])
    }
  }
  
  private func showActionButtons(_ status: Bool) {
    guard !status else {
      stackViewWidthConstraint.constant = 74
      UIView.animate(withDuration: 0.3) {
        self.expandButton.isHidden = true
        self.expandButton.alpha = 0
        self.actionButtons.forEach({$0.isHidden = false})
        self.view.layoutIfNeeded()
      }
      return
    }
    guard stackViewWidthConstraint.constant != 32 else { return }
    stackViewWidthConstraint.constant = 32
    UIView.animate(withDuration: 0.3) {
      self.expandButton.isHidden = false
      self.expandButton.alpha = 1
      self.actionButtons.forEach({$0.isHidden = true})
      self.view.layoutIfNeeded()
    }
  }
}

//MARK: IBActions
extension MessagesViewController {
  
  @IBAction func sendMessagePressed(_ sender: Any) {
    guard let text = inputTextField.text, !text.isEmpty else { return }
    let message = ObjectMessage()
    message.message = text
    message.ownerID = user_manager.currentUserID()
    inputTextField.text = nil
    showActionButtons(false)
    send(message)
  }
  
  @IBAction func sendImagePressed(_ sender: UIButton) {
    imageService.pickImage(from: self, allowEditing: false, source: sender.tag == 0 ? .photoLibrary : .camera) {[weak self] image in
      let message = ObjectMessage()
      message.contentType = .photo
      message.profilePic = image
        message.ownerID = self!.user_manager.currentUserID()
      self?.send(message)
      self?.inputTextField.text = nil
      self?.showActionButtons(false)
    }
  }
  
  
  @IBAction func expandItemsPressed(_ sender: UIButton) {
    showActionButtons(true)
  }
    
  @IBAction func backButtonPressed(_ sender: UIButton) {
//    self.dismiss(animated: true, completion: nil)
//    self.navigationController?.popViewController(animated: true)
    user_manager.currentUserData() {result in
        print(result?.role)
        
        let vc : ConversationsViewController = UIStoryboard.initial(storyboard: .conversations)
        vc.modalPresentationStyle = .fullScreen
        
        if result?.role == "Supplier" {
            vc.profile_btn_hidden_flag = true
        }
        self.present(vc, animated: true)
    }
  }
    
    @IBAction func onTitleClicked(_ sender: Any) {
        let vc : UserInfoViewController = UIStoryboard.initial(storyboard: .user_info)
        vc.conversation = conversation
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
  @IBAction func shoppingButtonPressed(_ sender: UIButton) {
        print("ok")
        AppdataManager.sharedInstance.orderItem = ObjectOrder()
        let vc : OrderViewController = UIStoryboard.initial(storyboard: .order)
        vc.conversation = conversation
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
  }
}

//MARK: UITableView Delegate & DataSource
extension MessagesViewController: UITableViewDelegate, UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return messages.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let message = messages[indexPath.row]
    if message.contentType == .none {
        let cell = tableView.dequeueReusableCell(withIdentifier: message.ownerID == user_manager.currentUserID() || message.ownerID == user_manager.currentUserEmail() ? "MessageTableViewCell" : "UserMessageTableViewCell") as! MessageTableViewCell
      cell.set(message)
      return cell
    }
    else if message.contentType == .product && message.ownerID == user_manager.currentUserID() && message.orderStatus == "Active"{
        let cell = tableView.dequeueReusableCell(withIdentifier: "my_order_message") as! MyMessageOrderTableViewCell
        cell.set(message)
        cell.conversation = conversation
        cell.msgVc = self
        return cell
    }
    else if message.contentType == .product && message.ownerID == user_manager.currentUserID() && message.orderStatus == "Cancelled"{
//        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageTableViewCell") as! MessageTableViewCell
//        message.message = "I canceled the order \(message.orderRefString!), i no longer need it"
//        cell.set(message)
//        return cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "my_order_message") as! MyMessageOrderTableViewCell
        cell.set(message)
        cell.conversation = conversation
        cell.msgVc = self
        return cell
    }
    else if message.contentType == .product && message.ownerID != user_manager.currentUserID()  && message.orderStatus == "Active"{
        let cell = tableView.dequeueReusableCell(withIdentifier: "order_message") as! MessageOrderTableViewCell
        cell.set(message)
        cell.conversation = conversation
        cell.msgVc = self
        return cell
    }
    else if message.contentType == .product && message.ownerID != user_manager.currentUserID() && message.orderStatus == "Cancelled"{
//        let cell = tableView.dequeueReusableCell(withIdentifier: "UserMessageTableViewCell") as! MessageTableViewCell
//        message.message = "I canceled the order \(message.orderRefString!), i no longer need it"
//        cell.set(message)
//        return cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "order_message") as! MessageOrderTableViewCell
        cell.set(message)
        cell.conversation = conversation
        cell.msgVc = self
        return cell
    }
    
    let cell = tableView.dequeueReusableCell(withIdentifier: message.ownerID == user_manager.currentUserID() ? "MessageAttachmentTableViewCell" : "UserMessageAttachmentTableViewCell") as! MessageAttachmentTableViewCell
    cell.delegate = self
    cell.set(message)
    return cell
  }
  
  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    guard tableView.isDragging else { return }
    cell.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
    UIView.animate(withDuration: 0.3, animations: {
      cell.transform = CGAffineTransform.identity
    })
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let message = messages[indexPath.row]
    switch message.contentType {
    case .location:
      let vc: MapPreviewController = UIStoryboard.controller(storyboard: .previews)
      vc.locationString = message.content
      self.present(vc, animated: true)
    case .photo:
      let vc: ImagePreviewController = UIStoryboard.controller(storyboard: .previews)
      vc.imageURLString = message.profilePicLink
      self.present(vc, animated: true)
    default: break
    }
  }
}

//MARK: UItextField Delegate
extension MessagesViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    return textField.resignFirstResponder()
  }
  
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    showActionButtons(false)
    return true
  }
}

//MARK: MessageTableViewCellDelegate Delegate
extension MessagesViewController: MessageTableViewCellDelegate {
  
  func messageTableViewCellUpdate() {
    tableView.beginUpdates()
    tableView.endUpdates()
  }
}

