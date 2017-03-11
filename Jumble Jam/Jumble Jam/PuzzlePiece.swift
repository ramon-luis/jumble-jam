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
    
    
    var openDirection: OpenDirection {    // which direction piece can move
        didSet {
            updateMovementLimitsForCenterPoint()    // update the movements available to this piece
        }
    }
    var imageView: UIImageView  // the imageview for the puzzle piece
    var correctLocation: Square // the correct gameBoard location of this piece
    var currentLocation: Square {   // the current gameBoard locatoin of this piece
        didSet {
            updateImageView()   // update the location of the imageView (i.e. move the piece visually)
        }
    }
    
    // movement limits for the center point of the puzzlePiece
    var minX: CGFloat = 0
    var maxX: CGFloat = 0
    var minY: CGFloat = 0
    var maxY: CGFloat = 0
    
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
    
    // update the movement limits for this piece
    func updateMovementLimitsForCenterPoint() {
        // get the size of a gameBoardSquare - this is most a piece can move
        let gameBoardSquareDistance = currentLocation.square.width
        
        // set the movement limits based on openDirection
        switch self.openDirection {
            case OpenDirection.up:
                minX = currentLocation.square.midX
                maxX = currentLocation.square.midX
                minY = currentLocation.square.midY - gameBoardSquareDistance
                maxY = currentLocation.square.midY
            case OpenDirection.down:
                minX = currentLocation.square.midX
                maxX = currentLocation.square.midX
                minY = currentLocation.square.midY
                maxY = currentLocation.square.midY + gameBoardSquareDistance

            case OpenDirection.left:
                minX = currentLocation.square.midX - gameBoardSquareDistance
                maxX = currentLocation.square.midX
                minY = currentLocation.square.midY
                maxY = currentLocation.square.midY

            case OpenDirection.right:
                minX = currentLocation.square.midX
                maxX = currentLocation.square.midX + gameBoardSquareDistance
                minY = currentLocation.square.midY
                maxY = currentLocation.square.midY
                
            case OpenDirection.none:
                minX = currentLocation.square.midX
                maxX = currentLocation.square.midX
                minY = currentLocation.square.midY
                maxY = currentLocation.square.midY
        }
    }
    
    func dumpInfo() {
        print("x: \(currentLocation.square.origin.x), y: \(currentLocation.square.origin.y) row: \(currentLocation.row), col: \(currentLocation.col), open: \(openDirection), homeRow: \(correctLocation.row), homeCol: \(correctLocation.col)")
    }
    
}
