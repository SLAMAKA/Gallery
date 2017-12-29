import UIKit
import AVFoundation

public protocol CameraControllerDelegate: class {
    func didCancelCameraController(_ controller: CameraController)
    func cameraController(_ controller: CameraController, didSelectImages images: [String])
}

public class CameraController: UIViewController {
    
    var locationManager: LocationManager?
    lazy var cameraMan: CameraMan = self.makeCameraMan()
    lazy var cameraView: CameraView = self.makeCameraView()
    let once = Once()
    public weak var delegate: CameraControllerDelegate?
    lazy var permissionController: PermissionController = self.makePermissionController()
    
    public override var prefersStatusBarHidden: Bool{ return MediaViewerConfig.hideStatusBar }
    public override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation { return .slide }
    
    // MARK: - Life cycle
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        if Permission.hasPermissions {
            showMain()
        } else {
            showPermissionView()
        }
    }
    
    func makePermissionController() -> PermissionController {
        let controller = PermissionController()
        controller.delegate = self
        
        return controller
    }
    
    func showPermissionView(){
        g_addChildController(permissionController)
    }
    
    
    func showMain(){
        setup()
        setupLocation()
        once.run {
            cameraMan.setup()
        }
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        locationManager?.start()
    }
    
    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        locationManager?.stop()
    }
    
    // MARK: - Setup
    
    func setup() {
        view.addSubview(cameraView)
        cameraView.g_pinEdges()
        
        cameraView.closeButton.addTarget(self, action: #selector(closeButtonTouched(_:)), for: .touchUpInside)
        cameraView.flashButton.addTarget(self, action: #selector(flashButtonTouched(_:)), for: .touchUpInside)
        cameraView.rotateButton.addTarget(self, action: #selector(rotateButtonTouched(_:)), for: .touchUpInside)
        //    cameraView.stackView.addTarget(self, action: #selector(stackViewTouched(_:)), for: .touchUpInside)
        cameraView.shutterButton.addTarget(self, action: #selector(shutterButtonTouched(_:)), for: .touchUpInside)
        cameraView.doneButton.addTarget(self, action: #selector(doneButtonTouched(_:)), for: .touchUpInside)
    }
    
    func setupLocation() {
        if Config.Camera.recordLocation {
            locationManager = LocationManager()
        }
    }
    
    // MARK: - Action
    
    func closeButtonTouched(_ button: UIButton) {
        Cart.shared.images.removeAll()
        self.delegate?.didCancelCameraController(self)
    }
    
    func flashButtonTouched(_ button: UIButton) {
        cameraView.flashButton.toggle()
        
        if let flashMode = AVCaptureFlashMode(rawValue: cameraView.flashButton.selectedIndex) {
            cameraMan.flash(flashMode)
        }
    }
    
    func rotateButtonTouched(_ button: UIButton) {
        UIView.animate(withDuration: 0.3, animations: {
            self.cameraView.rotateOverlayView.alpha = 1
        }, completion: { _ in
            self.cameraMan.switchCamera {
                UIView.animate(withDuration: 0.7, animations: {
                    self.cameraView.rotateOverlayView.alpha = 0
                })
            }
        })
    }
    
    func shutterButtonTouched(_ button: ShutterButton) {
        guard let previewLayer = cameraView.previewLayer else { return }
        
        button.isEnabled = false
        UIView.animate(withDuration: 0.1, animations: {
            self.cameraView.shutterOverlayView.alpha = 1
        }, completion: { _ in
            UIView.animate(withDuration: 0.1, animations: {
                self.cameraView.shutterOverlayView.alpha = 0
            })
        })
        
        self.cameraView.stackView.startLoading()
        cameraMan.takePhoto(previewLayer, location: locationManager?.latestLocation) { asset in
            button.isEnabled = true
            self.cameraView.stackView.stopLoading()
            
            if let asset = asset {
                Cart.shared.add(Image.init(asset: asset))
                let controller = MediaViewerController(images: Cart.shared.UIImages().map({ImageModel.init(image: $0)}), startIndex: Cart.shared.UIImages().count-1)
                controller.dynamicBackground = true
                controller.delegate = self
                self.present(controller, animated: true, completion: nil)
            }
        }
    }
    
    func doneButtonTouched(_ button: UIButton) {
        EventHub.shared.doneWithImages?()
    }
    
    // MARK: - View
    
    func refreshView() {
        let hasImages = !Cart.shared.images.isEmpty
        cameraView.bottomView.g_fade(visible: hasImages)
    }
    
    // MARK: - Controls
    
    func makeCameraMan() -> CameraMan {
        let man = CameraMan()
        man.delegate = self
        
        return man
    }
    
    func makeCameraView() -> CameraView {
        let view = CameraView()
        view.delegate = self
        
        return view
    }
}

extension CameraController: CartDelegate {
    
    func cart(_ cart: Cart, didAdd image: Image, newlyTaken: Bool) {
        cameraView.stackView.reload(cart.images, added: true)
        refreshView()
    }
    
    func cart(_ cart: Cart, didRemove image: Image) {
        cameraView.stackView.reload(cart.images)
        refreshView()
    }
    
    func cartDidReload(_ cart: Cart) {
        cameraView.stackView.reload(cart.images)
        refreshView()
    }
}

extension CameraController: CameraViewDelegate {
    
    func cameraView(_ cameraView: CameraView, didTouch point: CGPoint) {
        cameraMan.focus(point)
    }
}

extension CameraController: CameraManDelegate {
    
    func cameraManDidStart(_ cameraMan: CameraMan) {
        cameraView.setupPreviewLayer(cameraMan.session)
    }
    
    func cameraManNotAvailable(_ cameraMan: CameraMan) {
        cameraView.focusImageView.isHidden = true
    }
    
    func cameraMan(_ cameraMan: CameraMan, didChangeInput input: AVCaptureDeviceInput) {
        cameraView.flashButton.isHidden = !input.device.hasFlash
    }
}

extension CameraController: PermissionControllerDelegate {
    func permissionControllerDidFinish(_ controller: PermissionController) {
        showMain()
        permissionController.g_removeFromParentController()
    }
}

extension CameraController: MediaViewerControllerDelegate {
    public func mediaViewerControllerDidAdd(_ controller: MediaViewerController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    public func mediaViewerControllerDidSend(_ controller: MediaViewerController) {
        controller.dismiss(animated: true, completion: nil)
        self.delegate?.cameraController(self, didSelectImages: Cart.shared.assetsUrls())
        Cart.shared.images.removeAll()
    }
    
    public func mediaViewerControllerWillCancel(_ controller: MediaViewerController) {
        Cart.shared.images.removeAll()
        controller.dismiss(animated: true, completion: nil)
    }
    
    public func mediaViewerControllerWillDismiss(_ controller: MediaViewerController) {
        
    }
    
    public func mediaViewerController(_ controller: MediaViewerController, didMoveToPage page: Int) {
        
    }
    
    public func mediaViewerController(_ controller: MediaViewerController, didTouch image: ImageModel, at index: Int) {
        
    }
}
