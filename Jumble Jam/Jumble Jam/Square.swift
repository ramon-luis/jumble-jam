//
//  Square.swift
//  Jumble Jam
//
//  Created by Ramon RODRIGUEZ on 3/7/17.
//  Copyright © 2017 Ramon Rodriguez. All rights reserved.
//

import UIKit

class Square {
    
    // this is currently not used
    // possibly useful later for adding hidden power ups
    enum Status {
        case open
        case closed
    }
    
    //******************************************//
    //***************  Properties **************//
    //******************************************//
    
    // - MARK: Properties

    var square: CGRect
    var row: Int
    var col: Int
    var status: Status
    
    //******************************************//
    //*****************  Init ******************//
    //******************************************//
    
    // - MARK: Init
    
    init(square: CGRect, row: Int, col: Int) {
        self.square = square
        self.row = row
        self.col = col
        status = Status.closed
    }
    
    func toString() -> String{
        return "Square | row: \(row), col: \(col), origin: \(square.origin), xOrigin: \(CGPoint(x: (square.origin.x + square.width), y: (square.origin.y + square.height))), width: \(square.width)"
    }
    
    
}
