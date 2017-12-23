import UIKit
import Photos

protocol DropdownControllerDelegate: class {
    func dropdownController (_ controller: DropdownController, didSelect album: Album)
}

open class DropdownController: UIViewController {

    lazy var tableView: UITableView = self.makeTableView()
    var animating: Bool = false
    var expanding: Bool = false
    var albums: [ Album ] = []
    let imageLibrary = ImagesLibrary.init()
    var topConstraint: NSLayoutConstraint?
    weak var delegate: DropdownControllerDelegate?

    open override func viewDidLoad () {
        super.viewDidLoad()
        setup()
        imageLibrary.reload { [ unowned self ]_ in
            self.albums = self.imageLibrary.albums

            if let album = self.albums.first {
                self.openImagesContoller(with: album, false)
            }
            self.tableView.reloadData()
        }


    }

    // MARK: - Setup

    func setup () {

        view.addSubview(tableView)
        tableView.register(AlbumCell.self, forCellReuseIdentifier: String(describing: AlbumCell.self))
        tableView.g_pinEdges()
    }

    func makeTableView () -> UITableView {
        let tableView = UITableView()
        tableView.tableFooterView = UIView()
        tableView.rowHeight = 84
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }

    func openImagesContoller(with album: Album, _ animate: Bool = true){
        let imageViewcontroller = ImagesController.init()
        imageViewcontroller.selectedAlbum = album
        self.navigationController?.pushViewController(imageViewcontroller, animated: animate)
    }
}

extension DropdownController: UITableViewDataSource, UITableViewDelegate {

    // MARK: - UITableViewDataSource

    public func tableView (_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albums.count
    }

    public func tableView (_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: AlbumCell.self), for: indexPath)
        as! AlbumCell

        let album = albums[ (indexPath as NSIndexPath).row ]
        cell.configure(album)
        cell.backgroundColor = UIColor.clear

        return cell
    }

    // MARK: - UITableViewDelegate

    public func tableView (_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        self.openImagesContoller(with: albums[ (indexPath as NSIndexPath).row ])
    }
}

