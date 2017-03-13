//
//  GameBoard.swift
//  Jumble Jam
//
//  Created by Ramon RODRIGUEZ on 3/9/17.
//  Copyright © 2017 Ramon Rodriguez. All rights reserved.
//

import UIKit

class GameBoard {
    
    // difficulty (# of pieces per row)
    enum Difficulty: Int {
        case Easy = 3
        case Medium = 4
        case Hard = 5
        case Extreme = 6
    }
    
    // - MARK: Properties
    var difficulty: Difficulty = Difficulty.Easy
    var screenWidth: CGFloat = 375  // placeholder
    var squares = [Square]()    // gameboard squares
    var puzzleImage: UIImage?      // unscrambled image
    var pieceCount: Int = 0
    var imagePieces = [UIImage]()
    var puzzlePieces = [PuzzlePiece]()
    let borderWidth: CGFloat = 2.0
    let borderColor: CGColor = UIColor.white.cgColor
    var piecesPerRow: Int = 0 {
        didSet {
            pieceCount = piecesPerRow * piecesPerRow
        }
    }
    
    // singleton
    static let sharedInstance = GameBoard()
    private init() {}
    
    // create a gameBoard
    func create(screenWidth: CGFloat, puzzleImage: UIImage, difficulty: Difficulty) {
        self.screenWidth = screenWidth
        self.puzzleImage = puzzleImage
        self.difficulty = difficulty
        self.piecesPerRow = difficulty.rawValue
        self.pieceCount = piecesPerRow * piecesPerRow
        createData()
    }
    
    // update gameboard based on new difficulty
    func updateDifficulty(difficulty: Difficulty) {
        self.difficulty = difficulty
        piecesPerRow = difficulty.rawValue
        reset()
    }
    
    // update gameboard based on new image
    func updateImage(puzzleImage: UIImage) {
        self.puzzleImage = puzzleImage
        reset()
    }

    // update the open direction for puzzle pieces
    func updateOpenDirectionForPuzzlePieces() {
        // loop through all puzzle pieces and set open direction to none (default)
        for puzzlePiece in puzzlePieces {
            puzzlePiece.openDirection = PuzzlePiece.OpenDirection.none
        }
        
        // loop through all squares to find one without puzzle piece: update adjacent puzzlePiece's openDirection
        for square in squares {
            // if there is no puzzle piece, then this is an empty gameBoard square: update adjacent squares
            if !hasPuzzlePiece(square: square) {
                updateAdjacentPieceStatus(square: square) // set adjacent squares as able to move here
            }
        }
    }
    
    // get the puzzle piece based on an imageView
    func getCurrentPuzzlePiece(view: UIView) -> PuzzlePiece? {
        // loop through all puzzlePieces
        for puzzlePiece in puzzlePieces {
            // check if imageview origin on puzzlePiece matches gameBoardSquare origin
            if (puzzlePiece.imageView.frame.origin == view.frame.origin) {
                return puzzlePiece
            }
        }
        
        // no match -> return nil
        return nil
    }
    
    // get closest gameBoardSquare for a puzzlePiece
    func getClosestGameBoardSquare(puzzlePiece: PuzzlePiece) -> Square? {
        // define var to return the gameboard square that is closest
        var closestSquare: Square?
        
        // define the center of the puzzlePiece and var to track closest distance
        let puzzlePieceCenter = puzzlePiece.imageView.center // use center of imageview
        var closestDistance = CGFloat.greatestFiniteMagnitude  // initialize to max value
        
        // loop through all gameboard squares
        for square in squares {
            // get the center of the square
            let squareCenter = CGPoint(x: square.square.midX, y: square.square.midY)
            
            // get the distance from puzzlePiece to this square
            let thisDistance = distance(a: puzzlePieceCenter, b: squareCenter)
            
            // update if this is smallest distance found
            if (thisDistance < closestDistance) {
                closestDistance = thisDistance  // set as new closest distance
                closestSquare = square  // set as new closest square
            }
        }
        
        // return the gameboard square that is closest
        return closestSquare
    }
    
    // solve the puzzle
    func solvePuzzle() {
        // loop through all puzzlePieces
        for puzzlePiece in puzzlePieces {
            // set the current location to be the correct location
            puzzlePiece.currentLocation = puzzlePiece.correctLocation
        }
    }
    
    // check if puzzle is solved
    func isSolved() -> Bool {
        // loop through all puzzlePieces
        for puzzlePiece in puzzlePieces {
            // check if in wrong location
            if !puzzlePiece.isCorrectLocation() {
                return false
            }
        }
        
        // no pieces in wrong location: solved
        return true
    }

    
    // ****** PRIVATE BELOW ******
    
    // reset the gameBoard
    private func reset() {
        removeData()
        createData()
    }
    // create gameBoard data
    private func createData() {
        createSquares()
        createImagePieces()
        createPuzzlePieces()
        updateOpenDirectionForPuzzlePieces()
    }
    
    // remove gameBoard data
    private func removeData() {
        squares.removeAll()
        imagePieces.removeAll()
        puzzlePieces.removeAll()
    }
    
