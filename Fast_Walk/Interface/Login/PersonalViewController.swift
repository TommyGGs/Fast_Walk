//
//  PersonalViewController.swift
//  Fast_Walk
//
//  Created by Kee Seo jung on 2024/01/23.
//

import UIKit

class PersonalViewController: UIViewController{
    @IBOutlet weak var abcd: UILabel!
    @IBOutlet weak var birthday: UILabel!
    @IBOutlet weak var gender: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setGradientBackground()
        efgh()
        birthday1()
        gender1()
        
        func birthday1(){
            birthday.textColor = UIColor.white
            
        }
        
        func gender1(){
            gender.textColor = UIColor.white
        }
        
        func efgh(){
            abcd.textColor = UIColor.white
        }
        
        func setGradientBackground() {
            let gradientLayer = CAGradientLayer()
            gradientLayer.frame = view.bounds
            
            // Set your custom colors
            gradientLayer.colors = [
                UIColor(red: 0x45/255.0, green: 0xB1/255.0, blue: 0xFF/255.0, alpha: 1.0).cgColor,
                UIColor(red: 0x00/255.0, green: 0x21/255.0, blue: 0xCD/255.0, alpha: 1.0).cgColor
            ]
            
            // You can customize the direction of the gradient if needed
            gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.8)
            gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.0)
            
            // Add the gradient layer to your view's layer
            view.layer.insertSublayer(gradientLayer, at: 0)
        }
    }
}
