
//  ViewController.swift
//  DiffieHelmanSample
//
//  Created by Sanu Sathyaseelan on 8/6/18.
//  Copyright © 2018 Farabi. All rights reserved.
//

import UIKit
import PromiseKit
import Alamofire

class ViewController: UIViewController {
    
    @IBOutlet weak var labelStatus: UILabel?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        labelStatus?.text = ""
    }

    
    @IBAction func requestAction(_ sender: Any) {
        
        labelStatus?.text = ""
        
        SmarrtTouch.generateKeys().then { smartTouch in
            smartTouch.validateClientPublicKey().done { [weak self] success in
                print("Success >>> \(success.result)")
                self?.labelStatus?.text = success.result
                
            }
            }.catch { [weak self] error in
                print("Errorrrr >>>> \(error.localizedDescription)")
                self?.labelStatus?.text = error.localizedDescription
        }


    }
}



