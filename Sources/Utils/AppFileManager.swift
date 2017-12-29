//
//  AppFileManager.swift
//  Gallery
//
//  Created by Rakish Shalkar on 30.12.17.
//

import Foundation

public class AppFileManager {
    public init() {}
    
    func saveImageIntDirectory(_ image: UIImage) -> String? {
        if let data = UIImagePNGRepresentation(image) {
            do {
                let imagePath = NSTemporaryDirectory().appending("\(UUID.init().uuidString).png")
                try data.write(to: URL.init(fileURLWithPath: imagePath))
                return imagePath
            }catch let error {
                print("Exception in AppFileManager saveImageIntDirectory \(error.localizedDescription)")
                return nil
            }
        }
        return nil
    }
    
    public func getImageFromTemporaryAndThenDeleteImage(_ url: String) -> UIImage? {
        let  image = UIImage.init(contentsOfFile: url)
        self.deleteFile(url)
        return image
    }
    
    func deleteFile(_ url: String) {
        if FileManager.default.fileExists(atPath: url) {
            try? FileManager.default.removeItem(atPath: url)
        }
    }
}
