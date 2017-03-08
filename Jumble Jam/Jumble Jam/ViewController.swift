//
//  ViewController.swift
//  Jumble Jam
//
//  Created by Ramon RODRIGUEZ on 3/2/17.
//  Copyright © 2017 Ramon Rodriguez. All rights reserved.
//

import UIKit
import GameKit

class ViewController: UIViewController {

    
    // update movement status of pieces
    
    // pan:
    // check if piece can be moved
    // only allow movement in open direction
    // stop movement at border
    // set piece in exact location: use matching gameboard square origin
    // update location of piece: done in above step
    // update movement status of pieces
    
    
    //******************************************//
    //***************  Properties **************//
    //******************************************//
    
    // - MARK: Properties
    var originalImageView: UIImageView?
    var originalImage: UIImage?
    var pieceCount: Int = 0
    var gameBoard = [Square]()
    var imagePieces = [UIImage]()
    var puzzlePieces = [PuzzlePiece]()
    let border: CGFloat = 2.0
    
    @IBOutlet weak var jumbleView: UIView!
    
    //******************************************//
    //*************  View Did Load *************//
    //******************************************//
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
//        loadInitialImage()
        
        setOriginalImage()
        pieceCount = 9
        setGameBoard()
        setImagePieces()
        createPuzzlePieces()
        jumblePuzzlePieces()
        showPuzzlePieces()
        updateOpenDirectionForPuzzlePieces()
        addPlayerControl()
        dumpPuzzlePieceInfo()
    }

    //******************************************//
    //************  Gesture Control ************//
    //******************************************//
    
    // create gesture control
    private func createGresture(targetView: UIImageView) {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))
        targetView.addGestureRecognizer(panGesture)
        targetView.isUserInteractionEnabled = true
    }
    
    // handle user touch
    func handlePanGesture(recognizer: UIPanGestureRecognizer) {
        // update the imageView based on user panning
        let translation = recognizer.translation(in: self.view)
        if let view = recognizer.view {
            
            if (getCurrentPuzzlePiece(view: view)?.openDirection != PuzzlePiece.OpenDirection.none) {
                view.superview?.bringSubview(toFront: view)
                
                // horizontal movement
    //            view.center = CGPoint(x:view.center.x + translation.x,
    //                                  y:view.center.y + translation.y)
                
                // vertical movement
                view.center = CGPoint(x:view.center.x,
                                      y:view.center.y + translation.y)
            }
        }
        recognizer.setTranslation(CGPoint.zero, in: self.view)
    }

    //******************************************//
    //************  Original Image *************//
    //******************************************//
    
    // set the original image (i.e. image that is split into puzzle pieces)
    private func setOriginalImage() {
        originalImage = resizeToScreenSize(image: #imageLiteral(resourceName: "skyline"))  // resize to fit square screen size
    }
    
    // resize an image to the screen size
    private func resizeToScreenSize(image: UIImage)->UIImage{
        let screenSize = self.view.bounds.size
        return resizeImage(image: image, newWidth: screenSize.width)
    }
    
    // resize an image
    // - Attribute: https://gist.github.com/cuxaro/20a5b9bbbccc46180861e01aa7f4a267
    private func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        
        image.draw(in: CGRect(x: 0, y: 0,width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    //******************************************//
    //****  Setup GameBoard & PuzzlePieces *****//
    //******************************************//
    
    // set the gameboard: grid of squares stored in array
    private func setGameBoard() {
        // remove existing gameboard squares
        gameBoard.removeAll()
        
        // set vars to track rectangle (piece) location
        let piecesPerRow = Int(sqrt(Double(pieceCount)))
        let piecesPerCol = piecesPerRow
        var pieceIndex = 0
        var rowIndex = 0
        var colIndex = 0
        
        // set dimensions for rectangles
        let screenWidth = self.view.bounds.size.width
        let width: CGFloat = screenWidth / CGFloat(piecesPerRow)
        let height: CGFloat = width
        
        // create rectangles
        while (pieceIndex < pieceCount) {
            // check if need to start new row (i.e. col resets)
            if (colIndex == piecesPerCol) {
                colIndex = 0  // go to far left
                rowIndex += 1  // move one row down
            }
            
            // set the x and y of the the rect
            let x = 0 + CGFloat(colIndex) * width
            let y = 0 + CGFloat(rowIndex) * width
            
            // create the rect and add to array
            let rect = CGRect(x: x, y: y, width: width, height: height)
            let square = Square(square: rect, row: rowIndex, col: colIndex)
            gameBoard.append(square)
            
            // update tracking params
            colIndex += 1   // move one col to the right
            pieceIndex += 1  // increment number of splits formed
        }
    }
    
    // get the images for puzzle pieces: cropped from original image based on piece rectangles
    private func setImagePieces() {
        // clear all existing images
        imagePieces.removeAll()
        
        // loop through rectangles and create cropped image
        for gameBoardPiece in gameBoard {
            let square = gameBoardPiece.square  // set square that determines crop
            let image = originalImage?.crop(rect: square)  // create image crop
            imagePieces.append(image!)  // add image to array
        }
    }
    
    // create puzzle pieces
    private func createPuzzlePieces() {
        // set max index based on number of gameboard squares
        let maxIndex = gameBoard.count - 2  // -1 to get correct index, -1 again to skip last image (bottom right corner = empty)
        
        // create a puzzlePiece for each gameboard square except bottom right
        for index in 0...maxIndex {
            let square = gameBoard[index].square  // square from gameBoard piece
            let imageView = UIImageView(frame: square)  // create imageview
            imageView.image = imagePieces[index]  // assign image to imageview
            imageView.layer.borderWidth = border // set border width for imageview
            imageView.layer.borderColor = UIColor.black.cgColor  // set border color for imageview
            let puzzlePiece = PuzzlePiece(imageView: imageView, correctLocation: index, currentLocation: index)
            puzzlePieces.append(puzzlePiece)
        }
    }
    
    // jumble puzzle pieces
    private func jumblePuzzlePieces() {
        // set max index based on number of puzzles pieces
        let maxIndex = puzzlePieces.count - 1
        
        // shuffle the puzzle pieces
        puzzlePieces.shuffle()
        
        // // update the current location and frame location for each puzzle piece
        for index in 0...maxIndex {
            puzzlePieces[index].currentLocation = index
            puzzlePieces[index].imageView.frame.origin = gameBoard[index].square.origin
        }
    }
    
    // show the puzzle pieces
    private func showPuzzlePieces() {
        for puzzlePiece in puzzlePieces {
            jumbleView.addSubview(puzzlePiece.imageView)
        }
    }
    
    // add touch control for puzzle pieces
    private func addPlayerControl() {
        for puzzlePiece in puzzlePieces {
            createGresture(targetView: puzzlePiece.imageView)
        }
    }
    
    // dump info about each puzzle piece to console
    private func dumpPuzzlePieceInfo() {
        for piece in puzzlePieces {
            print("current location: \(piece.currentLocation), correct location: \(piece.correctLocation), status: \(piece.isCorrectLocation()), open: \(piece.openDirection)")
        }
    }

    //******************************************//
    //*****  OpenDirection for PuzzlePiece *****//
    //******************************************//
    
    private func updateOpenDirectionForPuzzlePieces() {
        // loop through all squares
        for gameBoardSquare in gameBoard {
            // if there is no puzzle piece, then this is an empty gameBoard square: update adjacent squares
            if !hasPuzzlePiece(gameBoardSquare: gameBoardSquare) {
                updateAdjacentPieceStatus(gameBoardSquare: gameBoardSquare) // set adjacent squares as able to move here
            }
        }
    }
    
    // update the status of adjacent pieces: left, right, up, down
    private func updateAdjacentPieceStatus(gameBoardSquare: Square) {
        // get the current row and col
        let row = gameBoardSquare.row
        let col = gameBoardSquare.col
        
        // left piece: get square first (if not nil)
        if let leftSquare = getGameBoardSquare(row: row, col: col - 1) {
            let leftPuzzlePiece = getCurrentPuzzlePiece(gameBoardSquare: leftSquare)  // get the puzzle piece
            leftPuzzlePiece?.openDirection = PuzzlePiece.OpenDirection.right  // open direction is opposite direction
        }
        
        // right piece: get square first (if not nil)
        if let rightSquare = getGameBoardSquare(row: row, col: col + 1) {
            let rightPuzzlePiece = getCurrentPuzzlePiece(gameBoardSquare: rightSquare)  // get the puzzle piece
            rightPuzzlePiece?.openDirection = PuzzlePiece.OpenDirection.left  // open direction is opposite direction
        }
        
        // up piece: get square first (if not nil)
        if let upSquare = getGameBoardSquare(row: row - 1, col: col) {
            let upPuzzlePiece = getCurrentPuzzlePiece(gameBoardSquare: upSquare)  // get the puzzle piece
            upPuzzlePiece?.openDirection = PuzzlePiece.OpenDirection.down  // open direction is opposite direction
        }
        
        // down piece: get square first (if not nil)
        if let downSquare = getGameBoardSquare(row: row + 1, col: col) {
            let downPuzzlePiece = getCurrentPuzzlePiece(gameBoardSquare: downSquare)  // get the puzzle piece
            downPuzzlePiece?.openDirection = PuzzlePiece.OpenDirection.up  // open direction is opposite direction
        }
    }
    
    // get a gameBoard Square based on a row and col
    private func getGameBoardSquare(row: Int, col: Int) -> Square? {
        // loop through all gameBoard squares
        for gameBoardSquare in gameBoard {
            // check if row and col match
            if (gameBoardSquare.row == row && gameBoardSquare.col == col) {
                return gameBoardSquare
            }
        }
        
        // no match found -> return nil
        return nil
    }
    
    // get the puzzle piece that is currently in a given gameBoardSquare
    private func getCurrentPuzzlePiece(gameBoardSquare: Square) -> PuzzlePiece? {
        // loop through all puzzlePieces
        for puzzlePiece in puzzlePieces {
            // check if imageview origin on puzzlePiece matches gameBoardSquare origin
            if (puzzlePiece.imageView.frame.origin == gameBoardSquare.square.origin) {
                return puzzlePiece
            }
        }
        
        // no match -> return nil
        return nil
    }
    
    // check if gameBoardSquare has a puzzlePiece
    private func hasPuzzlePiece(gameBoardSquare: Square) -> Bool {
        return getCurrentPuzzlePiece(gameBoardSquare: gameBoardSquare) != nil
    }
    
    // get the puzzle piece based on an imageView
    private func getCurrentPuzzlePiece(view: UIView) -> PuzzlePiece? {
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
    

    
}

// - Attribution: http://stackoverflow.com/questions/39310729/problems-with-cropping-a-uiimage-in-swift
extension UIImage {
    func crop( rect: CGRect) -> UIImage {
        var rect = rect
        rect.origin.x*=self.scale
        rect.origin.y*=self.scale
        rect.size.width*=self.scale
        rect.size.height*=self.scale
        
        let imageRef = self.cgImage!.cropping(to: rect)
        let image = UIImage(cgImage: imageRef!, scale: self.scale, orientation: self.imageOrientation)
        return image
    }
    
    
    
    
    
}

//******************************************//
//**************  Extensions ***************//
//******************************************//

// shuffle a collection
// - Attribution: http://stackoverflow.com/questions/24026510/how-do-i-shuffle-an-array-in-swift/24029847#24029847
extension MutableCollection where Indices.Iterator.Element == Index {
    /// Shuffles the contents of this collection.
    mutating func shuffle() {
        let c = count
        guard c > 1 else { return }
        
        for (firstUnshuffled , unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
            let d: IndexDistance = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
            guard d != 0 else { continue }
            let i = index(firstUnshuffled, offsetBy: d)
            swap(&self[firstUnshuffled], &self[i])
        }
    }
}

extension Sequence {
    /// Returns an array with the contents of this sequence, shuffled.
    func shuffled() -> [Iterator.Element] {
        var result = Array(self)
        result.shuffle()
        return result
    }
}

