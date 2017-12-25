import UIKit
import Photos

class GridView: UIView {

  // MARK: - Initialization
  lazy var topView: UIView = self.makeTopView()
  lazy var bottomView: UIView = self.makeBottomView()
  lazy var collectionView: UICollectionView = self.makeCollectionView()
  lazy var doneButton: UIButton = self.makeDoneButton()
  lazy var emptyView: UIView = self.makeEmptyView()

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
    backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)

    [collectionView, bottomView, topView, emptyView].forEach {
      addSubview($0)
    }
    
    [doneButton].forEach {
      bottomView.addSubview($0)
    }

    topView.g_pinUpward()
    topView.g_pin(height: 40)
    bottomView.g_pinDownward()
    bottomView.g_pin(height: 44)

    emptyView.g_pinEdges(view: collectionView)
    collectionView.g_pin(on: .left)
    collectionView.g_pin(on: .right)
    collectionView.g_pin(on: .bottom)
    collectionView.g_pin(on: .top, view: topView, on: .bottom, constant: 1)

    doneButton.g_pin(on: .centerY)
    doneButton.g_pin(on: .centerX)
  }
    
    func updateCount(){
        self.doneButton.setTitle("\(Cart.shared.images.count) selected", for: .normal)
        self.doneButton.sizeToFit()
    }

  // MARK: - Controls

  func makeTopView() -> UIView {
    let view = UIView()
    view.backgroundColor = UIColor.white

    return view
  }
    
  func makeBottomView() -> UIView {
    let view = UIView()
    view.backgroundColor = UIColor.init(hex: "FAFAFA")
    return view
  }
    
  func makeGridView() -> GridView {
    let view = GridView()
    return view
  }

  func makeDoneButton() -> UIButton {
    let button = UIButton(type: .system)
    button.setTitleColor(UIColor.init(hex: "262626"), for: UIControlState())
    button.setTitleColor(UIColor.lightGray, for: .disabled)
    button.titleLabel?.font = Config.Font.Text.regular.withSize(16)
    button.setTitle("\(Cart.shared.images.count) selected", for: .normal)
    
    return button
  }

  func makeCollectionView() -> UICollectionView {
    let layout = UICollectionViewFlowLayout()
    layout.minimumInteritemSpacing = 2
    layout.minimumLineSpacing = 2

    let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
    view.backgroundColor = UIColor.white

    return view
  }

  func makeEmptyView() -> EmptyView {
    let view = EmptyView()
    view.isHidden = true

    return view
  }
}
