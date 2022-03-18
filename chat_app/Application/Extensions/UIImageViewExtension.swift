
import UIKit
import Kingfisher

extension UIImageView {
  
  func setImage(url: URL?, completion: CompletionObject<UIImage?>? = nil) {
    kf.setImage(with: url) { result in
      switch result {
      case .success(let value):
        completion?(value.image)
      case .failure(_):
        completion?(nil)
      }
    }
  }
  
  func cancelDownload() {
    kf.cancelDownloadTask()
  }
}
