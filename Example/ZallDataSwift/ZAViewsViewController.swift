//
//  ZAViewsViewController.swift
//  ZallDataSwift
//
//  Created by Mac on 2022/1/26.
//  Copyright © 2022 Zall Data Co., Ltd. All rights reserved.
//

import UIKit

class ZAViewsViewController: UIViewController {
     
    @IBOutlet weak var myLabel:UILabel?
    @IBOutlet weak var myButton:UIButton?
    @IBOutlet weak var myButtonItem:UIButton?
    @IBOutlet weak var mySecond:UISegmentedControl?
    @IBOutlet weak var myTextField:UITextField?
    @IBOutlet weak var mySlider:UISlider?
    @IBOutlet weak var mySwitch:UISwitch?
    @IBOutlet weak var myActivityIndicator:UIActivityIndicatorView?
    @IBOutlet weak var myProgressView:UIProgressView?
    @IBOutlet weak var myPageControl:UIPageControl?
    @IBOutlet weak var myStepper:UIStepper?
    @IBOutlet weak var myImageView:UIImageView?
    @IBOutlet weak var myTextView:UITextView?
    @IBOutlet weak var myDataPicker:UIDatePicker?
   
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func mybuttonAction(_ sender: Any){
        
    }
    @IBAction func myButtonItemAction(_ sender: Any){
        
    }
    @IBAction func mySecondAction(_ sender: Any){
        
    }
    @IBAction func myTextFieldAction(_ sender: Any){
        
    }
    @IBAction func mySliderAction(_ sender: UISlider){
        self.myProgressView?.progress = sender.value;
    }
    @IBAction func mySwitchAction(_ sender: UISwitch){
        if (sender.isOn) {
            self.myActivityIndicator?.startAnimating()
        }else{
            self.myActivityIndicator?.stopAnimating()
        }
    }
    @IBAction func myPageAction(_ sender: Any){
        
    }
    @IBAction func myStepper(_ sender: Any){
        
    }
    @IBAction func myDataPicker(_ sender: Any){
        
    }
  

}
