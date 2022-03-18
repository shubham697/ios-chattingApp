import UIKit

class LoginViewController: UIViewController {
  
  //MARK: IBOutlets
  @IBOutlet weak var loginPhoneTextField: UITextField!
  @IBOutlet var separatorViews: [UIView]!
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }

  //MARK: Private properties
  private var selectedImage: UIImage?
  private let manager = UserManager()
  private let imageService = ImagePickerService()
  
  //MARK: Lifecycle
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
  }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
         view.endEditing(true)
     }
    
    @IBAction func goback(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

//MARK: IBActions
extension LoginViewController {
  
  @IBAction func login(_ sender: Any) {
    guard let phone = loginPhoneTextField.text else {
      return
    }
    guard !phone.isEmpty else {
      separatorViews.filter({$0.tag == 0}).first?.backgroundColor = .red
      return
    }
    
    view.endEditing(true)
    
    ThemeService.showLoading(true)
    manager.find_user(phone_number: phone) { found_user in
        if found_user == nil {
            ThemeService.showLoading(false)
            self.showAlert(title: "Warning!", message: "This number does not exist, please register first", completion: nil)
        }
        else {
            if found_user!.account_status?.lowercased() == "new" {
                ThemeService.showLoading(false)
                self.showAlert(title: "Warning!", message: "Someone from the Modular Product Group will be in touch with you soon", completion: nil)
            }
            else if found_user!.account_status?.lowercased() == "active" {
                let random_verification_code = Int.random(in: 1000 ..< 10000).description
                print("random_verification_code: \(random_verification_code)")
                SMSservice().sendLoginPhoneVerifySMS(to: phone, verify_code: random_verification_code) { result in
                    ThemeService.showLoading(false)
                    let alert = UIAlertController(title: "Phone Verify", message: "Enter verification code from SMS", preferredStyle: .alert)

                    alert.addTextField { (textField) in
//                        textField.borderColor = UIColor.lightGray
//                        textField.borderWidth = 1
//                        textField.borderStyle = .roundedRect
                        textField.placeholder = "Verification Code"
                    }
                    alert.view.tintColor = UIColor.init(red: 0.33, green: 0.33, blue: 0.37, alpha: 1)
                    alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { [weak alert] (_) in
                        let phone_verification_code = alert?.textFields![0].text
                        if phone_verification_code != random_verification_code {
                            self.showAlert(title: "Warning!", message: "Verification Code mismatched! Please retry.", completion: nil)
                            return
                        }
                        else {
                            UserDefaults.standard.set(phone, forKey: "user_phone")
                            UserDefaults.standard.set(found_user!.email, forKey: "user_email")
                            self.dismiss(animated: true, completion: nil)
                        }
                    }))
                    alert.addAction(UIAlertAction(title: "Close", style: .default, handler: { [weak alert] (_) in
                        alert?.dismiss(animated: false)
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
            }
            else {
                ThemeService.showLoading(false)
                self.showAlert(title: "Warning!", message: "Your account status is inactive", completion: nil)
            }
        }
    }
  }
}

//MARK: Private methods
extension LoginViewController {

}

//MARK: UITextField Delegate
extension LoginViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    return textField.resignFirstResponder()
  }
  
  func textFieldDidBeginEditing(_ textField: UITextField) {
    separatorViews.forEach({$0.backgroundColor = .darkGray})
  }
}
