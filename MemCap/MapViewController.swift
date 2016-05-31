//
//  ViewController.swift
//  MemCap
//
//  Created by Jahan Cherian on 5/19/16.
//  Copyright © 2016 Jahan Cherian. All rights reserved.
//

import UIKit
import MapKit
import GoogleMaps
import Firebase
import FirebaseDatabase
import FBSDKCoreKit

class MapViewController: UIViewController, GMSMapViewDelegate, messageProtocol, UITextViewDelegate
{
    private class User
    {
        var name = String()
        var ID = String()
        var picURL = NSURL()
        
        init()
        {
            name = ""
            ID = ""
        }
        
        init(n: String, url: NSURL)
        {
            name = n
            picURL = url
            ID = ""
        }
    }
    
    var ref = FIRDatabase.database().reference()
    
    //Take an image by transitioning to a different view controller
    @IBAction func drop_picture(sender: AnyObject)
    {
        self.performSegueWithIdentifier("toCamera", sender: self)
    }
    //Allows user to create a message within the current view
    @IBAction func drop_message(sender: AnyObject)
    {
        self.messageView?.hidden = false
    }
    
    //Refreshes the Map to update new scavenger drops
    @IBAction func refresh_view(sender: AnyObject)
    {
        ref.observeEventType(FIRDataEventType.Value, withBlock: { (snapshot) in
            let messages = snapshot.value!["messages"]! as! [String: AnyObject]
            for (_,value) in messages
            {
                let obj = value as! [String: AnyObject]
                var lat = CLLocationDegrees()
                var long = CLLocationDegrees()
                var mess = String()
                var name = String()
                var url:NSURL!
                for (f_key, f_value) in obj
                {
                    if(f_key == "lat")
                    {
                        lat = f_value as! CLLocationDegrees
                    } else if (f_key == "long")
                    {
                        long = f_value as! CLLocationDegrees
                    } else if (f_key == "message")
                    {
                        mess = f_value as! String
                    } else if (f_key == "name")
                    {
                        name = f_value as! String
                    } else
                    {
                        url = NSURL(string: f_value as! String)!
                    }
                }
                let coordinate = CLLocationCoordinate2DMake(lat, long)
                let tempMarker = GMSMarker(position: coordinate)
                tempMarker.map = self.mapView
                tempMarker.icon = UIImage(named: "Message_icon_dark")
                let tempUser = User(n: name, url: url)
                self.markers.append((tempMarker, mess, tempUser))
            }
        })
        
    }
    
    func setImageMarker()
    {
        if(self.imageToDrop != nil)
        {
            Location.sharedInstance.startUpdatingLocation()
            let eventMarker = GMSMarker(position: Location.sharedInstance.currLocation!.coordinate)
            eventMarker.map = self.mapView
            eventMarker.icon = UIImage(named: "Camera_icon_dark")
            self.markers.append((eventMarker, self.imageToDrop!, self.currUser))
            self.imageToDrop = nil
            Location.sharedInstance.stopUpdatingLocation()
        }
    }
    
    func setMessageMarker()
    {
        if(self.message != nil)
        {
            Location.sharedInstance.startUpdatingLocation()
            let eventMarker = GMSMarker(position: Location.sharedInstance.currLocation!.coordinate)
            eventMarker.map = self.mapView
            eventMarker.icon = UIImage(named: "Message_icon_dark")
            self.markers.append((eventMarker, self.message!, self.currUser))
            let sendLat = Location.sharedInstance.currLocation!.coordinate.latitude as NSNumber
            let sendLong = Location.sharedInstance.currLocation!.coordinate.longitude as NSNumber
            let sendMessage = message! as NSString
            let stringyUrl:NSString = self.currUser.picURL.absoluteString as NSString
            let data = ["message": sendMessage, "lat": sendLat, "long": sendLong, "name": self.currUser.name, "profPic": stringyUrl]
            self.ref.child("messages").childByAutoId().setValue(data)
            self.message = ""
            Location.sharedInstance.stopUpdatingLocation()
        }
    }
    
    func mapView(mapView: GMSMapView, didTapMarker marker: GMSMarker) -> Bool {
        for element in self.markers
        {
            if(element.0 == marker)
            {
                if(element.1 is UIImage)
                {
                    initWindow(0, object: element.1, user: element.2)
                }
                else if(element.1 is String)
                {
                    initWindow(1, object: element.1, user: element.2)
                }
            }
        }
        return false
    }
    
    private func createImage(url: NSURL) -> UIImage
    {
        return UIImage(data: NSData(contentsOfURL: url)!)!
    }
    
    private func initWindow(objectType: Int, object: AnyObject, user: User)
    {
        //let userImage = UIImage() //Replace with image from Firebase
        if(objectType == 0)
        {
            window?.hidden = true
            imageWindow?.profileName.text = user.name
            imageWindow?.circleThumbnail.setThumbnailImage(createImage(user.picURL))
            imageWindow?.userImage.image = object as? UIImage
            
        } else
        {
            imageWindow?.hidden = true
            window!.profileName.text = user.name
            window!.circleThumbnail.setThumbnailImage(createImage(user.picURL))
            window!.userMessage.text = object as! String
        }
        window!.hidden = false
    }
    
