import UIKit
import Photos

public class ImagesController: UIViewController {
    fileprivate lazy var gridView: GridView = self.makeGridView()
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
        gridView.g_pinEdges()

        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "", style: .plain, target: self, action: #selector(self.cancelBarButtonTapped(_:)))
    }

//    MARK: - Actions
    func doneButtonTouched (_ button: UIButton) {
        let images = Cart.shared.UIImages()
        MediaViewerConfig.SelectedFileCountLabel.text = "\(images.count) selected"
        let controller = MediaViewerController(images: images.map({ ImageModel.init(image: $0)}), startIndex: images.count)
        controller.dynamicBackground = true
        controller.delegate = self
        self.present(controller, animated: true, completion: nil)
    }
    
    func cancelBarButtonTapped(_ sender: UIBarButtonItem){
        if Cart.shared.images.isEmpty {
            EventHub.shared.close?()
        } else{
            self.doneButtonTouched(self.gridView.doneButton)
        }
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
        self.navigationItem.rightBarButtonItem?.title = hasImages ? "Done".g_localize(fallback: "Done") : "Cancel".g_localize(fallback: "Cancel")
        gridView.bottomView.g_fade(visible: hasImages)
        gridView.collectionView.g_updateBottomInset(hasImages ? gridView.bottomView.frame.size.height : 0)
    }

//    MARK: - View maker
    func makeGridView () -> GridView {
        let view = GridView()
        view.bottomView.alpha = 0
        return view
    }
    
}

extension ImagesController: CartDelegate {
    func cart (_ cart: Cart, didAdd image: Image, newlyTaken: Bool) {
        self.gridView.updateCount()
        self.refreshView()
        if newlyTaken {
            self.refreshSelectedAlbum()
        }
    }

    func cart (_ cart: Cart, didRemove image: Image) {
        self.gridView.updateCount()
        self.refreshView()
        configureFrameViews()
    }

    func cartDidReload (_ cart: Cart) {
        self.gridView.updateCount()
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

extension ImagesController: MediaViewerControllerDelegate {
    public func mediaViewerControllerDidAdd(_ controller: MediaViewerController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    public func mediaViewerControllerDidSend(_ controller: MediaViewerController) {
        EventHub.shared.doneWithImages?()
    }
    
    
    public func mediaViewerControllerWillCancel(_ controller: MediaViewerController) {
        controller.dismiss(animated: true, completion: nil)
        Cart.shared.images.removeAll()
        self.gridView.collectionView.reloadData()
        self.gridView.updateCount()
        self.refreshView()
    }
    
    public func mediaViewerControllerWillDismiss(_ controller: MediaViewerController) {
        
    }
    
    public func mediaViewerController(_ controller: MediaViewerController, didMoveToPage page: Int) {
        
    }
    
    public func mediaViewerController(_ controller: MediaViewerController, didTouch image: ImageModel, at index: Int) {
        
    }
}
