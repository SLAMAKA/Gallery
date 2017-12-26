import UIKit

class FrameView: UIView {

  lazy var label: UILabel = self.makeLabel()
  lazy var gradientLayer: CAGradientLayer = self.makeGradientLayer()

  // MARK: - Initialization

  override init(frame: CGRect) {
    super.init(frame: frame)

    setup()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Setup

  func setup() {
    layer.addSublayer(gradientLayer)
    layer.borderColor = Config.Grid.FrameView.borderColor.cgColor
    layer.borderWidth = 3

    addSubview(label)
    }

  // MARK: - Layout

  override func layoutSubviews() {
    super.layoutSubviews()

    gradientLayer.frame = bounds
  }

  // MARK: - Controls

  func makeLabel() -> UILabel {
    let label = UILabel()
    label.font = Config.Font.Main.regular.withSize(14)
    label.textColor = UIColor.white
    label.backgroundColor = UIColor.init(hex: "0084FF")
    label.layer.cornerRadius = 11
    label.layer.borderColor = UIColor.white.cgColor
    label.layer.borderWidth = 1.0
    label.textAlignment = .center
    label.layer.masksToBounds = true
    label.frame.size = CGSize.init(width: 22, height: 22)
    return label
  }

  func makeGradientLayer() -> CAGradientLayer {
    let layer = CAGradientLayer()
    layer.colors = [
      Config.Grid.FrameView.fillColor.withAlphaComponent(0.25).cgColor,
      Config.Grid.FrameView.fillColor.withAlphaComponent(0.4).cgColor
    ]

    return layer
  }
}
