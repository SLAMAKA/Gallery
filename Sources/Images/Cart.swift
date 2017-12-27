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
    fileprivate var lightBoxUIImages: [UIImage] = []
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
        lightBoxUIImages = Fetcher.fetchImages(images.map({ $0.asset }))
        return lightBoxUIImages
    }
    
    func singleImage(_ asset: PHAsset) -> UIImage? {
        return Fetcher.fetchImage(asset)
    }
    
    func reload(_ UIImages: [UIImage]) {
        var changedImages: [Image] = []
        
        lightBoxUIImages.filter {
            return UIImages.contains($0)
            }.flatMap {
                return lightBoxUIImages.index(of: $0)
            }.forEach { index in
                if index < images.count {
                    changedImages.append(images[index])
                }
        }
        
        lightBoxUIImages = []
        reload(changedImages)
    }
}
