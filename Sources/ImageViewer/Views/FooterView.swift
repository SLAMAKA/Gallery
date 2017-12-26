import UIKit

public protocol FooterViewDelegate: class {
    func footerView(_ footerView: FooterView, didPressDeleteButton deleteButton: UIButton)
    func footerView(_ footerView: FooterView, didPressCancelButton closeButton: UIButton)
    func footerView(_ footerView: FooterView, didPressAddButton closeButton: UIButton)
    func footerView(_ footerView: FooterView, didPressSendButton closeButton: UIButton)

}

open class FooterView: UIView {

  fileprivate let gradientColors = [UIColor(hex: "000000").alpha(0.48), UIColor(hex: "000000").alpha(0.48)]
  open weak var delegate: FooterViewDelegate?
    
    open fileprivate(set) lazy var sendButton: UIButton = { [unowned self] in
        let title = NSAttributedString(
            string: LightboxConfig.SendButton.text,
            attributes: LightboxConfig.SendButton.textAttributes)
        
        let button = UIButton(type: .system)
        
        button.setAttributedTitle(title, for: UIControlState())
        
        if let size = LightboxConfig.CloseButton.size {
            button.frame.size = size
        } else {
            button.sizeToFit()
        }
        
        button.addTarget(self, action: #selector(sendButtonDidPress(_:)),
                         for: .touchUpInside)
        
        if let image = LightboxConfig.CloseButton.image {
            button.setBackgroundImage(image, for: UIControlState())
        }
        
        button.isHidden = !LightboxConfig.SendButton.enabled
        
        return button
        }()
    
    open fileprivate(set) lazy var addButton: UIButton = { [unowned self] in
        let title = NSAttributedString(
            string: LightboxConfig.AddButton.text,
            attributes: LightboxConfig.AddButton.textAttributes)
        
        let button = UIButton(type: .system)
        
        button.setAttributedTitle(title, for: UIControlState())
        
        if let image = LightboxConfig.AddButton.image {
            button.setImage(image, for: .normal)
        }
        button.sizeToFit()
        
        
        button.addTarget(self, action: #selector(addButtonDidPress(_:)),
                         for: .touchUpInside)
        button.isHidden = !LightboxConfig.AddButton.enabled
        
        return button
        }()
    
    open fileprivate(set) lazy var deleteButton: UIButton = { [unowned self] in
        let title = NSAttributedString(
            string: LightboxConfig.DeleteButton.text,
            attributes: LightboxConfig.DeleteButton.textAttributes)
        
        let button = UIButton(type: .system)
        
        button.setAttributedTitle(title, for: UIControlState())
        
        if let size = LightboxConfig.DeleteButton.size {
            button.frame.size = size
        } else {
            button.sizeToFit()
        }
        
        if let image = LightboxConfig.DeleteButton.image {
            button.setImage(image, for: .normal)
        }
        
        button.addTarget(self, action: #selector(deleteButtonDidPress(_:)),
                         for: .touchUpInside)
        
        if let image = LightboxConfig.AddButton.image {
            button.setBackgroundImage(image, for: UIControlState())
        }
        
        button.isHidden = !LightboxConfig.AddButton.enabled
        
        return button
        }()
    
    open fileprivate(set) lazy var messageTextView: ExpandableTextView = { [unowned self] in
        
        let textView = ExpandableTextView()

        textView.setTextPlaceholder(LightboxConfig.MessageTextView.placeholderText)
        textView.setTextPlaceholderFont(UIFont.systemFont(ofSize: 15))
        textView.setTextPlaceholderColor(UIColor.white)
        textView.textColor = .white

        textView.layer.cornerRadius = 4
        textView.spellCheckingType = .yes
        textView.autocorrectionType = .yes
        textView.attributedText = NSAttributedString(string: "",
                                                     attributes: LightboxConfig.MessageTextView.textAttributes)
        
        textView.backgroundColor = UIColor.init(red: 1, green: 1, blue: 1, alpha: 0.24)
        
        return textView
    }()
    
    open fileprivate(set) lazy var cancelButton: UIButton = { [unowned self] in
        let title = NSAttributedString(
            string: LightboxConfig.CancelButton.text,
            attributes: LightboxConfig.CancelButton.textAttributes)
        
        let button = UIButton(type: .system)
        
        button.setAttributedTitle(title, for: UIControlState())
        
        if let size = LightboxConfig.CancelButton.size {
            button.frame.size = size
        } else {
            button.sizeToFit()
        }
        
        button.addTarget(self, action: #selector(cancelButtonDidPress(_:)),
                         for: .touchUpInside)
        
        if let image = LightboxConfig.CancelButton.image {
            button.setBackgroundImage(image, for: UIControlState())
        }
        
        button.isHidden = !LightboxConfig.CancelButton.enabled
        
        return button
        }()


  // MARK: - Initializers

  public init() {
    super.init(frame: CGRect.zero)

    backgroundColor = UIColor.clear
    _ = addGradientLayer(gradientColors)

    [addButton, messageTextView, cancelButton, deleteButton, sendButton].forEach { addSubview($0) }
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  
  // MARK: - Layout

  fileprivate func resetFrames() {
    resizeGradientLayer()
  }
    
//    MARK: - Actions
    func sendButtonDidPress(_ button: UIButton) {
        self.delegate?.footerView(self, didPressSendButton: button)
    }
    
    func deleteButtonDidPress(_ button: UIButton) {
        self.delegate?.footerView(self, didPressDeleteButton: button)
    }
    
    func cancelButtonDidPress(_ button: UIButton) {
        self.delegate?.footerView(self, didPressCancelButton: button)
    }
    
    func addButtonDidPress(_ button: UIButton){
        self.delegate?.footerView(self, didPressAddButton: button)
    }
    
    
//    MARK: - Store func
    func closeButtonDidPress(_ button: UIButton){
        self.delegate?.footerView(self, didPressCancelButton: button)
    }
}

// MARK: - LayoutConfigurable

extension FooterView: LayoutConfigurable {
    public func configureLayout() {
        self.addButton.frame.origin = CGPoint.init(x: 16, y: 9)
        self.messageTextView.frame = CGRect.init(origin: CGPoint.init(x: self.addButton.bounds.maxX + 16 * 2, y: 9), size: CGSize.init(width: self.bounds.width - self.addButton.frame.width - 16 * 3, height: 30))
        self.cancelButton.frame.origin = CGPoint.init(x: 16, y: self.bounds.maxY - self.cancelButton.bounds.height - 12)
        self.sendButton.frame.origin = CGPoint.init(x: self.bounds.width - self.sendButton.bounds.width - 16, y: self.bounds.maxY - self.sendButton.bounds.height - 12)
        self.deleteButton.frame.origin = CGPoint.init(x: (self.bounds.width / 2) - (self.deleteButton.bounds.width / 2) , y: self.bounds.maxY - self.deleteButton.bounds.height - 12)
        
        self.resizeGradientLayer()
    }
}
