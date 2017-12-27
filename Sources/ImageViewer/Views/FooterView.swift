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
                string: MediaViewerConfig.SendButton.text,
                attributes: MediaViewerConfig.SendButton.textAttributes)

        let button = UIButton(type: .system)

        button.setAttributedTitle(title, for: UIControlState())

        if let size = MediaViewerConfig.CloseButton.size {
            button.frame.size = size
        } else {
            button.sizeToFit()
        }

        button.addTarget(self, action: #selector(sendButtonDidPress(_:)),
                for: .touchUpInside)

        if let image = MediaViewerConfig.CloseButton.image {
            button.setBackgroundImage(image, for: UIControlState())
        }

        button.isHidden = !MediaViewerConfig.SendButton.enabled

        return button
    }()

    open fileprivate(set) lazy var addButton: UIButton = { [unowned self] in
        let button = UIButton()
        if let image = MediaViewerConfig.AddButton.image {
            button.setImage(image, for: .normal)
        }

        if let size = MediaViewerConfig.AddButton.size {
            button.bounds.size = size
        } else {
            button.sizeToFit()
        }

        button.addTarget(self, action: #selector(addButtonDidPress(_:)),
                for: .touchUpInside)
        button.isHidden = !MediaViewerConfig.AddButton.enabled

        return button
    }()

    open fileprivate(set) lazy var deleteButton: UIButton = { [unowned self] in

        let button = UIButton(type: .custom)
        if let image = MediaViewerConfig.DeleteButton.image {
            button.setImage(image, for: .normal)
        }

//        button.setTitle("asd", for: .normal)
        button.addTarget(self, action: #selector(deleteButtonDidPress(_:)),
                for: .touchUpInside)
//        button.isHidden = !MediaViewerConfig.DeleteButton.enabled
        button.sizeToFit()

        return button
    }()

    open fileprivate(set) lazy var messageTextView: ExpandableTextView = { [unowned self] in

        let textView = ExpandableTextView()

        textView.setTextPlaceholder(MediaViewerConfig.MessageTextView.placeholderText)
        textView.setTextPlaceholderFont(UIFont.systemFont(ofSize: 15))
        textView.setTextPlaceholderColor(UIColor.white)
        textView.textColor = .white

        textView.layer.cornerRadius = 4
        textView.spellCheckingType = .yes
        textView.autocorrectionType = .yes
        textView.attributedText = NSAttributedString(string: "",
                attributes: MediaViewerConfig.MessageTextView.textAttributes)

        textView.isEditable = false

        textView.backgroundColor = UIColor.init(red: 1, green: 1, blue: 1, alpha: 0.24)

        return textView
    }()

    open fileprivate(set) lazy var cancelButton: UIButton = { [unowned self] in
        let title = NSAttributedString(
                string: MediaViewerConfig.CancelButton.text,
                attributes: MediaViewerConfig.CancelButton.textAttributes)

        let button = UIButton(type: .system)

        button.setAttributedTitle(title, for: UIControlState())

        if let size = MediaViewerConfig.CancelButton.size {
            button.frame.size = size
        } else {
            button.sizeToFit()
        }

        button.addTarget(self, action: #selector(cancelButtonDidPress(_:)),
                for: .touchUpInside)

        if let image = MediaViewerConfig.CancelButton.image {
            button.setBackgroundImage(image, for: UIControlState())
        }

        button.isHidden = !MediaViewerConfig.CancelButton.enabled

        return button
    }()


    // MARK: - Initializers

    public init() {
        super.init(frame: CGRect.zero)

        backgroundColor = UIColor.clear
        _ = addGradientLayer(gradientColors)

        [addButton, messageTextView, cancelButton, deleteButton, sendButton].forEach {
            addSubview($0)
        }
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

    func addButtonDidPress(_ button: UIButton) {
        self.delegate?.footerView(self, didPressAddButton: button)
    }


//    MARK: - Store func
    func closeButtonDidPress(_ button: UIButton) {
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
        self.deleteButton.frame.origin = CGPoint.init(x: (self.bounds.width / 2) - (self.deleteButton.bounds.width / 2), y: self.bounds.maxY - self.deleteButton.bounds.height - 12)

        self.resizeGradientLayer()
    }
}
