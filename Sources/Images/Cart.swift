import UIKit
import Photos

protocol CartDelegate: class {
    func cart(_ cart: Cart, didAdd image: Image, newlyTaken: Bool)
    func cart(_ cart: Cart, didRemove image: Image)
    func cartDidReload(_ cart: Cart)
}

public class Cart {
    
    public static let shared = Cart()
    
    public var images: [Image] = []
    fileprivate var selectedImages: [UIImage] = []
    public var video: Video?
    var delegates: NSHashTable<AnyObject> = NSHashTable.weakObjects()
    
    // MARK: - Initialization
    
    fileprivate init() {
        
    }
    
    // MARK: - Delegate
    
    func add(delegate: CartDelegate) {
        delegates.add(delegate)
    }
    
    // MARK: - Logic
    
    func add(_ image: Image, newlyTaken: Bool = false) {
        guard !images.contains(image) else { return }
        
        images.append(image)
        
        for case let delegate as CartDelegate in delegates.allObjects {
            delegate.cart(self, didAdd: image, newlyTaken: newlyTaken)
        }
    }
    
    func remove(_ image: Image) {
        guard let index = images.index(of: image) else { return }
        
        images.remove(at: index)
        
        for case let delegate as CartDelegate in delegates.allObjects {
            delegate.cart(self, didRemove: image)
        }
    }
    
    func remove(_ index: Int){
        self.remove(self.images[index])
    }
    
    func reload(_ images: [Image]) {
        self.images = images
        
        for case let delegate as CartDelegate in delegates.allObjects {
            delegate.cartDidReload(self)
        }
    }
    
    func getIndex(_ image: Image) -> Int? {
        return self.images.index(where: {$0 == image})
    }
    
    // MARK: - Reset
    
    func reset() {
        video = nil
        images.removeAll()
        delegates.removeAllObjects()
    }
    
    // MARK: - UIImages
    
    func UIImages() -> [UIImage] {
        selectedImages = Fetcher.fetchImages(images.map({ $0.asset }))
        return selectedImages
    }
    
    func singleImage(_ asset: PHAsset) -> UIImage? {
        return Fetcher.fetchImage(asset)
    }
    
    func reload(_ UIImages: [UIImage]) {
        var changedImages: [Image] = []
        
        selectedImages.filter {
            return UIImages.contains($0)
            }.flatMap {
                return selectedImages.index(of: $0)
            }.forEach { index in
                if index < images.count {
                    changedImages.append(images[index])
                }
        }
        
        selectedImages = []
        reload(changedImages)
    }
    
    func assetsUrls() -> [String] {
        var imagesUrl = [String]()
        let fileManager = AppFileManager()
        Fetcher.fetchImages(self.images.map({$0.asset})).forEach { (image) in
            if let path = fileManager.saveImageIntDirectory(image) {
                imagesUrl.append(path)
            }
        }
        return imagesUrl
    }
}

extension PHAsset {
    
    func getURL(completionHandler : @escaping ((_ responseURL : URL?) -> Void)){
        if self.mediaType == .image {
            let options: PHContentEditingInputRequestOptions = PHContentEditingInputRequestOptions()
            options.canHandleAdjustmentData = {(adjustmeta: PHAdjustmentData) -> Bool in
                return true
            }
            self.requestContentEditingInput(with: options, completionHandler: {(contentEditingInput: PHContentEditingInput?, info: [AnyHashable : Any]) -> Void in
                completionHandler(contentEditingInput!.fullSizeImageURL as URL?)
            })
        } else if self.mediaType == .video {
            let options: PHVideoRequestOptions = PHVideoRequestOptions()
            options.version = .original
            PHImageManager.default().requestAVAsset(forVideo: self, options: options, resultHandler: {(asset: AVAsset?, audioMix: AVAudioMix?, info: [AnyHashable : Any]?) -> Void in
                if let urlAsset = asset as? AVURLAsset {
                    let localVideoUrl: URL = urlAsset.url as URL
                    completionHandler(localVideoUrl)
                } else {
                    completionHandler(nil)
                }
            })
        }
    }
}
