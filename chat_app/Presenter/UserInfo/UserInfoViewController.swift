import UIKit



class UserInfoViewController: UIViewController {
  
  //MARK: IBOutlets
  @IBOutlet weak var profileImageView: UIImageView!
  @IBOutlet weak var profileNameTextField: UITextField!
    @IBOutlet weak var profileCompanyTextField: UITextField!
    @IBOutlet weak var profileEmailTextField: UITextField!
  @IBOutlet weak var profilePhoneTextField: UITextField!
  @IBOutlet var separatorViews: [UIView]!
    
  //MARK: Private properties
  private var selectedImage: UIImage?
  private let manager = UserManager()
  private let imageService = ImagePickerService()

  //MARK: Public properties
    var conversation : ObjectConversation?
    
  //MARK: Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    fetchUserInfo()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    profileImageView.cornerRadius = profileImageView.bounds.width / 2
  }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
  
    private func fetchUserInfo() {
        if conversation == nil {
            return
        }
        guard let currentUserID = manager.currentUserID() else { return }
        guard let userID = conversation!.userIDs.filter({$0 != currentUserID}).first else { return }

        manager.userData(for: userID) {[weak self] user in
           if user != nil {
            self!.profileNameTextField.text = user?.name
            self!.profileCompanyTextField.text = user?.company_name
               self!.profileEmailTextField.text = user?.email
               self!.profilePhoneTextField.text = user?.phone
               if let urlString = user?.profilePicLink {
                 self!.profileImageView.setImage(url: URL(string: urlString))
               }
           }
        }
    }
}

//MARK: IBActions
extension UserInfoViewController {
  
  @IBAction func closePressed(_ sender: Any) {
    UIView.animate(withDuration: 0.3, animations: {
     
      self.view.layoutIfNeeded()
    }) { _ in
      self.dismiss(animated: false, completion: nil)
    }
  }
  
}

//MARK: UItextField Delegate
extension UserInfoViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    return textField.resignFirstResponder()
  }
}
