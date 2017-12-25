import UIKit

protocol HeaderViewDelegate: class {

}

open class HeaderView: UIView {

  weak var delegate: HeaderViewDelegate?

    open fileprivate(set) lazy var conversationLabel: UILabel = { [unowned self] in
        let label = UILabel.init(frame: CGRect.zero)
        
//        // create an NSMutableAttributedString that we'll append everything to
//        let fullString = NSMutableAttributedString(string: "")
//        
//        // create our NSTextAttachment
//        let image1Attachment = NSTextAttachment()
//        image1Attachment.image = UIImage(named: "awesomeIcon.png")
//        
//        // wrap the attachment in its own attributed string so we can append it
//        let image1String = NSAttributedString(attachment: image1Attachment)
//        
//        // add the NSTextAttachment wrapper to our full string, then add some more text.
//        fullString.append(image1String)
//        fullString.append(NSAttributedString(string: "End of text"))
//        fullString.append(<#T##attrString: NSAttributedString##NSAttributedString#>)
        
        label.attributedText = NSAttributedString.init(string: LightboxConfig.ConversationNameLabel.text,
                                                       attributes: LightboxConfig.ConversationNameLabel.textAttributes)
        label.sizeToFit()
        return label
    }()
    
    
    
    
    open fileprivate(set) lazy var fileCountLabel: UILabel = { [unowned self] in
        let label = UILabel.init(frame: CGRect.zero)
        label.attributedText = NSAttributedString.init(string: LightboxConfig.SelectedFileCountLabel.text,
                                                       attributes: LightboxConfig.SelectedFileCountLabel.textAttributes)
        label.sizeToFit()
        return label
        }()
    
    fileprivate let gradientColors = [UIColor(hex: "000000").alpha(0.48), UIColor(hex: "000000").alpha(0.48)]
    
  // MARK: - Initializers

  public init() {
    super.init(frame: CGRect.zero)
    backgroundColor = UIColor.clear
    _ = self.addGradientLayer(self.gradientColors)
    [conversationLabel, fileCountLabel].forEach { addSubview($0) }
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Actions

  func deleteButtonDidPress(_ button: UIButton) {

  }

  func closeButtonDidPress(_ button: UIButton) {

  }
}

// MARK: - LayoutConfigurable

extension HeaderView: LayoutConfigurable {

  public func configureLayout() {
    self.conversationLabel.frame.origin = CGPoint.init(x: 16, y: 19)
    self.fileCountLabel.frame.origin = CGPoint.init(x: self.bounds.width - self.fileCountLabel.bounds.width - 16, y: 19)
    self.resizeGradientLayer()
  }
}
