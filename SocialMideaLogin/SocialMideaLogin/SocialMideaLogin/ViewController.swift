//
//  ViewController.swift
//  SocialMideaLogin
//
//  Created by Ashutosh on 19/11/15.
//  Copyright © 2015 LetsNurture. All rights reserved.
//

import UIKit


var imgUrl = ""
var name = ""
var userName = ""
var email = ""

class ViewController: UIViewController ,FHSTwitterEngineAccessTokenDelegate, MISLinkedinShareDelegate //FBSDKLoginButtonDelegate
{

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //For Twitter--------------(1)
        
        FHSTwitterEngine.sharedEngine().permanentlySetConsumerKey("Xg3ACDprWAH8loEPjMzRg", andSecret: "9LwYDxw1iTc6D9ebHdrYCZrJP4lJhQv5uf4ueiPHvJ0")
        FHSTwitterEngine.sharedEngine().delegate = self
        FHSTwitterEngine.sharedEngine().loadAccessToken()
        //----------------------------(1)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    
    
    //For Twitter--------------(2)
    @IBAction func btnActionTwitterLogin(sender: AnyObject) {
        let loginController = FHSTwitterEngine.sharedEngine().loginControllerWithCompletionHandler { (Bool success) -> Void in
            print("success: \(success) \n")
            
            let userID = FHSTwitterEngine.sharedEngine().authenticatedUsername
            imgUrl = FHSTwitterEngine.sharedEngine().getProfileImageURLStringForUsername(userID, andSize: FHSTwitterEngineImageSizeOriginal) as! String
            userName = FHSTwitterEngine.sharedEngine().verifyCredentials().valueForKey("name") as! String
            
            let xyz = FHSTwitterEngine.sharedEngine().verifyCredentials()
            
            let svc = self.storyboard?.instantiateViewControllerWithIdentifier("secondViewController") as! secondViewController
            self.navigationController?.pushViewController(svc, animated: true)
            print("\(xyz)")
           
        }
        
        self.presentViewController(loginController, animated: true, completion: nil)
    }
    //----------------------------(2)
    // MARK: - FHSTwitterEngine Delegate
    
    func storeAccessToken(accessToken: String!) {
        NSUserDefaults.standardUserDefaults().setObject(accessToken, forKey: "SavedAccessHTTPBody")
    }
    
    func loadAccessToken() -> String? {
        if let outputStr = NSUserDefaults.standardUserDefaults().objectForKey("SavedAccessHTTPBody") as? String{
            return outputStr
        }
        return nil
    }
    
    //----------------------------
    
    
    //LinkedIn
    @IBAction func btnActionLinkedInLogin(sender: UIButton) {
        
        MISLinkedinShare.sharedInstance().linkedInDelegate = self
        MISLinkedinShare.sharedInstance().loginIntoLinkedIn(self)
    }
    
    func didFinishLinkedInLogin(dicResult: NSMutableDictionary!) {
       userName  = "\(dicResult.objectForKey("firstName") as! String) \(dicResult.objectForKey("lastName") as! String)"
       imgUrl = dicResult.objectForKey("pictureUrl") as! String
        
        let svc = self.storyboard?.instantiateViewControllerWithIdentifier("secondViewController") as! secondViewController
        self.navigationController?.pushViewController(svc, animated: true)
    }
}

