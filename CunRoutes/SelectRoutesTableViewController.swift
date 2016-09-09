//
//  SelectRoutesTableViewController.swift
//  CunRoutes
//
//  Created by Wilson Muñoz on 7/9/16.
//  Copyright © 2016 Wilson Muñoz. All rights reserved.
//

import UIKit
import ElasticTransition
import CellAnimator

class SelectRoutesTableViewController: UITableViewController, ElasticMenuTransitionDelegate {
    
    //MARK: VARS
    var FullRoutesStatus:Bool?
    var RoutesList = [Dictionary<String, String>]()
    var indexPath: NSIndexPath!
    var transition = ElasticTransition()

    
    //MARK: Outlets
    @IBOutlet weak var ButtonSelectDeselect: UIButton!
    
    //Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
       
        //Read State of List
        fullListIsTrue()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return RoutesList.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell",
                                                               forIndexPath: indexPath) as! SelectRouteTableViewCell
        // Configure the cell...
        let route = RoutesList[indexPath.row] as NSDictionary
        
        //Animate Cell
        CellAnimator.animateCell(cell, withTransform: CellAnimator.TransformCurl, andDuration: 0.5)

        //Label
        cell.LabelName.text = route["nombre"] as? String
        
        //Radio Button
        //cell.ButtonRadio.setTitle(route["nombre"] as? String, forState: UIControlState.Normal)
        let color = UIColor(hexaString: route["color"] as! String)
        cell.ButtonRadio.circleColor = color
        cell.ButtonRadio.circleLineWidth = 6.0
        cell.ButtonRadio.fillCircleColor = color
        
        //If is Active we declare it Active in the view
        if(route["state"] as? String == "active"){
            
            cell.ButtonRadio.selected = true
        
        } else{
            
            cell.ButtonRadio.selected = false
            
        }
        
        //Return
        return cell
    }
    
    
    //User Selects a Route To Activate / Inactivate
    @IBAction func didPressButton(sender: RadioButton) {
        if(sender.selected == false){
            //Fill Color
            sender.fillCircleColor = sender.circleColor
            
            //Change the state of that route.
            if let superview = sender.superview {
                
                if let cell = superview.superview as? SelectRouteTableViewCell {
                    
                    //Get index of the cell and change that Route inside the array to active
                    indexPath = self.tableView.indexPathForCell(cell)
                    RoutesList[indexPath.row].updateValue("active", forKey: "state")
                    
                }//Ends if let cell
                
            }//Endsif let superview
            
        } else {
            //Change Color to "unfill"
            sender.fillCircleColor = UIColor.whiteColor()
            
            //Change the state of that route.
            if let superview = sender.superview {
                
                if let cell = superview.superview as? SelectRouteTableViewCell {
                    
                    //Get index of the cell and change that Route inside the array to inactive
                    indexPath = self.tableView.indexPathForCell(cell)
                    RoutesList[indexPath.row].updateValue("inactive", forKey: "state")

                }//Ends if let cell
                
            }//Endsif let superview
            
        }//Ends Else
        
        //Change state
        sender.selected = !sender.selected
        
        //Read State General Again
        fullListIsTrue()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        //Check if we are about to go back to the Map we pass the new array
        if(segue.identifier == "backToMap"){
            
            //Check State of List
            fullListIsTrue()
            
            //Select the View
            let targetController = segue.destinationViewController as! ViewController
            
            
            //Declare Vars
            targetController.Routes = RoutesList
            targetController.FullRoutes = FullRoutesStatus!
            
        }//If segue is identifier
        
    }
    
    //MARK: Actions
    @IBAction func SelectDeselect(sender: UIButton) {
        
        
        
        //Get all cells
        let tableSection = UITableView().numberOfSections.hashValue
        
        //Then we check based on true or false
        if(self.FullRoutesStatus == false){
            
            //If the list has some inactive Routes we select all the routes and put the active
            for section in 0...tableSection-1 {
                
                for cell in 0...RoutesList.count-1{
                        
                    let indexPathInside =  NSIndexPath(forRow: cell, inSection: section)
                    let cell = tableView.dequeueReusableCellWithIdentifier("cell",
                                                                           forIndexPath: indexPathInside) as! SelectRouteTableViewCell
                    RoutesList[indexPathInside.row].updateValue("active", forKey: "state")
                    cell.ButtonRadio.selected = true
                    cell.ButtonRadio.circleColor = cell.ButtonRadio.fillCircleColor
                    
                }
                
            }
            //Run one more time the status of the list
            tableView.reloadData()
            fullListIsTrue()
            
        } else {
            
            //If the list is completly active we deselect eveything and set it to inactive.
            for section in 0...tableSection-1 {
                
                for cell in 0...RoutesList.count-1{
                    
                    let indexPathInside =  NSIndexPath(forRow: cell, inSection: section)
                    let cell = tableView.dequeueReusableCellWithIdentifier("cell",
                                                                           forIndexPath: indexPathInside) as! SelectRouteTableViewCell
                    RoutesList[indexPathInside.row].updateValue("inactive", forKey: "state")
                    cell.ButtonRadio.selected = false
                    cell.ButtonRadio.circleColor = UIColor.whiteColor()
                }//For Cells
                
            }//For Sections
            
            //Run one more time the status of the list
            tableView.reloadData()
            fullListIsTrue()

        }//Else
        
    }//Ends IBAction
    
    
    //Check if we are full list
    func fullListIsTrue(){
        var rutasinactivas = 0
        for ruta in RoutesList{
            if (ruta["state"] as String! == "inactive"){
                rutasinactivas += 1
            }
        }
        if(rutasinactivas > 0){
            self.FullRoutesStatus = false
            self.ButtonSelectDeselect.setTitle("Select All", forState: UIControlState.Normal)

        } else {
            self.FullRoutesStatus = true
            self.ButtonSelectDeselect.setTitle("Deselect All", forState: UIControlState.Normal)
        }
    }
    
    
}


