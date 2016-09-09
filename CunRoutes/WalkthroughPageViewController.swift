//
//  WalkthroughPageViewController.swift
//  CunRoutes
//
//  Created by Wilson Muñoz on 7/11/16.
//  Copyright © 2016 Wilson Muñoz. All rights reserved.
//

import UIKit

class WalkthroughPageViewController: UIPageViewController, UIPageViewControllerDataSource {
    
    
    //MARK: Vars
    var pageHeadings = ["All Routes, One Place", "Choose Your Bus Routes", "Make Your Route", "Get Routes Information"]
    var pageImages = ["image1", "image2", "image3", "image4"]
    var pageContent = ["Get all the bus routes in Cancun in one map. Each Route has a distintive color.","Select All Routes or just the ones you need to plan your trip","With Cun Routes you can also create your own Route and see which Bus routes collide with yours", "Finally if you select one of the routes you get the name and number of the bus."]
    
    //MARK: Outlets
    
    //MARK: View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()

        // Create the first walkthrough screen
        if let startingViewController = viewControllerAtIndex(0) {
            setViewControllers([startingViewController], direction: .Forward,
                animated: true, completion: nil)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Methods
    func pageViewController(pageViewController: UIPageViewController,
                            viewControllerAfterViewController viewController: UIViewController) ->
        UIViewController? {
            var index = (viewController as!  WalkThroughViewController).index
            index += 1
            return viewControllerAtIndex(index)
    }
    func pageViewController(pageViewController: UIPageViewController,
                            viewControllerBeforeViewController viewController: UIViewController) ->
        UIViewController? {
            var index = (viewController as! WalkThroughViewController).index
            index -= 1
            return viewControllerAtIndex(index)
    }
    
    
    //MARK: Helpers
    func viewControllerAtIndex(index: Int) -> WalkThroughViewController? {
        if index == NSNotFound || index < 0 || index >= pageHeadings.count {
            return nil
        }
        // Create a new view controller and pass suitable data.
        if let pageContentViewController =
            storyboard?.instantiateViewControllerWithIdentifier("WalkThroughViewController")
                as? WalkThroughViewController {
            pageContentViewController.imageFile = pageImages[index]
            pageContentViewController.heading = pageHeadings[index]
            pageContentViewController.content = pageContent[index]
            pageContentViewController.index = index
            return pageContentViewController
        }
        return nil
    }
    
    func forward(index:Int) {
        if let nextViewController = viewControllerAtIndex(index + 1) {
            setViewControllers([nextViewController], direction: .Forward, animated:
                true, completion: nil)
        }
    }
    
    func backward(index:Int) {
        if let nextViewController = viewControllerAtIndex(index - 1) {
            setViewControllers([nextViewController], direction: .Reverse, animated:
                true, completion: nil)
        }
    }
    
    //Change Color Status Bar
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }

}
