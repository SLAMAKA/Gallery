import UIKit
import Gallery
import AVFoundation
import AVKit

class ViewController: UIViewController {
  
  var button: UIButton!
  var gallery: GalleryController!
  let editor: VideoEditing = VideoEditor()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor.white
    
    Gallery.Config.VideoEditor.savesEditedVideoToLibrary = true
    
    button = UIButton(type: .system)
    button.frame.size = CGSize(width: 200, height: 50)
    button.setTitle("Open Gallery", for: UIControlState())
    button.addTarget(self, action: #selector(buttonTouched(_:)), for: .touchUpInside)
    
    view.addSubview(button)
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
    button.center = CGPoint(x: view.bounds.size.width/2, y: view.bounds.size.height/2)
  }
  
  func buttonTouched(_ button: UIButton) {
    //    let controller = DropdownController()
    //    controller.delegate = self
    //    let navigationController = UINavigationController.init(rootViewController: controller)
    //    self.present(navigationController, animated: true, completion: nil)
    
    let camera = CameraController()
    camera.delegate = self
    self.present(camera, animated: true, completion: nil)
  }
  
  
  func galleryControllerDidCancel(_ controller: GalleryController) {
    controller.dismiss(animated: true, completion: nil)
    gallery = nil
  }
  
  func galleryController(_ controller: GalleryController, didSelectVideo video: Video) {
    controller.dismiss(animated: true, completion: nil)
    gallery = nil
    
    
    editor.edit(video: video) { (editedVideo: Video?, tempPath: URL?) in
      DispatchQueue.main.async {
        print(editedVideo)
        if let tempPath = tempPath {
          let data = NSData(contentsOf: tempPath)
          print(data?.length)
          let controller = AVPlayerViewController()
          controller.player = AVPlayer(url: tempPath)
          
          self.present(controller, animated: true, completion: nil)
        }
      }
    }
  }
  
  func galleryController(_ controller: GalleryController, didSelectImages images: [UIImage]){
    print(images.count)
  }
}

extension ViewController: DropdownControllerDelegate{
  func dropdownController(_ controller: DropdownController, didSelectImages images: [URL]) {
    images.forEach { (url) in
      print(url)
    }
    controller.dismiss(animated: true, completion: nil)
  }
  
  func dropdownController(_ controller: DropdownController, didSelectVideo video: Video){
    print("func dropdownController(_ controller: DropdownController, didSelectVideo video: Video)")
    controller.dismiss(animated: true, completion: nil)
  }
  
  func dropdownControllerDidCancel(_ controller: DropdownController){
    controller.dismiss(animated: true, completion: nil)
    print("func dropdownControllerDidCancel(_ controller: DropdownController)")
  }
}

extension ViewController: CameraControllerDelegate {

  func cameraController(_ controller: CameraController, didSelectImages images: [URL]) {
    images.forEach({print($0)})
    controller.dismiss(animated: true, completion: nil)
  }
  
  func didCancelCameraController(_ controller: CameraController){
    print("didCancelCameraController(_ controller: CameraController)")
    controller.dismiss(animated: true, completion: nil)
  }
}
