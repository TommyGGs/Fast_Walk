//
//  ImageCache.swift
//  Fast_Walk
//
//  Created by Tom  on 2024/01/03.
//

import UIKit

class ImageCache {
    static let shared = NSCache<NSURL, UIImage>()

    static func getImage(url: NSURL) -> UIImage? {
        return shared.object(forKey: url)
    }

    static func setImage(url: NSURL, image: UIImage) {
        shared.setObject(image, forKey: url)
    }
}

