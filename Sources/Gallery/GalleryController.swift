import UIKit
import AVFoundation

public protocol GalleryControllerDelegate: class {

  
}

public class GalleryController: UIViewController, PermissionControllerDelegate {

  lazy var imagesController: ImagesController = self.makeImagesController()
  lazy var cameraController: CameraController = self.makeCameraController()
  lazy var videosController: VideosController = self.makeVideosController()

  enum Page: Int {
    case images, camera, videos
  }

  lazy var pagesController: PagesController = self.makePagesController()
  lazy var permissionController: PermissionController = self.makePermissionController()
  public weak var delegate: GalleryControllerDelegate?

  // MARK: - Life cycle

  public override func viewDidLoad() {
    super.viewDidLoad()

    setup()

    if Permission.hasPermissions {
      showMain()
    } else {
      showPermissionView()
    }
  }

  deinit {
    Cart.shared.reset()
  }

  public override var prefersStatusBarHidden : Bool {
    return true
  }

  // MARK: - Logic

  public func reload(_ images: [UIImage]) {
    Cart.shared.reload(images)
  }

  func showMain() {
    g_addChildController(pagesController)
  }

  func showPermissionView() {
    g_addChildController(permissionController)
  }

  // MARK: - Child view controller

  func makeImagesController() -> ImagesController {
    let controller = ImagesController()
    controller.title = "Gallery.Images.Title".g_localize(fallback: "PHOTOS")
    Cart.shared.add(delegate: controller)

    return controller
  }

  func makeCameraController() -> CameraController {
    let controller = CameraController()
    controller.title = "Gallery.Camera.Title".g_localize(fallback: "CAMERA")
    Cart.shared.add(delegate: controller)

    return controller
  }

  func makeVideosController() -> VideosController {
    let controller = VideosController()
    controller.title = "Gallery.Videos.Title".g_localize(fallback: "VIDEOS")

    return controller
  }

  func makePagesController() -> PagesController {
    let controller = PagesController(controllers: [imagesController, cameraController, videosController])
    controller.selectedIndex = Page.camera.rawValue

    return controller
  }

  func makePermissionController() -> PermissionController {
    let controller = PermissionController()
    controller.delegate = self

    return controller
  }

  // MARK: - Setup

  func setup() {
    
  }

  // MARK: - PermissionControllerDelegate

  func permissionControllerDidFinish(_ controller: PermissionController) {
    showMain()
    permissionController.g_removeFromParentController()
  }
}
