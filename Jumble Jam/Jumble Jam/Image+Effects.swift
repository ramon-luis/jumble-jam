//
//  Image+Effects.swift
//  Jumble Jam
//
//  Created by Ramon RODRIGUEZ on 3/11/17.
//  Copyright © 2017 Ramon Rodriguez. All rights reserved.
//

import UIKit

// crop image
// - Attribution: http://stackoverflow.com/questions/39310729/problems-with-cropping-a-uiimage-in-swift
extension UIImage {
    func crop(rect: CGRect) -> UIImage {
        // set params
        var rect = rect
        rect.origin.x*=self.scale
        rect.origin.y*=self.scale
        rect.size.width*=self.scale
        rect.size.height*=self.scale
        
        print("cropping to w: \(rect.size.width), h: \(rect.size.height)")
        
        // crop & return the image
        let imageRef = self.cgImage!.cropping(to: rect)
        let image = UIImage(cgImage: imageRef!, scale: self.scale, orientation: self.imageOrientation)
        return image
    }
    
    // crop to square
    func cropToSquare() -> UIImage {
        let imageWidth = self.size.width
        let imageHeight = self.size.height
        let width =  min(imageWidth, imageHeight)
        let height = width
        
        let origin = CGPoint(x: (imageWidth - width) / 2, y: (imageHeight - height) / 2)
        let size = CGSize(width: width, height: height)
        let frame = CGRect(origin: origin, size: size)
        let squareImage = self.crop(rect: frame)
        return squareImage
    }
    
    // resize an image
    // - Attribute: https://gist.github.com/cuxaro/20a5b9bbbccc46180861e01aa7f4a267
    func resize(newWidth: CGFloat) -> UIImage {
        let scale = newWidth / self.size.width
        let newHeight = self.size.height * scale
        
        print("new image w: \(newWidth), h: \(newHeight)")
        
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        self.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    

}
