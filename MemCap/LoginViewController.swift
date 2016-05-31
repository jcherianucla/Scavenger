//
//  LoginViewController.swift
//  MemCap
//
//  Created by Connor Kenny on 5/19/16.
//  Copyright © 2016 Connor Kenny. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FBSDKCoreKit
import FBSDKLoginKit

class LoginViewController: UIViewController {
    
    // Code for signout button
    //    do {
    //    try FIRAuth.auth()?.signOut()
    //    } catch {
    //
    //    }
    
    var loggedIn = false
    
    //Should go through Facebook and login into Firebase
    @IBAction func login_pressed(sender: AnyObject)
    {
        FBSDKLoginManager().logInWithReadPermissions(["public_profile", "email", "user_friends"], fromViewController: self) { (login, error) in
            if error != nil {
                print("Facebook login failed. Error \(error)")
            } else if login.isCancelled {
                print("Facebook login was cancelled.")
            } else {
                let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
                let credential = FIRFacebookAuthProvider.credentialWithAccessToken(accessToken)
                
                if let user = FIRAuth.auth()?.currentUser {
                    user.linkWithCredential(credential) { (sup, error) in
                        if let error = error {
                            print(error.localizedDescription)
                            return
                        }
                    }
                }
                else {
                    FIRAuth.auth()?.signInWithCredential(credential) { (user, error) in
                        if let error = error
                        {
                            print(error.localizedDescription)
                            return
                        }
                    }
                }
                self.loggedIn = true
            }
        }
    }
    
    func checkLoginandSegue() {
        if ((FIRAuth.auth()?.currentUser) != nil) {
            dispatch_async(dispatch_get_main_queue(),{
                self.performSegueWithIdentifier("toMap", sender: self)
            })
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if(self.loggedIn)
        {
            dispatch_async(dispatch_get_main_queue(),{
                self.performSegueWithIdentifier("toMap", sender: self)
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}