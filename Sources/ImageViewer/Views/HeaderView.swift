import UIKit

protocol HeaderViewDelegate: class {

}

open class HeaderView: UIView {

  weak var delegate: HeaderViewDelegate?

    open fileprivate(set) lazy var conversationLabel: UILabel = { [unowned self] in
        let label = UILabel.init(frame: CGRect.zero)
                
        label.attributedText = NSAttributedString.init(string: MediaViewerConfig.ConversationNameLabel.text,
                                                       attributes: MediaViewerConfig.ConversationNameLabel.textAttributes)
        label.sizeToFit()
        return label
    }()
    
    
    open fileprivate(set) lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 2
        layout.minimumLineSpacing = 2
        layout.scrollDirection = .horizontal
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        view.dataSource = self
        view.delegate = self
        view.register(ImageCell.self, forCellWithReuseIdentifier: String(describing: ImageCell.self))
        view.backgroundColor = UIColor.clear
        return view
    }()
    
    open fileprivate(set) lazy var fileCountLabel: UILabel = { [unowned self] in
        let label = UILabel.init(frame: CGRect.zero)
        label.attributedText = NSAttributedString.init(string: "\(Cart.shared.images.count) selected",
                                                       attributes: MediaViewerConfig.SelectedFileCountLabel.textAttributes)
        label.sizeToFit()
        return label
        }()
    
    fileprivate let gradientColors = [UIColor(hex: "000000").alpha(0.48), UIColor(hex: "000000").alpha(0.48)]
    
  // MARK: - Initializers

  public init() {
    super.init(frame: CGRect.zero)
    backgroundColor = UIColor.clear
    _ = self.addGradientLayer(self.gradientColors)
    [conversationLabel, collectionView, fileCountLabel].forEach { addSubview($0) }
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

    func updateSelectedCountLabel(){
        self.fileCountLabel.attributedText = NSAttributedString.init(string: "\(Cart.shared.images.count) selected",
            attributes: MediaViewerConfig.SelectedFileCountLabel.textAttributes)
        self.fileCountLabel.sizeToFit()
    }
    
    func deleteRowInCollectionView(_ row: Int){
        self.collectionView.deleteItems(at: [IndexPath.init(row: row, section: 0)])
    }
    
    fileprivate var prevPosition: Int = -1
    func setFocusOn(_ position: Int) {
        
        if self.prevPosition < 0 {
            self.prevPosition = position
        }
        
        self.collectionView.scrollToItem(at: IndexPath.init(row: position, section: 0), at: UICollectionViewScrollPosition.centeredHorizontally, animated: true)
        
    }
    
//    func configureFrameView (_ cell: ImageCell, indexPath: IndexPath) {
//        let item = items[ (indexPath as NSIndexPath).item ]
//
//        if let index = Cart.shared.images.index(of: item) {
//            cell.frameView.g_quickFade()
//            cell.frameView.label.text = "\(index + 1)"
//        } else {
//            cell.frameView.alpha = 0
//        }
//    }
}

// MARK: - LayoutConfigurable

extension HeaderView: LayoutConfigurable {

  public func configureLayout() {
    self.conversationLabel.frame.origin = CGPoint.init(x: 16, y: 16)
    
    if Cart.shared.images.count <= 1 {
        self.collectionView.isHidden = true
        self.fileCountLabel.isHidden = true
    } else {
        self.fileCountLabel.frame.origin = CGPoint.init(x: self.bounds.width - self.fileCountLabel.bounds.width - 16, y: 16)
        self.collectionView.frame = CGRect.init(origin: CGPoint.init(x: 2, y: 38), size: CGSize.init(width: self.bounds.width - 4, height: 56))
        self.collectionView.reloadData()
    }
    self.resizeGradientLayer()
  }
}

extension HeaderView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    // MARK: - UICollectionViewDataSource
    public func collectionView (_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Cart.shared.images.count
    }
    
    public func collectionView (_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ImageCell.self), for: indexPath)
            as! ImageCell
        let item = Cart.shared.images[indexPath.row]
        
        cell.configure(item)
        return cell
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    public func collectionView (_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 56, height: 56)
    }
}