    // set the gameboard: grid of squares stored in array
    private func createSquares() {
        // set vars to track rectangle (piece) location
        let piecesPerCol = piecesPerRow
        var pieceIndex = 0
        var rowIndex = 0
        var colIndex = 0
        
        // set dimensions for rectangles
        let width: CGFloat = screenWidth / CGFloat(piecesPerRow)
        let height: CGFloat = width
        
        // create rectangles
        while (pieceIndex < pieceCount) {
            // check if need to start new row (i.e. col resets)
            if (colIndex == piecesPerCol) {
                colIndex = 0  // go to far left
                rowIndex += 1  // move one row down
            }
            
            // set the x and y of the the rect: start at origin of jumbleView and adjust based on col/row
            let x = 0 + CGFloat(colIndex) * width
            let y = 0 + CGFloat(rowIndex) * width
            
            // create the rect and add to array
            let rect = CGRect(x: x, y: y, width: width, height: height)
            let square = Square(square: rect, row: rowIndex, col: colIndex)
            squares.append(square)
            
            // update tracking params
            colIndex += 1   // move one col to the right
            pieceIndex += 1  // increment number of splits formed
        }
    }

    // create the images for puzzle pieces: cropped from original image based on squares
    private func createImagePieces() {
        if puzzleImage != nil {
            // clear all existing images
            imagePieces.removeAll()
            
            // loop through rectangles and create cropped image
            for square in squares {
                let square = square.square  // set square that determines crop
                let imagePiece = puzzleImage?.crop(rect: square)  // create image crop
                imagePieces.append(imagePiece!)  // add image to array
            }
        }
    }
    
    // create puzzle pieces
    private func createPuzzlePieces() {
        // set max index based on number of gameboard squares
        let maxIndex = squares.count - 2  // -1 to get correct index, -1 again to skip last image (bottom right corner = empty)
        
        // create a puzzlePiece for each gameboard square except bottom right
        for index in 0...maxIndex {
            let square = squares[index]
            let frame = square.square  // square from gameBoard piece
            let imageView = UIImageView(frame: frame)  // create imageview
            imageView.image = imagePieces[index]  // assign image to imageview
            imageView.layer.borderWidth = borderWidth // set border width for imageview
            imageView.layer.borderColor = borderColor  // set border color for imageview
            let puzzlePiece = PuzzlePiece(imageView: imageView, correctLocation: square, currentLocation: square)
            puzzlePieces.append(puzzlePiece)
        }
    }
    
    // check if square has a puzzlePiece
    private func hasPuzzlePiece(square: Square) -> Bool {
        return getCurrentPuzzlePiece(square: square) != nil
    }

    // update the status of adjacent pieces: left, right, up, down
    private func updateAdjacentPieceStatus(square: Square) {
        // get the current row and col
        let row = square.row
        let col = square.col
        
        // left piece: get square first (if not nil)
        if let leftSquare = getSquare(row: row, col: col - 1) {
            let leftPuzzlePiece = getCurrentPuzzlePiece(square: leftSquare)  // get the puzzle piece
            leftPuzzlePiece?.openDirection = PuzzlePiece.OpenDirection.right  // open direction is opposite direction
        }
        
        // right piece: get square first (if not nil)
        if let rightSquare = getSquare(row: row, col: col + 1) {
            let rightPuzzlePiece = getCurrentPuzzlePiece(square: rightSquare)  // get the puzzle piece
            rightPuzzlePiece?.openDirection = PuzzlePiece.OpenDirection.left  // open direction is opposite direction
        }
        
        // up piece: get square first (if not nil)
        if let upSquare = getSquare(row: row - 1, col: col) {
            let upPuzzlePiece = getCurrentPuzzlePiece(square: upSquare)  // get the puzzle piece
            upPuzzlePiece?.openDirection = PuzzlePiece.OpenDirection.down  // open direction is opposite direction
        }
        
        // down piece: get square first (if not nil)
        if let downSquare = getSquare(row: row + 1, col: col) {
            let downPuzzlePiece = getCurrentPuzzlePiece(square: downSquare)  // get the puzzle piece
            downPuzzlePiece?.openDirection = PuzzlePiece.OpenDirection.up  // open direction is opposite direction
        }
    }
    
    // get the puzzle piece that is currently in a given square
    private func getCurrentPuzzlePiece(square: Square) -> PuzzlePiece? {
        // loop through all puzzlePieces
        for puzzlePiece in puzzlePieces {
            // check if puzzlePiece location matches gameBoardSquare
            if (puzzlePiece.currentLocation === square) {
                return puzzlePiece
            }
        }
        
        // no match -> return nil
        print("no puzzle piece at row: \(square.row), col: \(square.col)")
        return nil
        
    }
    
    // get a square based on a row and col
    private func getSquare(row: Int, col: Int) -> Square? {
        // loop through all gameBoard squares
        for square in squares {
            // check if row and col match
            if (square.row == row && square.col == col) {
                return square
            }
        }
        
        // no match found -> return nil
        return nil
    }
    
    // helper function to calculate distance between two points
    private func distance(a: CGPoint, b: CGPoint) -> CGFloat {
        let xDist = a.x - b.x
        let yDist = a.y - b.y
        return CGFloat(sqrt((xDist * xDist) + (yDist * yDist)))
    }
    
    // dump info about each puzzle piece to console
    private func dumpPuzzlePieceInfo() {
        print("****")
        for piece in puzzlePieces {
            piece.dumpInfo()
        }
    }
    
}
