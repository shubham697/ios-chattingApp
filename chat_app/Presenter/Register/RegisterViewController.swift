import UIKit

class RegisterViewController: UIViewController {
  
  //MARK: IBOutlets
  @IBOutlet weak var registerImageView: UIImageView!
  @IBOutlet weak var registerNameTextField: UITextField!
  @IBOutlet weak var registerPhoneTextField: UITextField!
  @IBOutlet weak var registerEmailTextField: UITextField!
    @IBOutlet weak var registerRole: DropDown!
    @IBOutlet var separatorViews: [UIView]!
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }

  //MARK: Private properties
  private var selectedImage: UIImage?
  private let manager = UserManager()
  private let http_service = Httpservice()
  private let imageService = ImagePickerService()
  
  //MARK: Lifecycle
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    registerRole.text = "Customer"
    registerRole.optionArray = ["Customer", "Supplier"]
    registerRole.didSelect{(selectedText , index ,id) in
    }

  }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
         view.endEditing(true)
     }
    
    @IBAction func goback(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

//MARK: IBActions
extension RegisterViewController {

  @IBAction func register(_ sender: Any) {
    guard let name = registerNameTextField.text, let phone = registerPhoneTextField.text, let email = registerEmailTextField.text else {
      return
    }
    guard !name.isEmpty else {
      separatorViews.filter({$0.tag == 22}).first?.backgroundColor = .red
      return
    }
    guard !phone.isEmpty else {
      separatorViews.filter({$0.tag == 23}).first?.backgroundColor = .red
      return
    }
    guard email.isValidEmail() else {
      separatorViews.filter({$0.tag == 24}).first?.backgroundColor = .red
      return
    }

    view.endEditing(true)
    let user = ObjectUser()
    user.id = phone
    user.name = name
    user.phone = phone
    user.phone_email = phone + "@gmail.com"
    user.email = email
    user.profilePic = selectedImage
    user.role = registerRole.text
    
    ThemeService.showLoading(true)
    manager.find_user(phone_number: phone){ found_user in
        print("=============")
        if found_user != nil {
            ThemeService.showLoading(false)
            self.showAlert(title: "Warning!", message: "This number is already registered, please log in", completion: nil)
        }
        else {
            self.manager.update(user: user) {[weak self] response in
              switch response {
                case .failure:
                    ThemeService.showLoading(false)
                    self!.showAlert()
                case .success:
                    self?.updateConversations(user: user)
              }
            }
        }
    }
  }

  @IBAction func profileImage(_ sender: Any) {
    imageService.pickImage(from: self) {[weak self] image in
      self?.registerImageView.image = image
      self?.selectedImage = image
    }
  }
    
    func updateConversations(user : ObjectUser)
    {
        http_service.updateConversations(user.email!, phone: user.phone!) { result in
            ThemeService.showLoading(false)
            
            let vc = UIStoryboard.initial(storyboard:  .add_shipping) as! AddShippingViewController
            vc.user = user
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true)
            //self?.dismiss(animated: true, completion: nil)
        }
    }
}
