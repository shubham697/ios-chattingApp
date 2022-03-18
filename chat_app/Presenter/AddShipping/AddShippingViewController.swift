import UIKit

class AddShippingViewController: UIViewController {
  
  //MARK: IBOutlets
 
    @IBOutlet weak var company_name_tb: UITextField!
    @IBOutlet weak var street_address_tb: UITextField!
    @IBOutlet weak var state_drpdwn: DropDown!
    @IBOutlet weak var city_drpdwn: DropDown!
    @IBOutlet weak var zipcode_tb: UITextField!
    
    @IBOutlet var separatorViews: [UIView]!
    
    private let manager = UserManager()
    let service = StateCityService()
    
    var token_str = ""
    var user = ObjectUser()
    //MARK: Lifecycle
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        state_drpdwn.didSelect{(selectedText , index ,id) in
            self.service.get("https://www.universal-tutorial.com/api/cities/" + selectedText, token: self.token_str,  body: ["" : ""]) { results in
                for json_item in results {
                    self.city_drpdwn.optionArray.append(json_item["city_name"] as! String)
                }
            }
        }
        
        ThemeService.showLoading(true)
        service.get_token(){ token_result in
            if token_result["token"] as! String == "" {
                ThemeService.showLoading(false)
                return
            }
            else
            {
                self.token_str = token_result["token"] as! String
                print("token \(token_result["token"])")
                self.service.get("https://www.universal-tutorial.com/api/states/United States", token: token_result["token"] as! String,  body: ["" : ""]) { results in
                    ThemeService.showLoading(false)
                    for json_item in results {
                        self.state_drpdwn.optionArray.append(json_item["state_name"] as! String)
                    }
                }
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
         view.endEditing(true)
     }
}

//MARK: IBActions
extension AddShippingViewController {
    
    func sendSMS_EMAIL(phone_number : String){
        Httpservice().sendNewRegister(phone_number){ result_http in
            SMSservice().sendNewRegisterSMS(phone_number: phone_number) { result_sms in
                ThemeService.showLoading(false)
                print("register sms result : \(result_sms)")
                self.showAlert(title: "Success", message: "Someone from the Modular Product Group will be in touch with you soon.", completion: {
                //                self!.manager.currentUserData() {result in
                //                     print(result?.role)
                //                    let vc = UIStoryboard.initial(storyboard:
                //                        result?.role == "Customer" ?
                //                        .conversations : .supplier_dash)
                //                    vc.modalPresentationStyle = .fullScreen
                //                    self!.present(vc, animated: true)
                //                }
                    // go to login
                    let vc = UIStoryboard.initial(storyboard: .initial)
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true)
                })
            }
        }
    }
    
    @IBAction func onRegister(_ sender: Any) {
        guard let company_name = company_name_tb.text, let street_address = street_address_tb.text, let state = state_drpdwn.text, let city = city_drpdwn.text, let zipcode = zipcode_tb.text else {
          return
        }
        guard !company_name.isEmpty else {
          separatorViews.filter({$0.tag == 1}).first?.backgroundColor = .red
          return
        }
        guard !street_address.isEmpty else {
          separatorViews.filter({$0.tag == 2}).first?.backgroundColor = .red
          return
        }
        guard !state.isEmpty else {
          separatorViews.filter({$0.tag == 3}).first?.backgroundColor = .red
          return
        }
        guard !city.isEmpty else {
          separatorViews.filter({$0.tag == 4}).first?.backgroundColor = .red
          return
        }
        guard !zipcode.isEmpty else {
          separatorViews.filter({$0.tag == 5}).first?.backgroundColor = .red
          return
        }
       
        view.endEditing(true)
        
    
        user.company_name = company_name
        user.street_address = street_address
        user.state = state
        user.city = city
        user.zipcode = zipcode
        user.account_status = "New"
        
        ThemeService.showLoading(true)
        manager.update(user: user) {[weak self] response in
          
          switch response {
            case .failure:
                ThemeService.showLoading(false)
                self?.showAlert()
            case .success: self?.sendSMS_EMAIL(phone_number: self!.user.phone!)
          }
        }
    }
}

