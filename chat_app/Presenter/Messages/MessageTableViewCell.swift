import UIKit

protocol MessageTableViewCellDelegate: class {
  func messageTableViewCellUpdate()
}

class MessageTableViewCell: UITableViewCell {
  
  @IBOutlet weak var profilePic: UIImageView?
  @IBOutlet weak var messageTextView: UITextView?
    @IBOutlet weak var timestamp: UILabel!
    
  func set(_ message: ObjectMessage) {
    messageTextView?.text = message.message
    
    guard let tmlabel = timestamp else { return }
    
    let date = NSDate(timeIntervalSince1970: TimeInterval(message.timestamp))
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    tmlabel.text = dateFormatter.string(from: date as Date)
    
    guard let imageView = profilePic else { return }
    guard let userID = message.ownerID else { return }
    ProfileManager.shared.userData(id: userID) { user in
      guard let urlString = user?.profilePicLink else { return }
      imageView.setImage(url: URL(string: urlString))
    }
  }
}

class MessageAttachmentTableViewCell: MessageTableViewCell {
  
    @IBOutlet weak var tmstamp: UILabel!
    @IBOutlet weak var attachmentImageView: UIImageView!
  @IBOutlet weak var attachmentImageViewHeightConstraint: NSLayoutConstraint!
  @IBOutlet weak var attachmentImageViewWidthConstraint: NSLayoutConstraint!
  weak var delegate: MessageTableViewCellDelegate?
  
  override func prepareForReuse() {
    super.prepareForReuse()
    attachmentImageView.cancelDownload()
    attachmentImageView.image = nil
    attachmentImageViewHeightConstraint.constant = 250 / 1.3
    attachmentImageViewWidthConstraint.constant = 250
  }
  
  override func set(_ message: ObjectMessage) {
    super.set(message)
    
    switch message.contentType {
    case .location:
      attachmentImageView.image = UIImage(named: "locationThumbnail")
    case .photo:
        if(tmstamp != nil)
        {
            let date = NSDate(timeIntervalSince1970: TimeInterval(message.timestamp))
           let dateFormatter = DateFormatter()
           dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
           tmstamp.text = dateFormatter.string(from: date as Date)
        }
       
      guard let urlString = message.profilePicLink else { return }
      attachmentImageView.setImage(url: URL(string: urlString)) {[weak self] image in
        guard let image = image, let weakSelf = self else { return }
        guard weakSelf.attachmentImageViewHeightConstraint.constant != image.size.height, weakSelf.attachmentImageViewWidthConstraint.constant != image.size.width else { return }
        if max(image.size.height, image.size.width) <= 250 {
          weakSelf.attachmentImageViewHeightConstraint.constant = image.size.height
          weakSelf.attachmentImageViewWidthConstraint.constant = image.size.width
          weakSelf.delegate?.messageTableViewCellUpdate()
          return
        }
        weakSelf.attachmentImageViewWidthConstraint.constant = 250
        weakSelf.attachmentImageViewHeightConstraint.constant = image.size.height * (250 / image.size.width)
        weakSelf.delegate?.messageTableViewCellUpdate()
      }
    default: break
    }
  }
}


class MessageOrderTableViewCell : UITableViewCell {
  
    @IBOutlet weak var order_title: UILabel!
    @IBOutlet weak var order_date: UILabel!
    @IBOutlet weak var order_product_count: UILabel!
    @IBOutlet weak var user_profile_img: UIImageView!
    @IBOutlet weak var order_comment: UITextView!
    @IBOutlet weak var tmstamp: UILabel!
    
    let manager = OrderdataManager()
    var msgVc = MessagesViewController()
    var conversation = ObjectConversation()
    var order_ref_id = ""
    var message = ObjectMessage()
    func set(_ message: ObjectMessage) {
        
        self.order_title.text = message.orderTitle
        self.order_date.text = message.orderdate
        self.order_comment.text = message.orderComment
        self.order_product_count.text = message.orderProductCount.description
        
        if(tmstamp != nil)
        {
            let date = NSDate(timeIntervalSince1970: TimeInterval(message.timestamp))
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            tmstamp.text = dateFormatter.string(from: date as Date)
        }
        
        guard let userID = message.ownerID else { return }
        ProfileManager.shared.userData(id: userID) { user in
          guard let urlString = user?.profilePicLink else { return }
          self.user_profile_img.setImage(url: URL(string: urlString))
        }
        
        if  message.orderRefString != nil {
          order_ref_id = message.orderRefString!
        }
        
        self.message = message
//
//        switch message.contentType {
//        case .product:
//            guard let orderRefString = message.orderRefString else { return }
//            guard let userID = message.ownerID else { return }
//            ProfileManager.shared.userData(id: userID) { user in
//              guard let urlString = user?.profilePicLink else { return }
//              self.user_profile_img.setImage(url: URL(string: urlString))
//            }
//            manager.get_order(orderRefString) { result in
//                self.order_title.text = result.title
//                self.order_date.text = result.date
//                self.order_comment.text = result.comment
//                self.order_product_count.text = result.products.count.description
//            }
//
//        default: break
//        }
    }
    
    @IBAction func onViewDetail(_ sender: Any) {
        let vc: OrderDetailViewController = UIStoryboard.initial(storyboard: .order_detail)
        vc.modalPresentationStyle = .fullScreen
        vc.message = message
        vc.flag = true
        vc.conversation = conversation
        vc.order_ref_id = order_ref_id
        msgVc.show(vc, sender: self)
    }
    
}


class MyMessageOrderTableViewCell: UITableViewCell {
  
    @IBOutlet weak var order_title: UILabel!
    @IBOutlet weak var order_date: UILabel!
    @IBOutlet weak var order_product_count: UILabel!
    @IBOutlet weak var order_comment: UITextView!
    @IBOutlet weak var order_id: UILabel!
    @IBOutlet weak var tmstamp: UILabel!
    
    
    let manager = OrderdataManager()
    var order_ref_id = ""
    var msgVc = MessagesViewController()
    var conversation = ObjectConversation()
    var message = ObjectMessage()
    
    func set(_ message: ObjectMessage) {
         self.order_title.text = message.orderTitle
         self.order_date.text = message.orderdate
         self.order_comment.text = message.orderComment
         self.order_product_count.text = message.orderProductCount.description
        
        if(tmstamp != nil)
        {
            let date = NSDate(timeIntervalSince1970: TimeInterval(message.timestamp))
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            tmstamp.text = dateFormatter.string(from: date as Date)
        }
        
        if  message.orderRefString != nil {
            order_ref_id = message.orderRefString!
            order_id.text = order_ref_id
        }
        self.message = message
//        switch message.contentType {
//            case .product:
//            guard let orderRefString = message.orderRefString else { return }
//
//              manager.get_order(orderRefString) { result in
//                  self.order_title.text = result.title
//                  self.order_date.text = result.date
//                  self.order_comment.text = result.comment
//                  self.order_product_count.text = result.products.count.description
//              }
//
//            default: break
//        }
    }
    
    @IBAction func onViewDetail(_ sender: Any) {

        let vc: OrderDetailViewController = UIStoryboard.initial(storyboard: .order_detail)
        vc.modalPresentationStyle = .fullScreen
        vc.message = message
        vc.flag = false
        vc.conversation = conversation
        vc.order_ref_id = order_ref_id
        msgVc.show(vc, sender: self)
    }
}