    //Image that is passed back from the Camera
    var imageToDrop: UIImage?
    
    //Message that we store from the message View
    
    var message : String?
    private var currUser = User()
    
    //Temporary current location
    private var myCurrentLocation: CLLocation?
    
    //Array of markers and what object they hold
    private var markers = [(GMSMarker, AnyObject, User)]()
    
    var window: InfoWindow?
    
    var imageWindow: ImageWindow?
    
    //Custom message view dialogue box
    var messageView: MessageView?
    
    @IBOutlet weak var mapView: GMSMapView!
    override func viewDidLoad()
    {
        super.viewDidLoad()
        //Initialize User
        getUserData()
        
        //Link the maps
        Location.sharedInstance.mapView = self.mapView
        
        //Instantiate current controller as delegate
        mapView.delegate = self
        
        //Request for authorization
        Location.sharedInstance.requestLocation()
        
        //Start gathering Location
        Location.sharedInstance.startUpdatingLocation()
        
        //Throw alert if no location
        self.throwAlert(Location.sharedInstance.shouldThrowAlert)
        delay(1) { () -> () in
            Location.sharedInstance.stopUpdatingLocation()
        }
        
        //Set up Views
        messageView = MessageView()
        window = InfoWindow()
        imageWindow = ImageWindow()
        initExtraViews()
        
        messageView!.delegate = self
        self.messageView?.messageTextField.delegate = self
        
        //See if we should drop a image marker
        self.setImageMarker()
    }
    
    func initExtraViews()
    {
        let mwidth = self.view.bounds.size.width * 0.6
        let mheight = self.view.bounds.size.height * 0.4
        let mcenterX = self.view.center.x - mwidth/2
        let mcenterY = self.view.center.y - mheight/2
        self.messageView!.frame = CGRect(x: mcenterX, y: mcenterY, width: mwidth, height: mheight)
        self.messageView!.hidden = true
        self.view.addSubview(messageView!)
        
        //Change the width and height for more compatibility with other devices
        let wwidth: CGFloat = 363.0
        let wheight: CGFloat = 300.0
        let wcenterX = self.view.center.x - wwidth/2
        let wcenterY = self.view.center.y - wheight/2
        self.window!.frame = CGRect(x: wcenterX, y: wcenterY, width: wwidth, height: wheight)
        self.window!.hidden = true
        self.view.addSubview(window!)
        
        let iwidth: CGFloat = 300.0
        let iheight: CGFloat = 450.0
        let icenterX = self.view.center.x - iwidth/2
        let icenterY = self.view.center.y - iheight/2
        self.imageWindow!.frame = CGRect(x: icenterX, y: icenterY, width: iwidth, height: iheight)
        self.imageWindow!.hidden = true
        self.view.addSubview(imageWindow!)
    }
    
    func mapView(mapView: GMSMapView, didTapAtCoordinate coordinate: CLLocationCoordinate2D) {
        messageView?.hidden = true
        messageView?.messageTextField.resignFirstResponder()
        window?.hidden = true
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n")
        {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    //Display the Alert dialogue if needed
    func throwAlert(shouldAlert: Bool)
    {
        if(shouldAlert)
        {
            self.displayNSAlert("An error occured while trying to retrieve your location", titleString: "Location Retrieval Error!")
        }
    }
    
    //Function for delays
    func delay(seconds: Double, completion:()->())
    {
        let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64( Double(NSEC_PER_SEC) * seconds ))
        
        dispatch_after(popTime, dispatch_get_main_queue())
        {
            completion()
        }
    }
    
    //Get User's Facebook data
    var imageURL:UIImageView!
    //
    func getUserData()
    {
        if((FBSDKAccessToken.currentAccessToken()) != nil)
        {
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "name, picture"]).startWithCompletionHandler( { (connection, result, error) -> Void in
                
                if (error == nil)
                {
                    self.currUser.ID = result["id"] as! String
                    
                    // GET NAME HERE
                    if let name = result["name"]
                    {
                        self.currUser.name = name as! String
                    }
                    // GET PROF PIC
                    if let url = NSURL(string: "https://graph.facebook.com/\(self.currUser.ID)/picture?type=large")
                    {
                        self.currUser.picURL = url
                    }
                    
                }
                else
                {
                    print("Error Retrieving FB Stuff")
                }
            })
        }
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    //MessageView Functions defined here
    
    func cancelButtonPressed() {
        self.messageView?.hidden = true
        self.messageView?.messageTextField.text = ""
    }
    
    func sendButtonPressed()
    {
        //Send message to firebase
        self.message = self.messageView?.messageTextField.text
        self.messageView?.hidden = true
        self.messageView?.messageTextField.text = ""
        self.setMessageMarker()
    }
    
}

