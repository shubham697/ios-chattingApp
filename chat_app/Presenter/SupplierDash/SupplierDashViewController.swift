import UIKit
import Alamofire


class SupplierDashViewController: UIViewController {

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    @IBOutlet weak var profile_imgview: UIImageView!
    @IBOutlet weak var company_name: UILabel!
    
    let user_manager = UserManager()
    var currentUser = ObjectUser()
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.setNavigationBarHidden(true, animated: true)
        user_manager.currentUserData() {result in
            if result == nil {
                return
            }
            self.currentUser = result!
            self.company_name.text = result!.company_name
            
            if let urlString = result?.profilePicLink {
              self.profile_imgview.setImage(url: URL(string: urlString))
            }
        }
        
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
         view.endEditing(true)
     }
    
    @IBAction func onClickOrders(_ sender: Any) {
        let vc: ConversationsViewController = UIStoryboard.initial(storyboard: .conversations)
        vc.modalPresentationStyle = .fullScreen
        vc.profile_btn_hidden_flag = true
        self.present(vc, animated: true)
    }
    
    @IBAction func onClickProducts(_ sender: Any) {
        let vc = UIStoryboard.initial(storyboard: .product_view)
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
    
    @IBAction func onLogout(_ sender: Any) {
        if user_manager.logout() == true {
        //            self.dismiss(animated: false, completion: {
        //                  self.delegate?.profileViewControllerDidLogOut()
        //                })
            let vc = UIStoryboard.initial(storyboard:  .initial)
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true)
        }
    }
    
    @IBAction func onClickReport(_ sender: Any) {
//        let accountSID = "ACa2fe8aedf382aa23d78b1e4d96e16f11"
//         let authToken = "83091c52cc70bb51e82b255ce281171e"
//
//            let url = "https://api.twilio.com/2010-04-01/Accounts/\(accountSID)/Messages"
//            let parameters =
//                ["From": "13342068961", "To": "",
//                 "Body": "You received a new order from %0a \"Customer Name\" " + "%0a%0a%0a" +
//                    "Contact person : 13342068961 %0a" +
//                    "Delivery address : 6246 North western Avenue chicago 6056 %0a%0a" +
//                    "Delivery notes : Film shum %0a" +
//                    "Requested delivery date : Thursday October adfas %0a%0a" +
//                    "1 Contact person (11232) %0a" +
//                    "1 Contact person (11232) %0a" +
//                    "1 Contact person (11232) %0a" +
//                    "1 Contact person (11232) %0a" +
//                    "%0a Total ordered products : 5 %0a" +
//                    "%0a Confirm the order by clicking this link: %0a" +
//                    "url https://www.google.com/ %0a" +
//                    "The Modular Product Group %0a"
//                ]
//
//        AF.request(url, method: .post, parameters: parameters)
//              .authenticate(username: accountSID, password: authToken)
//              .responseJSON { response in
//                print("sms \(response)")
//                debugPrint(response)
//            }
        
    }
    
    @IBAction func onProfileChange(_ sender: Any) {
        let vc: ProfileViewController = UIStoryboard.initial(storyboard: .profile)
        vc.user = currentUser
        vc.logout_btn_show_flag = false
        present(vc, animated: false)
    }
    
}
