//
//  ViewController.swift
//  CunRoutes
//
//  Created by Wilson Muñoz on 7/4/16.
//  Copyright © 2016 Wilson Muñoz. All rights reserved.
//


import UIKit
import GoogleMaps
import SCLAlertView
import SwiftyJSON
import Alamofire
import Polyline
import ElasticTransition
import Spring

class ViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {
    
    //Got rid of ElasticMenuTransitionDelegate, too much Memory
    
    //MARK: Outlets
    @IBOutlet var GeneralView: SpringView!
    @IBOutlet weak var MainMapView: GMSMapView!
    @IBOutlet weak var NavigationBar: UINavigationBar!
    
    //MARK: Vars
    var locationManager = CLLocationManager()
    var didFindMyLocation = false
    var FullRoutes:Bool = true
    var Routes:[Dictionary<String, String>] = []
    var transition = ElasticTransition()
    var polylineUserDirection:GMSPolyline?
    var pathDirectionsUserCoordinatesCount:UInt?

    
    //MARK: Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Sets
        didFindMyLocation = false
        MainMapView.delegate = self
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        
        //Cancun
        let camera = GMSCameraPosition.cameraWithLatitude(21.1602138, longitude: -86.8497939, zoom: 14)
        
        //Other Stuff
        MainMapView.camera = camera
        MainMapView.accessibilityElementsHidden = false
        MainMapView.myLocationEnabled = true
        MainMapView.mapType = kGMSTypeNormal
        MainMapView.buildingsEnabled = true

        
        //Add Listener so we can show USer Location
        MainMapView.addObserver(self, forKeyPath: "myLocation", options: NSKeyValueObservingOptions.New, context: nil)
        
    }//Ends Did Load
    
    
    //Will Appear
    override func viewWillAppear(animated: Bool) {
        
        //Change color NavBAr and titleColor
        NavigationBar.barTintColor = UIColor(red:0.182,  green:0.602,  blue:0.860, alpha:1)
        let textAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()]
        NavigationBar.titleTextAttributes = textAttributes
        
        
        //Animate the General View
        GeneralView.scaleX = 3.0
        GeneralView.scaleY = 3.0
        GeneralView.duration = 1.5
        GeneralView.curve = "squeezeDown"
        GeneralView.animateTo()
        GeneralView.animateNext{
            self.GeneralView.scaleX = 1.0
            self.GeneralView.scaleY = 1.0
            self.GeneralView.duration = 1.8
            self.GeneralView.curve = "pop"
            self.GeneralView.animate()
        }
        //Fetch
        fetchRoutes()
            
    }//Ends Will Appear
    
    //Function Fetch Routes. On v2 check if we can DRY this function.
    func fetchRoutes(){
        
        //We Clear
        MainMapView.clear()
        
        //If We are Fething Full Routes
        if(FullRoutes){
            
            //We Clear
            MainMapView.clear()
            self.Routes.removeAll()

            
            //Get General Routes File
            let pathfile = NSBundle.mainBundle().pathForResource("rutas", ofType: "json")
            let jsonData = NSData(contentsOfFile:pathfile!)
            let json = JSON(data: jsonData!)
            let routes = json.arrayValue
            
            
            //Loop all the routes
            for ruta in routes{
                
                //Append
                self.Routes.append(ruta.rawValue as! [String : String])
                
                //Get each route json file
                let rutafile = ruta["archivo"].stringValue
                let pathfileRuta = NSBundle.mainBundle().pathForResource(rutafile, ofType: "json")
                let jsonDataRuta = NSData(contentsOfFile:pathfileRuta!)
                let jsonruta = JSON(data: jsonDataRuta!)
                let rutasRuta = jsonruta.arrayValue
                
                //Prepare Path
                let path = GMSMutablePath()
                
                //Prepare al polylines for Path
                for polyline in rutasRuta{
                    //create basic Path
                    
                    //Add Polylines to Path
                    path.addLatitude(polyline["latitude"].doubleValue, longitude: polyline["longitude"].doubleValue)
                    
                }//Ends For for Polyline
                
                //Configure and Add Polyline to Path and finally add Path to Map
                let color = UIColor(hexaString: ruta["color"].stringValue)
                let polyline = GMSPolyline(path: path)
                polyline.strokeColor = color
                polyline.strokeWidth = 2.1
                polyline.map = MainMapView
                polyline.tappable = true
                polyline.title = ruta["nombre"].stringValue
            }//Ends ruta in rutas (route in Routes)
            
        }// If full Routes
            
            //Full Routes is FALSE
        else {
            //Loop all the routes
            for ruta in Routes{
                
                //Check if the Route is Active
                if(ruta["state"] as String! == "active") {
                    
                    //Get each route json file
                    let rutafile = ruta["archivo"] as String!
                    let pathfileRuta = NSBundle.mainBundle().pathForResource(rutafile, ofType: "json")
                    let jsonDataRuta = NSData(contentsOfFile:pathfileRuta!)
                    let jsonruta = JSON(data: jsonDataRuta!)
                    let rutasRuta = jsonruta.arrayValue
                    
                    //Prepare Path
                    let path = GMSMutablePath()
                    
                    //Prepare al polylines for Path
                    for polyline in rutasRuta{
                        //create basic Path
                        
                        //Add Polylines to Path
                        path.addLatitude(polyline["latitude"].doubleValue, longitude: polyline["longitude"].doubleValue)
                        
                        
                    }//Ends For for Polyline
                    
                    //Configure and Add Polyline to Path and finally add Path to Map
                    let color = UIColor(hexaString: ruta["color"] as String!)
                    let polyline = GMSPolyline(path: path)
                    polyline.strokeColor = color
                    polyline.strokeWidth = 1.1
                    polyline.map = MainMapView
                    polyline.tappable = true
                    polyline.title = ruta["nombre"] as String!

                }//Ends if route is Active
                
            }//Ends ruta in rutas (route in Routes)
            
        }// Ends Else
        
    }//Ends FetchRoutes
    
    
    //Listen to Authorization
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.AuthorizedWhenInUse {
            MainMapView.myLocationEnabled = true
        }
        if status == CLAuthorizationStatus.AuthorizedAlways{
            MainMapView.myLocationEnabled = true
        }
    }
    
    
    //Listener for My Location Response
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        //If location is enabled set button and change var to true
        if (didFindMyLocation == false) {
            MainMapView.settings.myLocationButton = true
            didFindMyLocation = true
            
        }

    }
    
    //DID APPEAR
    override func viewDidAppear(animated: Bool) {
        
        //Present WalkThrough
        let defaults = NSUserDefaults.standardUserDefaults()
        
        //If Want to show walkthrough multiple times, comment it on ship.
        //defaults.setBool(false, forKey: "hasViewedWalkthroughCunRoutes")
        let hasViewedWalkthrough = defaults.boolForKey("hasViewedWalkthroughCunRoutes")
        if hasViewedWalkthrough {
            return
        }
        
        if let pageViewController = storyboard?.instantiateViewControllerWithIdentifier("WalkthroughController")
            as? WalkthroughPageViewController {
            presentViewController(pageViewController, animated: true, completion:
                nil)
        }
        
        
        //run location on user
        if(MainMapView.myLocation?.coordinate != nil){
            
            MainMapView.myLocationEnabled = true
            MainMapView.settings.myLocationButton = true
            didFindMyLocation = true
        }
        
        //We create a timer ro run a function named "zommearMapa" after 4 sec.
        _ = NSTimer.scheduledTimerWithTimeInterval(4.0, target: self, selector: #selector(ViewController.zoomearMapa), userInfo: nil, repeats: true)
        
    }
    
    
    //Function to zoom
    func zoomearMapa()->() {
        
        //Firs we check if we have authorization
        if CLLocationManager.locationServicesEnabled() {
            
            //Check if we have Location enabled, we do not want any errors.
            if(MainMapView.myLocationEnabled.boolValue == true){
                
                //Set struct to 0
                struct TokenContainer {
                    static var token : dispatch_once_t = 0
                }
                
                //Dispatch function ONCE
                dispatch_once(&TokenContainer.token) {
                    
                    //Lastly check if coordinates are NOT nil
                    if (self.MainMapView.myLocation?.coordinate != nil){
                        //Get User Data
                        let userlocation:CLLocationCoordinate2D = (self.MainMapView.myLocation?.coordinate)!
                        
                        //Start Transition
                        CATransaction.begin()
                        
                        //Set Time for Transition
                        CATransaction.setValue(NSNumber(float: 4.0), forKey: kCATransactionAnimationDuration)
                        
                        //Set new position of camera
                        self.MainMapView.animateToCameraPosition(GMSCameraPosition.cameraWithLatitude(userlocation.latitude, longitude: userlocation.longitude, zoom: 19, bearing: 0, viewingAngle: 200))
                        
                        //Finish Transition
                        CATransaction.commit()
                        
                    }
                    
                }//Dispatch Finishes
            }//If mylocation is true
        }//if locationServices is enabled
    }//Function Finishes
    
    
    //Called when the My Location button is tapped.
    func didTapMyLocationButtonForMapView(mapView: GMSMapView) -> Bool {
        
        if (mapView.myLocation?.coordinate != nil){
            //Get User Data
            let userlocation:CLLocationCoordinate2D = (self.MainMapView.myLocation?.coordinate)!
            
            //Start Transition
            CATransaction.begin()
            
            //Set Time for Transition
            CATransaction.setValue(NSNumber(float: 4.0), forKey: kCATransactionAnimationDuration)
            
            //Set new position of camera
            mapView.animateToCameraPosition(GMSCameraPosition.cameraWithLatitude(userlocation.latitude, longitude: userlocation.longitude, zoom: 19, bearing: 0, viewingAngle: 200))
            
            //Finish Transition
            CATransaction.commit()
        }
        
        return true

    }
    
<<<<<<< HEAD

=======
>>>>>>> cceb39cb2877d44bc2fc45e3481e8ba7bbada3be
    
    //MARK: Actions
    
    //Show Alert Box of show Address
    @IBAction func setAddress(sender: UIBarButtonItem) {
        
        let alert = SCLAlertView()
        let from_destination = alert.addTextField("Where are you?")
        let to_destination = alert.addTextField("Enter Your Destination")
        alert.addButton("Create My Route") {
            
            //Check if Empty, if not we run route
            if(from_destination.text == "" || to_destination.text == ""){
                
                SCLAlertView().showError("Empty Data", subTitle: "Please Fill the fields so we can trace a route.") // Error
            
            } else{
                
                //We call Google Directions with Alamofire
                //Vars
                var from    = from_destination.text as String!
                var to      = to_destination.text as String!
                
                //Check if the Word "Cancun" is in the end of the sentences.
                let last5CharsFrom = String(from.characters.suffix(6)).lowercaseString
                let last5CharsTo = String(to.characters.suffix(6)).lowercaseString
                
                //If last 5 Chars are not the word "Cancun" we add it.
                if (last5CharsFrom != "cancun"){
                    from = from + " Cancun"
                }
                if (last5CharsTo != "cancun"){
                    to = to + " Cancun"
                }
                
                //Create Link with Address
                var link    = "https://maps.googleapis.com/maps/api/directions/json?origin=\(from)&destination=\(to)&key=AIzaSyDYr49ZubEYWFvr01pph-yRR7SWwzagbLg"
                link = link.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
                
                //Alamofire && SwitfyJSON to the rescue
                Alamofire.request(.GET, link).validate().responseJSON() { response in
                    switch response.result {
                    case .Success:
                        
                        if let value = response.result.value {
                            let json = JSON(value)
                            
                            let polyroutes = json["routes"][0]["legs"][0]["steps"]
                            
                            //Prepare Polyline
                            let pathDirectionsUser = GMSMutablePath()
                            
                            for route in polyroutes{
                                
                               
                                let encodedpolyline = route.1["polyline"]["points"].stringValue
                                
                                let polyline = Polyline(encodedPolyline: encodedpolyline)
                                
                                for pathpoly in polyline.coordinates!{
                                    
                                    pathDirectionsUser.addLatitude(pathpoly.latitude, longitude: pathpoly.longitude)
                                    
                                }
                                
                                self.pathDirectionsUserCoordinatesCount = UInt(polyline.coordinates!.count)

                            }
                            //Add Poly of Route
                            //Configure and Add Polyline to Path and finally add Path to Map
                            let color = UIColor.redColor()
                            if(self.polylineUserDirection?.map != nil){
                                self.polylineUserDirection?.map = nil
                            }
                            self.polylineUserDirection = GMSPolyline(path: pathDirectionsUser)
                            self.polylineUserDirection!.strokeColor = color
                            self.polylineUserDirection!.strokeWidth = 3.5
                            self.polylineUserDirection!.title = "This is your Route: \(from) to \(to)."
                            self.polylineUserDirection!.zIndex = 3
                            self.polylineUserDirection!.map = self.MainMapView
                            
                            //Animate Cameera for first Point.
                            let lastCoordinateOfTheDirection = pathDirectionsUser.coordinateAtIndex(self.pathDirectionsUserCoordinatesCount!)
                            
                            //Start Transition
                            CATransaction.begin()
                            
                            //Set Time for Transition
                            CATransaction.setValue(NSNumber(float: 2.0), forKey: kCATransactionAnimationDuration)
                            
                            //Move Camera to Position
                            self.MainMapView.animateToCameraPosition(GMSCameraPosition.cameraWithLatitude(lastCoordinateOfTheDirection.latitude, longitude: lastCoordinateOfTheDirection.longitude, zoom: 15, bearing: 0, viewingAngle: 80))
                            
                            //Finish Transition
                            CATransaction.commit()

                        }
                        
                        case .Failure(let error):
                        
                            //show error
                            let errorFinal = error.localizedDescription
                            SCLAlertView().showError("Error", subTitle: errorFinal) // Error

                        
                    }//EndsSwitch
                
                }//Ends Alamofire

            }//Ends Else
        }//ends Conform of Alert
        alert.showInfo("My Route", subTitle: "See which Bus Routes collide with yours. Your Route will be marked in red.")

    }//Ends IBAction
    
    
    //If user Taps a PolygoneLine we show info
    func mapView(mapView: GMSMapView, didTapOverlay overlay: GMSOverlay) {
        let alert = SCLAlertView()
        
        let ruteTitle = overlay.title as String?
        alert.showNotice("BusRoute", subTitle: ruteTitle!)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Unwind Function
    @IBAction func unwindToMenu(segue: UIStoryboardSegue) {
        
        //Detect the previous Controller
        let passviewcontroll = segue.sourceViewController as! SelectRoutesTableViewController
        
        //We get the updated Route List and status
        self.Routes = passviewcontroll.RoutesList
        self.FullRoutes = passviewcontroll.FullRoutesStatus!
        
        //Fetch it and update the map
        fetchRoutes()
        
    }//Ends Unwind

    
    //MARK: Prepare For Segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        //Check if we are about to go to Table View of Select Routes
        if(segue.identifier == "selectRoutes"){
            
            transition.edge = .Bottom
            transition.startingPoint = sender!.center
            
            //Select the View
            let selectRoutes = segue.destinationViewController as! SelectRoutesTableViewController
            
            //Declare Vars
            selectRoutes.RoutesList = Routes
            
            //Animate Modal
            selectRoutes.transitioningDelegate = transition
            selectRoutes.modalPresentationStyle = .Custom

            //We check if inside the array there is ANY route not Active
            //If there is at least one not Active we declare FullRoute as False
            var rutasinactivas = 0
            for ruta in Routes{
                if (ruta["state"] as String! == "inactive"){
                    rutasinactivas += 1
                }
            }
            
            //If there is at least 1 inactive route we set
            if(rutasinactivas > 0){
                selectRoutes.FullRoutesStatus = false
            } else {
                selectRoutes.FullRoutesStatus = true
            }//Ends else
        
        }//Ends segue.identifier == "selectRoutes"
        
    }//Ends prepareForSegue
    
    
    //Change Color Status Bar
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
}//CLASS Ends


//MARK: Extensions
extension UIColor {
    convenience init(hexaString:String) {
        self.init(
            red:   CGFloat( strtoul( String(Array(hexaString.characters)[1...2]), nil, 16) ) / 255.0,
            green: CGFloat( strtoul( String(Array(hexaString.characters)[3...4]), nil, 16) ) / 255.0,
            blue:  CGFloat( strtoul( String(Array(hexaString.characters)[5...6]), nil, 16) ) / 255.0, alpha: 1.0 )
    }
}
