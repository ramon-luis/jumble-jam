//
//  PuzzlePiece.swift
//  Jumble Jam
//
//  Created by Ramon RODRIGUEZ on 3/7/17.
//  Copyright © 2017 Ramon Rodriguez. All rights reserved.
//

import UIKit

class PuzzlePiece {
    
    enum OpenDirection {
        case up
        case down
        case left
        case right
        case none
    }
    
    var imageView: UIImageView
    var correctLocation: Int
    var currentLocation: Int
    var openDirection: OpenDirection
    
    init(imageView: UIImageView, correctLocation: Int, currentLocation: Int) {
        self.imageView = imageView
        self.correctLocation = correctLocation
        self.currentLocation = currentLocation
        self.openDirection = OpenDirection.none
    }
    
    func isCorrectLocation() -> Bool {
        return currentLocation == correctLocation
    }
    
}
