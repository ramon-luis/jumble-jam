//
//  SplashViewController.swift
//  Jumble Jam
//
//  Created by Ramon RODRIGUEZ on 3/11/17.
//  Copyright © 2017 Ramon Rodriguez. All rights reserved.
//

import UIKit

class SplashViewController: UIViewController {

    // - MARK: Properties
    let distance: CGFloat = 750 // distance off screen to hide
    @IBOutlet weak var splashLabel: UILabel!
    @IBOutlet weak var splashImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        hideSplashImageView()   // hide first
        animateSplash() // then animate
    }
    
    // hide the logo for animation
    private func hideSplashImageView() {
        splashImageView.frame.origin.y -= distance
        splashImageView.isHidden = false
    }
    
    // perform animations
    private func animateSplash() {
        UIView.animate(withDuration: 0.5, delay: 0.0, options: [.curveEaseInOut], animations: {
            
            // drop down imageView
            self.splashImageView.frame.origin.y += self.distance
            
        }, completion: { finishing in
            UIView.animate(withDuration: 1.0, delay: 0.0, animations: {
                
                // fade in label
                self.splashLabel.alpha = 1.0
            }, completion: { finishing in
                
                // segue to game
                self.performSegue(withIdentifier: "SplashSegue", sender: nil)
            })
        })
    }
    
}
