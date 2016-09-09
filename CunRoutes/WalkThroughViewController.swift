//
//  WalkThroughViewController.swift
//  CunRoutes
//
//  Created by Wilson Muñoz on 7/11/16.
//  Copyright © 2016 Wilson Muñoz. All rights reserved.
//

import UIKit

class WalkThroughViewController: UIViewController {
    
    //Outlets
    @IBOutlet var headingLabel:UILabel!
    @IBOutlet var contentLabel:UILabel!
    @IBOutlet var contentImageView:UIImageView!
    @IBOutlet var forwardButton:UIButton!
    @IBOutlet var backwardButton:UIButton!
    
    //Vars
    var index = 0
    var heading = ""
    var imageFile = ""
    var content = ""
    
    //Change Color Status Bar
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        headingLabel.text = heading
        contentLabel.text = content
        contentImageView.image = UIImage(named: imageFile)
        
        if case 0...2 = index {
            forwardButton.setTitle("NEXT", forState: UIControlState.Normal)
        } else if case 3 = index {
            forwardButton.setTitle("DONE", forState: UIControlState.Normal)
        }
        if case 1...3 = index {
            backwardButton.hidden = false
            backwardButton.setTitle("BACK", forState: UIControlState.Normal)
        } else if case 0 = index {
            backwardButton.hidden = true
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: Actions
    @IBAction func nextButtonTapped(sender: UIButton) {
        switch index {
        case 0...2:
            let pageViewController = parentViewController as!
            WalkthroughPageViewController
            pageViewController.forward(index)
        case 3:
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setBool(true, forKey: "hasViewedWalkthroughCunRoutes")
            dismissViewControllerAnimated(true, completion: nil)
        default: break
        }
    }
    
    @IBAction func backButtonTapped(sender: UIButton) {
        switch index {
        case 1...3:
            let pageViewController = parentViewController as!
            WalkthroughPageViewController
            pageViewController.backward(index)
        default: break
        }
    }

}
