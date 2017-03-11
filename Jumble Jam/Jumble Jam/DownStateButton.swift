//
//  RadioButton.swift
//  Jumble Jam
//
//  Created by Ramon RODRIGUEZ on 3/11/17.
//  Copyright © 2017 Ramon Rodriguez. All rights reserved.
//

import UIKit

class DownStateButton: UIButton {
    
    var alternateButtons = [DownStateButton]()
    
    var downStateImage: UIImage = #imageLiteral(resourceName: "radioButtonDown"){
        didSet {
                self.setImage(downStateImage, for: UIControlState.selected)
        }
    }
    
    func unselectAlternateButtons(){
        if (alternateButtons.count > 0) {
            self.isSelected = true
            for button in alternateButtons {
                button.isSelected = false
            }
        } else{
            toggleButton()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        unselectAlternateButtons()
        super.touchesBegan(touches, with: event)
    }
    
    func toggleButton(){
        self.isSelected = !isSelected
    }
}
