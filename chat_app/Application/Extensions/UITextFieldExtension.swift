import Foundation
import UIKit

extension UITextField  {
 func textbottommboarder(frame1 : CGRect){
    let border = UIView()
    let width = CGFloat(2.0)
    border.backgroundColor = UIColor.lightGray
    border.frame = CGRect(x: 0, y: self.frame.size.height - width, width:  frame1.width, height: 20)
    self.layer.addSublayer(border.layer)
    self.layer.masksToBounds = true
 }
}
