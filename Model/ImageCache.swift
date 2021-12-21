//
//  ImageCache.swift
//  Git-it
//
//  Created by 정성훈 on 2021/06/03.
//

import UIKit
import Foundation

class ImageCache {
    private init() {}
    
    static let shared: ImageCache = ImageCache()
    private let cachedImages = NSCache<NSURL, UIImage>()
    
    func image(url: URL) -> UIImage? {
        let url = url as NSURL
        return cachedImages.object(forKey: url)
    }
    
    func load(url: URL, completionHandler: @escaping (UIImage?) -> Void ) {
        if let image = self.image(url: url) {
            DispatchQueue.main.async {
                completionHandler(image)
            }
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if error != nil {
                DispatchQueue.main.async {
                    completionHandler(nil)
                    return
                }
            }
            
            if let httpResponse = response as? HTTPURLResponse,
               (200...399).contains(httpResponse.statusCode),
               let imageData = data {
                DispatchQueue.main.async {
                    guard let image = UIImage(data: imageData) else {
                        completionHandler(nil)
                        return
                    }
                    self.cachedImages.setObject(image, forKey: url as NSURL)
                    completionHandler(image)
                    return
                }
            }
        }.resume()
    }
}
