import UIKit
import Photos

public class ImagesController: UIViewController {
    fileprivate lazy var gridView: GridView = self.makeGridView()
    fileprivate lazy var stackView: StackView = self.makeStackView()
    fileprivate var items: [ Image ] = []
    var selectedAlbum: Album?

    override public func viewDidLoad () {
        super.viewDidLoad()
        self.setup()

        if let currentAlbum = self.selectedAlbum {
            self.show(album: currentAlbum)
            self.refreshView()
        }
    }
    
    func setup () {
        Cart.shared.add(delegate: self)
        view.backgroundColor = UIColor.white
        view.addSubview(gridView)
        
        gridView.collectionView.dataSource = self
        gridView.collectionView.delegate = self
        gridView.collectionView.register(ImageCell.self, forCellWithReuseIdentifier: String(describing: ImageCell.self))
        
        gridView.bottomView.addSubview(stackView)
        gridView.g_pinEdges()
        stackView.g_pin(on: .centerY, constant: -4)
        stackView.g_pin(on: .left, constant: 38)
        stackView.g_pin(size: CGSize(width: 56, height: 56))
        gridView.doneButton.addTarget(self, action: #selector(doneButtonTouched(_:)), for: .touchUpInside)
        stackView.addTarget(self, action: #selector(stackViewTouched(_:)), for: .touchUpInside)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "Cancel".g_localize(fallback: "Cancel"), style: .plain, target: self, action: #selector(self.cancelBarButtonTapped(_:)))

    }

//    MARK: - Actions
    func doneButtonTouched (_ button: UIButton) {
        EventHub.shared.doneWithImages?()
    }
    
    func cancelBarButtonTapped(_ sender: UIBarButtonItem){
        EventHub.shared.close?()
    }

    func stackViewTouched (_ stackView: StackView) {
        let images = Cart.shared.UIImages()
        LightboxConfig.SelectedFileCountLabel.text = "\(images.count) selected"
        let controller = LightboxController(images: images.map({LightboxImage.init(image: $0)}))
        controller.dynamicBackground = true
        controller.delegate = self
        self.present(controller, animated: true, completion: nil)
    }

    // MARK: - Logic
    func show (album: Album) {
        self.items = album.items
        self.gridView.collectionView.reloadData()
        self.gridView.collectionView.g_scrollToTop()
        self.gridView.emptyView.isHidden = !self.items.isEmpty
        
        self.navigationItem.title = album.collection.localizedTitle
    }

    func refreshSelectedAlbum () {
        if let selectedAlbum = selectedAlbum {
            selectedAlbum.reload()
            show(album: selectedAlbum)
        }
    }
    
    func refreshView () {
        let hasImages = !Cart.shared.images.isEmpty
        gridView.bottomView.g_fade(visible: hasImages)
        gridView.collectionView.g_updateBottomInset(hasImages ? gridView.bottomView.frame.size.height : 0)
    }

//    MARK: - View maker
    func makeGridView () -> GridView {
        let view = GridView()
        view.bottomView.alpha = 0
        return view
    }

    func makeStackView () -> StackView {
        let stackView = StackView()
        stackView.reload(Cart.shared.images)
        return StackView()
    }
}

extension ImagesController: CartDelegate {
    func cart (_ cart: Cart, didAdd image: Image, newlyTaken: Bool) {
        self.stackView.reload(cart.images, added: true)
        self.refreshView()
        if newlyTaken {
            self.refreshSelectedAlbum()
        }
    }

    func cart (_ cart: Cart, didRemove image: Image) {
        self.stackView.reload(cart.images)
        self.refreshView()
    }

    func cartDidReload (_ cart: Cart) {
        self.stackView.reload(cart.images)
        self.refreshView()
        self.refreshSelectedAlbum()
    }
}

extension ImagesController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    // MARK: - UICollectionViewDataSource
    public func collectionView (_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }

    public func collectionView (_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ImageCell.self), for: indexPath)
        as! ImageCell
        let item = items[ (indexPath as NSIndexPath).item ]

        cell.configure(item)
        configureFrameView(cell, indexPath: indexPath)

        return cell
    }

    // MARK: - UICollectionViewDelegateFlowLayout
    public func collectionView (_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let size = (collectionView.bounds.size.width - (Config.Grid.Dimension.columnCount - 1) * Config.Grid.Dimension.cellSpacing)
                / Config.Grid.Dimension.columnCount
        return CGSize(width: size, height: size)
    }

    public func collectionView (_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = items[ (indexPath as NSIndexPath).item ]

        if Cart.shared.images.contains(item) {
            Cart.shared.remove(item)
        } else {
            Cart.shared.add(item)
        }

        configureFrameViews()
    }

    func configureFrameViews () {
        for case let cell as ImageCell in gridView.collectionView.visibleCells {
            if let indexPath = gridView.collectionView.indexPath(for: cell) {
                configureFrameView(cell, indexPath: indexPath)
            }
        }
    }

    func configureFrameView (_ cell: ImageCell, indexPath: IndexPath) {
        let item = items[ (indexPath as NSIndexPath).item ]

        if let index = Cart.shared.images.index(of: item) {
            cell.frameView.g_quickFade()
            cell.frameView.label.text = "\(index + 1)"
        } else {
            cell.frameView.alpha = 0
        }
    }
}

extension ImagesController: LightboxControllerDelegate {
    
    public func lightboxControllerWillCancel(_ controller: LightboxController) {
        
    }
    
    public func lightboxControllerWillDismiss(_ controller: LightboxController) {
        
    }
    
    public func lightboxController(_ controller: LightboxController, didMoveToPage page: Int) {
        
    }
    
    public func lightboxController(_ controller: LightboxController, didTouch image: LightboxImage, at index: Int) {
        
    }
}
