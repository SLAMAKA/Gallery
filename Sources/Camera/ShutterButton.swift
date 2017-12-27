import UIKit

class ShutterButton: UIButton {

  lazy var overlayView: UIView = self.makeOverlayView()
  lazy var roundLayer: CAShapeLayer = self.makeRoundLayer()

  // MARK: - Initialization

  override init(frame: CGRect) {
    super.init(frame: frame)

    setup()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Layout

  override func layoutSubviews() {
    super.layoutSubviews()

    overlayView.frame = bounds.insetBy(dx: 8, dy: 8)
    overlayView.layer.cornerRadius = overlayView.frame.size.width/2

    roundLayer.path = UIBezierPath(ovalIn: bounds.insetBy(dx: 3, dy: 3)).cgPath
    layer.cornerRadius = bounds.size.width/2
  }

  // MARK: - Setup

  func setup() {
    backgroundColor = UIColor.clear

    addSubview(overlayView)
    layer.addSublayer(roundLayer)
  }

  // MARK: - Controls

  func makeOverlayView() -> UIView {
    let view = UIView()
    view.frame.size = CGSize.init(width: 54, height: 54)
    view.backgroundColor = UIColor.white
    view.isUserInteractionEnabled = false

    return view
  }

  func makeRoundLayer() -> CAShapeLayer {
    let layer = CAShapeLayer()
    layer.strokeColor = UIColor.white.cgColor
    layer.lineWidth = 3
    layer.fillColor = nil

    return layer
  }

  // MARK: - Highlight

  override var isHighlighted: Bool {
    didSet {
      overlayView.backgroundColor = isHighlighted ? UIColor.gray : UIColor.white
    }
  }
}
