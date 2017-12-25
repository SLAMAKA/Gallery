import UIKit
import AVKit
import AVFoundation

open class LightboxConfig {

  public typealias LoadImageCompletion = (_ error: NSError?, _ image: UIImage?) -> Void

  open static var hideStatusBar = true

  open static var loadImage: (_ imageView: UIImageView, _ URL: URL, _ httpHeaders: [String: String]?, _ completion: LoadImageCompletion?) -> Void = {
    imageView, URL, httpHeaders, completion in
        
    var imageRequest: URLRequest = URLRequest(url: URL)
    imageRequest.allHTTPHeaderFields = httpHeaders

    NSURLConnection.sendAsynchronousRequest(imageRequest,
      queue: OperationQueue.main,
      completionHandler: { response, data, error in
        if let data = data, let image = UIImage(data: data) {
          imageView.image = image
        }

        completion?(error as NSError?, imageView.image)
    })
  }

  open static var handleVideo: (_ from: UIViewController, _ videoURL: URL) -> Void = { from, videoURL in
    let videoController = AVPlayerViewController()
    videoController.player = AVPlayer(url: videoURL)

    from.present(videoController, animated: true) {
      videoController.player?.play()
    }
  }

  public struct PageIndicator {
    public static var enabled = true
    public static var separatorColor = UIColor(hex: "3D4757")

    public static var textAttributes = [
      NSFontAttributeName: UIFont.systemFont(ofSize: 12),
      NSForegroundColorAttributeName: UIColor(hex: "899AB8"),
      NSParagraphStyleAttributeName: {
        var style = NSMutableParagraphStyle()
        style.alignment = .center
        return style
        }()
    ]
  }

  public struct CloseButton {
    public static var enabled = true
    public static var size: CGSize?
    public static var text = NSLocalizedString("Close", comment: "")
    public static var image: UIImage?

    public static var textAttributes = [
      NSFontAttributeName: UIFont.boldSystemFont(ofSize: 16),
      NSForegroundColorAttributeName: UIColor.white,
      NSParagraphStyleAttributeName: {
        var style = NSMutableParagraphStyle()
        style.alignment = .center
        return style
        }()
    ]
  }

    public struct ConversationNameLabel {
        public static var enabled = true
        public static var text: String = NSLocalizedString("Conversation label", comment: "")
        
        public static var textAttributes = [
            NSFontAttributeName: UIFont.boldSystemFont(ofSize: 14),
            NSForegroundColorAttributeName: UIColor.white,
            NSParagraphStyleAttributeName: {
                var style = NSMutableParagraphStyle()
                style.alignment = .left
                return style
            }()
        ]
    }
    
    public struct SelectedFileCountLabel {
        public static var enabled = true
        public static var text: String = NSLocalizedString("Set File count", comment: "")
        
        public static var textAttributes = [
            NSFontAttributeName: UIFont.boldSystemFont(ofSize: 14),
            NSForegroundColorAttributeName: UIColor.white,
            NSParagraphStyleAttributeName: {
                var style = NSMutableParagraphStyle()
                style.alignment = .left
                return style
            }()
        ]
    }
    
    public struct SendButton {
        public static var enabled = true
        public static var size: CGSize?
        public static var text = NSLocalizedString("Send", comment: "")
        public static var image: UIImage?
        
        public static var textAttributes = [
            NSFontAttributeName: UIFont.boldSystemFont(ofSize: 16),
            NSForegroundColorAttributeName: UIColor.white,
            NSParagraphStyleAttributeName: {
                var style = NSMutableParagraphStyle()
                style.alignment = .center
                return style
            }()
        ]
    }
    
    public struct AddButton {
        public static var enabled = true
        public static var size: CGSize?
        public static var text = NSLocalizedString("Add", comment: "")
        public static var image: UIImage? 
        
        public static var textAttributes = [
            NSFontAttributeName: UIFont.boldSystemFont(ofSize: 16),
            NSForegroundColorAttributeName: UIColor.white,
            NSParagraphStyleAttributeName: {
                var style = NSMutableParagraphStyle()
                style.alignment = .center
                return style
            }()
        ]
    }
    
    
    public struct CancelButton {
        public static var enabled = true
        public static var size: CGSize?
        public static var text = NSLocalizedString("Cancel", comment: "")
        public static var image: UIImage?
        
        public static var textAttributes = [
            NSFontAttributeName: UIFont.boldSystemFont(ofSize: 16),
            NSForegroundColorAttributeName: UIColor.white,
            NSParagraphStyleAttributeName: {
                var style = NSMutableParagraphStyle()
                style.alignment = .center
                return style
            }()
        ]
    }
    
    public struct MessageTextView {
        public static var enabled = true
        public static var size: CGSize?
        public static var placeholderText = NSLocalizedString("Add a caption ...", comment: "")
        public static var image: UIImage?
        
        public static var textAttributes = [
            NSFontAttributeName: UIFont.boldSystemFont(ofSize: 15),
            NSForegroundColorAttributeName: UIColor.white,
            NSParagraphStyleAttributeName: {
                var style = NSMutableParagraphStyle()
                style.alignment = .center
                return style
            }()
        ]
    }

  public struct DeleteButton {
    public static var enabled = true
    public static var size: CGSize?
    public static var text = NSLocalizedString("Delete", comment: "")
    public static var image: UIImage? = UIImage.init(named: "photo_delete")

    public static var textAttributes = [
      NSFontAttributeName: UIFont.boldSystemFont(ofSize: 16),
      NSForegroundColorAttributeName: UIColor.white,
      NSParagraphStyleAttributeName: {
        var style = NSMutableParagraphStyle()
        style.alignment = .center
        return style
        }()
    ]
  }

  public struct InfoLabel {
    public static var enabled = true
    public static var textColor = UIColor.white
    public static var ellipsisText = NSLocalizedString("Show more", comment: "")
    public static var ellipsisColor = UIColor(hex: "899AB9")

    public static var textAttributes = [
      NSFontAttributeName: UIFont.systemFont(ofSize: 12),
      NSForegroundColorAttributeName: UIColor(hex: "DBDBDB")
    ]
  }

  public struct Zoom {
    public static var minimumScale: CGFloat = 1.0
    public static var maximumScale: CGFloat = 3.0
  }
  
  public struct LoadingIndicator {
    public static var configure: ((UIActivityIndicatorView) -> Void)? = nil
  }
}
