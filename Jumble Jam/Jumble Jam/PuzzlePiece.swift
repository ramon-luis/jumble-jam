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
    
    var openDirection: OpenDirection
    var imageView: UIImageView
    var correctLocation: Square
    var currentLocation: Square {
        didSet {
            updateImageView()
        }
    }
    
    
    init(imageView: UIImageView, correctLocation: Square, currentLocation: Square) {
        self.imageView = imageView
        self.correctLocation = correctLocation
        self.currentLocation = currentLocation
        self.openDirection = OpenDirection.none
    }
    
    func isCorrectLocation() -> Bool {
        return (self.currentLocation === self.correctLocation)  // DO I NEED TO IMPLEMENT EQUATABLE?
    }
    
    // update the imageView when the location is updated
    func updateImageView() {
        self.imageView.frame = currentLocation.square
    }
    
    func dumpInfo() {
        print("row: \(currentLocation.row), col: \(currentLocation.col), open: \(openDirection), homeRow: \(correctLocation.row), homeCol: \(correctLocation.col)")
    }
    
}
