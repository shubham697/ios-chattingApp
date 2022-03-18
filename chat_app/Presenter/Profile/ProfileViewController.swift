import UIKit

protocol ProfileViewControllerDelegate: class {
  func profileViewControllerDidLogOut()
}

class ProfileViewController: UIViewController {
  
  //MARK: IBOutlets
  @IBOutlet weak var profileImageView: UIImageView!
  @IBOutlet weak var profileNameTextField: UITextField!
  @IBOutlet weak var profileEmailTextField: UITextField!
  @IBOutlet weak var profilePhoneTextField: UITextField!
  @IBOutlet var separatorViews: [UIView]!
    @IBOutlet weak var log_out_btn: UIButton!
    
  //MARK: Private properties
  private var selectedImage: UIImage?
  private let manager = UserManager()
  private let imageService = ImagePickerService()

  //MARK: Public properties
  var user: ObjectUser?
  var logout_btn_show_flag = true
  var delegate: ProfileViewControllerDelegate?
    
  //MARK: Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    profileNameTextField.text = user?.name
    profileEmailTextField.text = user?.email
    profilePhoneTextField.text = user?.phone
    if let urlString = user?.profilePicLink {
      profileImageView.setImage(url: URL(string: urlString))
    }
    log_out_btn.isHidden = logout_btn_show_flag ? false : true
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    profileNameTextField.text = user?.name
    profileEmailTextField.text = user?.email
    profilePhoneTextField.text = user?.phone
    if let urlString = user?.profilePicLink {
      profileImageView.setImage(url: URL(string: urlString))
    }
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    profileImageView.cornerRadius = profileImageView.bounds.width / 2
  }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    modalPresentationStyle = .overFullScreen
  }
}

//MARK: IBActions
extension ProfileViewController {
  
  @IBAction func closePressed(_ sender: Any) {
    UIView.animate(withDuration: 0.3, animations: {
     
      self.view.layoutIfNeeded()
    }) { _ in
      self.dismiss(animated: false, completion: nil)
    }
  }
  
  @IBAction func logOutPressed(_ sender: Any) {
    
    UIView.animate(withDuration: 0.3, animations: {
     
      self.view.layoutIfNeeded()
    }) { _ in
        
        if self.manager.logout() == true {
//            self.dismiss(animated: false, completion: {
//                  self.delegate?.profileViewControllerDidLogOut()
//                })
            let vc = UIStoryboard.initial(storyboard:  .initial)
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true)
        }
        else {
        }
    }
  }
    

    @IBAction func update_profile(_ sender: Any) {
      guard let name = profileNameTextField.text, let email = profileEmailTextField.text, let phone = profilePhoneTextField.text else {
        return
      }
      guard !name.isEmpty else {
        separatorViews.filter({$0.tag == 11}).first?.backgroundColor = .red
        return
      }
        guard !phone.isEmpty else {
               separatorViews.filter({$0.tag == 12}).first?.backgroundColor = .red
               return
             }
        
      guard email.isValidEmail() else {
        separatorViews.filter({$0.tag == 13}).first?.backgroundColor = .red
        return
      }
//      guard phone.count > 5 else {
//        separatorViews.filter({$0.tag == 4}).first?.backgroundColor = .red
//        return
//      }
      view.endEditing(true)
        
      user!.name = name
      user!.email = email
      user!.phone = phone
      user!.phone_email = phone + "@gmail.com"
      user!.profilePic = selectedImage
      ThemeService.showLoading(true)
        manager.update(user: user!) {[weak self] response in
            ThemeService.showLoading(false)
            switch response {
              case .failure: self?.showAlert()
              case .success: self?.showAlert(title: "Success", message: "Your profile is updated successfuly.", completion: {
            })
        }
      }
    }
    
    @IBAction func profileImage(_ sender: Any) {
      imageService.pickImage(from: self) {[weak self] image in
        self?.profileImageView.image = image
        self?.selectedImage = image
      }
    }
}

//MARK: UItextField Delegate
extension ProfileViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    return textField.resignFirstResponder()
  }
//
//  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//    return true
//  }
}
