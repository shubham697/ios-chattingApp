import UIKit

class ConversationCell: UITableViewCell {
  
  //MARK: IBOutlets
  @IBOutlet weak var profilePic: UIImageView!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var messageLabel: UILabel!
  @IBOutlet weak var timeLabel: UILabel!
  
  //MARK: Private properties
//  var userID = UserManager().currentUserID() ?? ""
  var userID = ""
  //MARK: Public methods
  func set(_ conversation: ObjectConversation) {
    timeLabel.text = DateService.shared.format(Date(timeIntervalSince1970: TimeInterval(conversation.timestamp)))
    messageLabel.text = conversation.lastMessage
    
    guard let id = conversation.userIDs.filter({$0 != userID}).first else { return }
    let isRead = conversation.isRead[userID] ?? true
    if !isRead {
      nameLabel.font = nameLabel.font.bold
      messageLabel.font = messageLabel.font.bold
      messageLabel.textColor = ThemeService.purpleColor
      timeLabel.font = timeLabel.font.bold
    }
    ProfileManager.shared.userData(id: id) {[weak self] profile in
        var name_label_txt = ""
        if profile != nil {
            name_label_txt = (profile!.name == nil ? "" : profile!.name!) + "-" + (profile!.company_name == nil ? "" : profile!.company_name!)
            if profile!.role == "TechSupport" {
                name_label_txt = "Technical Support"
            }
        }
        else {
            name_label_txt = (conversation.contact_name == nil ? "" : conversation.contact_name!) + "-" +
                (conversation.company_name == nil ? "" :  conversation.company_name!)
        }
        self?.nameLabel.text = name_label_txt
        guard let urlString = profile?.profilePicLink else {
//            self?.profilePic.image = UIImage(named: "profile pic")
            return
        }
        self?.profilePic.setImage(url: URL(string: urlString))
    }
  }
  
  //MARK: Lifecycle
  override func prepareForReuse() {
    super.prepareForReuse()
    profilePic.cancelDownload()
    nameLabel.font = nameLabel.font.regular
    messageLabel.font = messageLabel.font.regular
    timeLabel.font = timeLabel.font.regular
    messageLabel.textColor = .gray
    messageLabel.text = nil
  }
}

