//
//  secondViewController.swift
//  SocialMideaLogin
//
//  Created by Ashutosh on 19/11/15.
//  Copyright © 2015 LetsNurture. All rights reserved.
//

import UIKit

class secondViewController: UIViewController {

    @IBOutlet weak var lblFirstName: UILabel!
    
    @IBOutlet weak var lblSecondName: UILabel!
    
    @IBOutlet weak var lblThirdName: UILabel!
    
    @IBOutlet weak var imgView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let url = NSURL(string: imgUrl as String) {
            if let data = NSData(contentsOfURL: url){
                imgView.image = UIImage(data: data)!
                }
        }
        
        lblFirstName.text = userName
        //lblSecondName.text =
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
