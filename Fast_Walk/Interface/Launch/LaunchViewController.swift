//
//  LaunchViewController.swift
//  Fast_Walk
//
//  Created by Tom  on 2024/07/18.
//

import UIKit

class LaunchViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setGradientBackground()
        addImageView()
    }
    
    func addImageView() {
       let imageView = UIImageView()
       
       // Set the desired size for the image view
       let imageViewSize = CGSize(width: 67.0, height: 115.0)
       
       // Calculate the centered origin point for the resized image view
       let originX = (view.bounds.width - imageViewSize.width) / 2.0
       let originY = (view.bounds.height - imageViewSize.height) / 2.7
               
       imageView.frame = CGRect(origin: CGPoint(x: originX, y: originY), size: imageViewSize)
       
       //imageView.frame = view.bounds
       imageView.contentMode = .scaleAspectFill
       imageView.image = UIImage(named: "sasaka logo megabig.png")
       imageView.clipsToBounds = true // Add this line
       view.addSubview(imageView)
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
