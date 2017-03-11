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
    
    // variables
    var jumbleView: UIView?
    var screenWidth: CGFloat = 375  // placeholder
    var puzzleImageView: UIImageView?
    var puzzleImage: UIImage?
    var gameBoard = [Square]()
    var imagePieces = [UIImage]()
    var puzzlePieces = [PuzzlePiece]()
    let borderWidth: CGFloat = 2.0
    let borderColor: CGColor = UIColor.white.cgColor
    var piecesPerRow: Int = 0 {
        didSet {
            pieceCount = piecesPerRow * piecesPerRow
        }
    }
    
    @IBOutlet weak var picturesView: UIView!
    @IBOutlet weak var picturesHeaderView: UIView!
    @IBOutlet weak var picturesCollectionView: UICollectionView!
    let reuseIdentifier = "PictureCell"
    let sectionInsets = UIEdgeInsets(top: 15.0, left: 15.0, bottom: 15.0, right: 15.0)  // collectionView formatting
    let itemsPerRow: CGFloat = 1    // collectionView formatting
    var pictures = [UIImage]()
    var puzzleCount = 43
    
    
    // difficulty: # of pieces per row & col
    let easy: Int = 3
    let medium: Int = 4
    let hard: Int = 5
    let extreme: Int = 6
    var pieceCount: Int = 0
    var difficultyButtons = [UIButton]()
    
    // outlets
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var difficultyView: UIView!
    @IBOutlet weak var easyButton: UIButton!
    @IBOutlet weak var mediumButton: UIButton!
    @IBOutlet weak var hardButton: UIButton!
    @IBOutlet weak var extremeButton: UIButton!
    @IBOutlet weak var jumbleButton: UIButton!
    @IBOutlet weak var powerUpButton: UIButton!

   
    
    // buttons
    @IBAction func pictureButton(_ sender: UIButton) {
        // show collection view controller
        // existing images: some disabled
        // add photo from camera or photo roll
        
        showPictures()
    }
    @IBAction func difficultyButton(_ sender: UIButton) {
        // reveal difficulty view
        toggleDifficultyView()
    }
    
    @IBAction func infoButton(_ sender: UIButton) {
        // show instructions view
    }
    
    @IBAction func settingsButton(_ sender: UIButton) {
        // show settings view
    }
    
    @IBAction func easyButton(_ sender: UIButton) {
        difficultySelected(sender: sender)
        piecesPerRow = easy
        clearPuzzle()
        if let image = puzzleImage {
            setPuzzle(picture: image)
        }
        toggleDifficultyView()
    }
    
    @IBAction func mediumButton(_ sender: UIButton) {
        difficultySelected(sender: sender)
        piecesPerRow = medium
        clearPuzzle()
        if let image = puzzleImage {
            setPuzzle(picture: image)
        }
        toggleDifficultyView()
    }
    
    @IBAction func hardButton(_ sender: UIButton) {
        difficultySelected(sender: sender)
        piecesPerRow = hard
        clearPuzzle()
        if let image = puzzleImage {
            setPuzzle(picture: image)
        }
        toggleDifficultyView()
    }
    
    @IBAction func extremeButton(_ sender: UIButton) {
        difficultySelected(sender: sender)
        piecesPerRow = extreme
        clearPuzzle()
        if let image = puzzleImage {
            setPuzzle(picture: image)
        }
        toggleDifficultyView()
    }
    
    @IBAction func jumbleButton(_ sender: UIButton) {
        jumblePuzzlePieces()
    }
    
    @IBAction func powerUpBUtton(_ sender: UIButton) {
        // show powerUp available: default is highlight?
        solvePuzzle()   // **** TEMP PLACE HOLDER ****
    }
    
    //******************************************//
    //************ Button Actions **************//
    //******************************************//
    
    // show or hide difficulty view (difficulty buttons)
    private func toggleDifficultyView() {
        if (difficultyView.isHidden == true) {
            difficultyView.isHidden = false
            jumbleView?.frame.origin.y += difficultyView.frame.height
        } else {
            difficultyView.isHidden = true
            jumbleView?.frame.origin.y -= difficultyView.frame.height
        }
    }
    
    // add difficulty buttons to array
    func initializeDifficultyButtonArray() {
        
        difficultyButtons.append(easyButton)
        difficultyButtons.append(mediumButton)
        difficultyButtons.append(hardButton)
        difficultyButtons.append(extremeButton)
        
        // round edges
        for button in difficultyButtons {
            button.layer.cornerRadius = 15
        }

        // set based on user defaults
        difficultySelected(sender: easyButton)
    }
    
    func selectButton(button: UIButton) {
        button.backgroundColor = #colorLiteral(red: 0.004859850742, green: 0.09608627111, blue: 0.5749928951, alpha: 1)
        button.tintColor = #colorLiteral(red: 0.004859850742, green: 0.09608627111, blue: 0.5749928951, alpha: 1)
        button.titleLabel?.textColor = UIColor.white
        button.isSelected = true
    }
    
    func unselectButton(button: UIButton) {
        button.backgroundColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
        button.tintColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
        button.titleLabel?.textColor = UIColor.white
        button.isSelected = false
    }
    
    
    func difficultySelected(sender:UIButton) {
        for button in difficultyButtons {
            unselectButton(button: button)
        }
        selectButton(button: sender)
    }
    
    func clearPuzzle() {
        gameBoard.removeAll()
        imagePieces.removeAll()
        puzzlePieces.removeAll()
        if let subviews = jumbleView?.subviews {
            for view in subviews {
                view.removeFromSuperview()
            }
        }
        
    }
    

    func setPictures() {
        let maxIndex = puzzleCount - 1
        for index in 0...maxIndex {
            let pictureName = "puzzle\(index).png"
            if let image = UIImage(named: pictureName) {
                pictures.append(image)
            }
        }
    }
    
    
    func setPuzzle(picture: UIImage) {
        // check for last user
  
            
//            let frame = CGRect(x: 0, y: 0, width: (jumbleView?.frame.width)!, height: (jumbleView?.frame.height)!)
//            puzzleImageView = UIImageView(frame: frame)
//            puzzleImageView?.image = pictures.first!
//            jumbleView?.addSubview(puzzleImageView!)
//            puzzleImageView?.isHidden = true
        
        setPuzzleImage(image: picture)
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
    //*************  View Did Load *************//
    //******************************************//
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
//        loadInitialImage()
        
        // setup the pictures view
        setPictures()
        
        picturesCollectionView.delegate = self
        picturesCollectionView.dataSource = self
        cropAllPictures()
        
        setScreenWidth()
        setJumbleView()
        initializeDifficultyButtonArray()
        
        piecesPerRow = easy
        clearPuzzle()
        
        if (!pictures.isEmpty) {
            let image = pictures.first!
            setPuzzle(picture: image)
        }
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
    }
    
    // handle user touch
    func handlePanGesture(recognizer: UIPanGestureRecognizer) {
        // get the translation
        let translation = recognizer.translation(in: self.view)
        
        // get the view & puzzlePiece
        if let view = recognizer.view, let puzzlePiece = getCurrentPuzzlePiece(view: view) {
        
            // get open direction
            let openDirection = puzzlePiece.openDirection
            
            // bring puzzlePiece to front
            view.superview?.bringSubview(toFront: view)
            let target = CGPoint(x:view.center.x + translation.x, y:view.center.y + translation.y)
            let final = getFinalPoint(puzzlePiece: puzzlePiece, targetPoint: target)
            view.center = final
        }
        
        // reset the translation
        recognizer.setTranslation(CGPoint.zero, in: self.view)
        
        // end of pan gesture
        if (recognizer.state == UIGestureRecognizerState.ended) {
            // set piece in final location
            // get the view & puzzlePiece
            if let view = recognizer.view,
                let puzzlePiece = getCurrentPuzzlePiece(view: view),
                let gameBoardSquare = getClosestGameBoardSquare(puzzlePiece: puzzlePiece) {
                
                puzzlePiece.currentLocation = gameBoardSquare
                
                // update open status
                updateOpenDirectionForPuzzlePieces()
                
                // check if end of game
                if (isGameOver()) {
                    print("game over: true")
                    addMissingPuzzlePiece()
                } else {
                    print ("game over: false")
                }
            }
        }

        
        
    }
    
    // place puzzle piece in gameBoardSquare
    private func placePuzzlePiece(puzzlePiece: PuzzlePiece, gameBoardSquare: Square) {

    }
    
    // get final point based on puzzlePiece movement limits
    private func getFinalPoint(puzzlePiece: PuzzlePiece, targetPoint: CGPoint) -> CGPoint {
        // get the x and y values based on available movement range
        let x = getValueInRange(target: targetPoint.x,  min: puzzlePiece.minX, max: puzzlePiece.maxX)
        let y = getValueInRange(target: targetPoint.y,  min: puzzlePiece.minY, max: puzzlePiece.maxY)
        
        // return final point
        return CGPoint(x: x, y: y)
    }
    
    // helper function to return a value that is limited to a max and min
    private func getValueInRange(target: CGFloat, min: CGFloat, max: CGFloat) -> CGFloat {
        if (target > max) {
            return max
        } else if (target < min) {
            return min
        } else {
            return target
        }
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
        let yCushion: CGFloat = 5.0
        let y: CGFloat = infoView.frame.height - difficultyView.frame.height + yCushion
        let width: CGFloat = screenWidth
        let height: CGFloat = width
        
        let frame = CGRect(x: x, y: y, width: width, height: height)
        jumbleView = UIView(frame: frame)
        jumbleView?.layer.borderWidth = borderWidth // set border width for imageview
        jumbleView?.layer.borderColor = borderColor  // set border color for imageview
        jumbleView?.backgroundColor = UIColor.white
        self.view.addSubview(jumbleView!)
    }
    
    
    //******************************************//
    //************  Original Image *************//
    //******************************************//
    
    // set the original image (i.e. image that is split into puzzle pieces)
    func setPuzzleImage(image: UIImage) {
        print("inside setPuzzleImage")
        puzzleImage = resizeToScreenSize(image: image)
        
    }
    
    // resize an image to the screen size
    private func resizeToScreenSize(image: UIImage) -> UIImage{
        print("inside resizeToScreenSize")
        return resizeImage(image: image, newWidth: screenWidth)
    }
    
    // resize an image
    // - Attribute: https://gist.github.com/cuxaro/20a5b9bbbccc46180861e01aa7f4a267
    private func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        print("inside resize Image")
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
        if let image = puzzleImage {
            // clear all existing images
            imagePieces.removeAll()
            
            // loop through rectangles and create cropped image
            for gameBoardPiece in gameBoard {
                let square = gameBoardPiece.square  // set square that determines crop
                print("square: \(square)")
                print("image: \(image)")
                print("imagecg: \(image.cgImage)")
                let imagePiece = image.crop(rect: square)  // create image crop
                imagePieces.append(imagePiece)  // add image to array
            }
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
            imageView.layer.borderWidth = borderWidth // set border width for imageview
            imageView.layer.borderColor = borderColor  // set border color for imageview
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
        
        updateOpenDirectionForPuzzlePieces()
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
        missingImageView.layer.borderWidth = borderWidth // set border width for imageview
        missingImageView.layer.borderColor = borderColor  // set border color for imageview
        jumbleView?.addSubview(missingImageView)
        
        UIView.animate(withDuration: 1.0, delay: 0.0, animations: {
            // bring the missing image into view
            missingImageView.alpha = 1.0
        }, completion: { finished in
            // show complete image
            let finalImageView = UIImageView(image: self.puzzleImage)
            finalImageView.alpha = 0.0
            self.jumbleView?.addSubview(finalImageView)
            UIView.animate(withDuration: 1.0, delay: 0.0, animations: {
                finalImageView.alpha = 1.0
            }, completion: nil)
            
            
        })
        
    }
    
    
    // COLLECTION VIEW STUFF
    
    private func cropAllPictures() {
        var croppedPictures = [UIImage]()
        for picture in pictures {
            let croppedPicture = cropToSquare(image: picture)
            croppedPictures.append(croppedPicture)
        }
    
        pictures.removeAll()
        pictures = croppedPictures
    }
    
    func cropToSquare(image: UIImage) -> UIImage {
        let imageWidth = image.size.width
        let imageHeight = image.size.height
        let width =  min(imageWidth, imageHeight)
        let height = width
        
        let origin = CGPoint(x: (imageWidth - width) / 2, y: (imageHeight - height) / 2)
        let size = CGSize(width: width, height: height)
        let frame = CGRect(origin: origin, size: size)
        let squareImage = image.crop(rect: frame)
        return squareImage
    }
    
    private func showPictures() {
        let frame = self.view.frame
            // set size and location
            picturesView.frame = frame
            picturesView.layer.borderWidth = borderWidth // set border width
            picturesView.layer.borderColor = borderColor // set border color
            picturesView.backgroundColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
            // add to view
            self.view.addSubview(picturesView)
            picturesView.isHidden = false
        
        
    }
    
    func hidePictures() {
        picturesView.isHidden = true
    }
    
    
}

//******************************************//
//**************  Extensions ***************//
//******************************************//


extension ViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pictures.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PictureCell
        
        // format cell
        cell.backgroundColor = UIColor.white
        cell.layer.borderWidth = borderWidth
        cell.layer.borderColor = borderColor
        
        // assign image
        let image = pictures[(indexPath as IndexPath).row]
        cell.pictureImageView.image = image
        cell.pictureImageView.contentMode = .scaleAspectFill

        return cell
    }

}


extension ViewController : UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let image = pictures[(indexPath as IndexPath).row]
        clearPuzzle()
        setPuzzle(picture: image)
        hidePictures()
        
        // use this image
        // clear old gameboard (save?)
        // set background image
        // hide this view
        // show new image
        // jumble
    }
    
}

// Layout for CollectionView
// - Attribution: https://www.raywenderlich.com/136159/uicollectionview-tutorial-getting-started
extension ViewController : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = self.view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}





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
        
        // crop & return the image
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


