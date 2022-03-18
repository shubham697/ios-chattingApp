import UIKit
import MapKit

class MapPreviewController: UIViewController {
  
  @IBOutlet weak var mapView: MKMapView!
  var locationString: String?
  
  @IBAction func closePressed(_ sender: Any) {
    dismiss(animated: true, completion: nil)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    guard let location = locationString?.location else { return }
    let annotation = MKPointAnnotation()
    annotation.coordinate = location
    mapView.addAnnotation(annotation)
    mapView.showAnnotations(mapView.annotations, animated: false)
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    modalTransitionStyle = .crossDissolve
    modalPresentationStyle = .overFullScreen
  }
}
