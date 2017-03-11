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
    
    // - don't use intersect: instead need to check against max/min x/y during move
    
    //******************************************//
    //***************  Properties **************//
    //******************************************//
    
    // - MARK: Properties
    var originalImageView: UIImageView?
    var originalImage: UIImage?
    var piecesPerRow: Int = 0
    var pieceCount: Int = 0
    var gameBoard = [Square]()
    var imagePieces = [UIImage]()
    var puzzlePieces = [PuzzlePiece]()
    
    let border: CGFloat = 2.0
    var screenWidth: CGFloat = 375  // placeholder
    
    var jumbleView: UIView?
    
    
    @IBOutlet weak var infoView: UIView!
    
    // jumble puzzle pieces
    @IBAction func jumbleButton(_ sender: UIButton) {
        jumblePuzzlePieces()
    }
    
    // solve the puzzle
    @IBAction func solveButton(_ sender: UIButton) {
        solvePuzzle()
    }
    
    
    
    //******************************************//
    //*************  View Did Load *************//
    //******************************************//
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
//        loadInitialImage()
        
        setScreenWidth()
        setJumbleView()
        
        setOriginalImage()
        piecesPerRow = 5
        pieceCount = piecesPerRow * piecesPerRow
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
    
    // shake to jumble puzzle
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if (motion == UIEventSubtype.motionShake) {
            jumblePuzzlePieces()
        }
    }
    
    // create gesture control
    private func createGresture(targetView: UIImageView) {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))
        targetView.addGestureRecognizer(panGesture)
        targetView.isUserInteractionEnabled = true
        print("added user control")
    }
    
    // handle user touch
    func handlePanGesture(recognizer: UIPanGestureRecognizer) {
        // var to hold the puzzlePiece being moved
        var puzzlePiece: PuzzlePiece?
        
        // get the translation
        let translation = recognizer.translation(in: self.view)
        
        // get the view
        if let view = recognizer.view {
            //set the puzzlePiece
            puzzlePiece = getCurrentPuzzlePiece(view: view)
            
            // get open direction
            let openDirection = puzzlePiece?.openDirection

            // vars to identify type of movement: vertical or horizontal
            let isVerticalMove = (openDirection == PuzzlePiece.OpenDirection.up ||
                openDirection == PuzzlePiece.OpenDirection.down)
            let isHorizontalMove = (openDirection == PuzzlePiece.OpenDirection.right ||
                openDirection == PuzzlePiece.OpenDirection.left)
            
            // bring puzzlePiece to front
            view.superview?.bringSubview(toFront: view)

            // move (translate) puzzlePiece based on type of movement: vertical or horizontal
            if isVerticalMove {
                // check if valid move: not out of bounds or colliding with another puzzlePiece
                if (isValidMove(puzzlePiece: puzzlePiece!)) {
                    // vertical movement
                    view.center = CGPoint(x:view.center.x, y:view.center.y + translation.y)
                }
            } else if isHorizontalMove {
                // check if valid move: not out of bounds or colliding with another puzzlePiece
                if (isValidMove(puzzlePiece: puzzlePiece!)) {
                    // horizontal movement
                    view.center = CGPoint(x:view.center.x + translation.x, y:view.center.y)
                }
            }
        }
        
        // reset the translation
        recognizer.setTranslation(CGPoint.zero, in: self.view)
        
        // end of pan gesture
        if (recognizer.state == UIGestureRecognizerState.ended) {
            // set piece in final location -> ANIMATE???
            puzzlePiece?.currentLocation = getClosestGameBoardSquare(puzzlePiece: puzzlePiece!)!
            
            // update open status
            updateOpenDirectionForPuzzlePieces()
            
            print("x: \(recognizer.view?.frame.origin.x), y: \(recognizer.view?.frame.origin.y)")
            // check if end of game
            if (isGameOver()) {
                print("game over: true")
                addMissingPuzzlePiece()
            } else {
                print ("game over: false")
            }
            
            dumpPuzzlePieceInfo()
            
        }
    }
    
    // check if puzzlePiece is intersecting any other puzzle pieces or outside bounds
    private func isValidMove(puzzlePiece: PuzzlePiece) -> Bool {
        // loop through all the puzzle pieces
        for otherPuzzlePiece in puzzlePieces {
            // get the frame for this puzzle piece and that (other) puzzle piece
            let thisRect = puzzlePiece.imageView.frame
            let thatRect = otherPuzzlePiece.imageView.frame
            
            // set booleans to check if valid move
            let isSamePuzzlePiece = (puzzlePiece === otherPuzzlePiece)
            let isIntersection = (thisRect.intersects(thatRect) && !isSamePuzzlePiece)  // check if intersects the rect of other puzzle piece
            let isOutsideBounds = isOutsideJumbleView(frame: thisRect)  // check if outside bounds
            
            // if outside bounds or intersectection then not valid move
//            if (isOutsideBounds || isIntersection) {
                if (isOutsideBounds) {

                return false
            }
        }
        
        // not outside bounds or intersection found: valid move
        return true
    }
    
    
    
    // check if frame is outside of bounds
    private func isOutsideJumbleView(frame: CGRect) -> Bool {
        // set values of x and y boundaries
        let minX: CGFloat = 0
        let minY: CGFloat = 0
        let maxX = minX + (jumbleView?.frame.width)!
        let maxY = minY + (jumbleView?.frame.height)!
        
        // set booleans to check if frame is inside max bounds
        let isOutsideLeftBounds = (frame.origin.x < minX)
        let isOutsideRightBounds = (frame.origin.x + frame.width > maxX)
        let isOutsideUpperBounds = (frame.origin.y < minY)
        let isOutsideLowerBounds = (frame.origin.y + frame.height > maxY)
        
        // return if inside all boundaries
        return (isOutsideLeftBounds || isOutsideRightBounds || isOutsideUpperBounds || isOutsideLowerBounds)
    }
    
    // get closest gameBoardSquare for a puzzlePiece
    private func getClosestGameBoardSquare(puzzlePiece: PuzzlePiece) -> Square? {
        // define var to return the gameboard square that is closest
        var closestGameBoardSquare: Square?
        
        // define the center of the puzzlePiece and var to track closest distance
        let puzzlePieceCenter = puzzlePiece.imageView.center // use center of imageview
        var closestDistance = CGFloat.greatestFiniteMagnitude  // initialize to max value
        
        // loop through all gameboard squares
        for gameBoardSquare in gameBoard {
            // get the center of the square
            let gameBoardSquareCenter = CGPoint(x: gameBoardSquare.square.midX, y: gameBoardSquare.square.midY)
            
            // get the distance from puzzlePiece to this square
            let thisDistance = distance(a: puzzlePieceCenter, b: gameBoardSquareCenter)
            
            // update if this is smallest distance found
            if (thisDistance < closestDistance) {
                closestDistance = thisDistance  // set as new closest distance
                closestGameBoardSquare = gameBoardSquare  // set as new closest square
            }
        }
        
        // return the gameboard square that is closest
        return closestGameBoardSquare
    }
    
    // helper function to calculate distance between two points
    func distance(a: CGPoint, b: CGPoint) -> CGFloat {
        let xDist = a.x - b.x
        let yDist = a.y - b.y
        return CGFloat(sqrt((xDist * xDist) + (yDist * yDist)))
    }
    
    //******************************************//
    //**************  Initialize ***************//
    //******************************************//
    
    private func setScreenWidth() {
        screenWidth = self.view.bounds.size.width
    }
    
    private func setJumbleView() {
        let x: CGFloat = 0
        let y: CGFloat = infoView.frame.height
        let width: CGFloat = screenWidth
        let height: CGFloat = width
        
        let frame = CGRect(x: x, y: y, width: width, height: height)
        jumbleView = UIView(frame: frame)
        jumbleView?.backgroundColor = UIColor.black
        self.view.addSubview(jumbleView!)
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
        return resizeImage(image: image, newWidth: screenWidth)
    }
    
    // resize an image
    // - Attribute: https://gist.github.com/cuxaro/20a5b9bbbccc46180861e01aa7f4a267
    private func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
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
            
            // set the x and y of the the rect: start at origin of jumbleView and adjust based on col/row
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
            let gameBoardSquare = gameBoard[index]
            let frame = gameBoardSquare.square  // square from gameBoard piece
            let imageView = UIImageView(frame: frame)  // create imageview
            imageView.image = imagePieces[index]  // assign image to imageview
            imageView.layer.borderWidth = border // set border width for imageview
            imageView.layer.borderColor = UIColor.black.cgColor  // set border color for imageview
            let puzzlePiece = PuzzlePiece(imageView: imageView, correctLocation: gameBoardSquare, currentLocation: gameBoardSquare)
            puzzlePieces.append(puzzlePiece)
        }
    }
    
    // jumble puzzle pieces
    private func jumblePuzzlePieces() {
        // shuffle the puzzle pieces
        puzzlePieces.shuffle()
        
        // set the current location
        for index in 0...(puzzlePieces.count-1) {
            puzzlePieces[index].currentLocation = gameBoard[index]
        }
    }
    
    // show the puzzle pieces
    private func showPuzzlePieces() {
        for puzzlePiece in puzzlePieces {
            jumbleView?.addSubview(puzzlePiece.imageView)
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
        print("****")
        for piece in puzzlePieces {
            piece.dumpInfo()
        }
    }

    //******************************************//
    //*****  OpenDirection for PuzzlePiece *****//
    //******************************************//
    
    private func updateOpenDirectionForPuzzlePieces() {
        // loop through all puzzle pieces and set open direction to none (default)
        for puzzlePiece in puzzlePieces {
            puzzlePiece.openDirection = PuzzlePiece.OpenDirection.none
        }
        
        // loop through all squares to find one without puzzle piece: update adjacent puzzlePiece's openDirection
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
    
    // get a gameBoard Square based on origin point
    private func getGameBoardSquare(origin: CGPoint) -> Square? {
        // loop through all gameBoard squares
        for gameBoardSquare in gameBoard {
            // check if origin matches
            if (gameBoardSquare.square.origin == origin) {
                return gameBoardSquare
            }
        }
        
        // no match found -> return nil
        return nil
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
            // check if puzzlePiece location matches gameBoardSquare
            if (puzzlePiece.currentLocation === gameBoardSquare) {
                return puzzlePiece
            }
        }
        
        // no match -> return nil
        print("no puzzle piece at row: \(gameBoardSquare.row), col: \(gameBoardSquare.col)")
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
    
    
    //******************************************//
    //************* Handle GamePlay ************//
    //******************************************//
    
    // solve the puzzle
    private func solvePuzzle() {
        // loop through all puzzlePieces
        for puzzlePiece in puzzlePieces {
            // set the current location to be the correct location
            puzzlePiece.currentLocation = puzzlePiece.correctLocation
        }
        addMissingPuzzlePiece()
    }
    
    // check if game is over
    private func isGameOver() -> Bool {
        // loop through all puzzlePieces
        for puzzlePiece in puzzlePieces {
            // if piece is not in correct location, then game not over
            if !puzzlePiece.isCorrectLocation() {
                return false
            }
        }
        // all pieces in correct location: game over
        return true
    }
    
    // add the missing puzzlePiece  *** REMEMBER TO REMOVE LATER ****
    private func addMissingPuzzlePiece() {
        let openGameSquare = gameBoard.last
        let missingImage = imagePieces.last
        let missingImageView = UIImageView(frame: (openGameSquare?.square)!)
        missingImageView.image = missingImage
        missingImageView.alpha = 0.0
        missingImageView.layer.borderWidth = border // set border width for imageview
        missingImageView.layer.borderColor = UIColor.black.cgColor  // set border color for imageview
        jumbleView?.addSubview(missingImageView)
        
        UIView.animate(withDuration: 1.0, delay: 0.0, animations: {
            // bring the missing image into view
            missingImageView.alpha = 1.0
        }, completion: { finished in
            // show complete image
            let finalImageView = UIImageView(image: self.originalImage)
            finalImageView.alpha = 0.0
            self.jumbleView?.addSubview(finalImageView)
            UIView.animate(withDuration: 1.0, delay: 0.0, animations: {
                finalImageView.alpha = 1.0
            }, completion: nil)
            
            
        })
        
    }
    
}

//******************************************//
//**************  Extensions ***************//
//******************************************//

// crop image
// - Attribution: http://stackoverflow.com/questions/39310729/problems-with-cropping-a-uiimage-in-swift
extension UIImage {
    func crop(rect: CGRect) -> UIImage {
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

