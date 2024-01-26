//
//  ChooseViewController.swift
//  Fast_Walk
//
//  Created by Kee Seo jung on 2024/01/19.
//

import UIKit

class ChooseViewController: UIViewController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setGradientBackground()
        addImageView()
    }
    
    func addImageView() {
        let imageView = UIImageView()
        
        // Set the desired size for the image view
        let imageViewSize = CGSize(width: 47.0, height: 80.0)
        
        // Calculate the centered origin point for the resized image view
        let originX = (view.bounds.width - imageViewSize.width) / 2.0
        let originY = (view.bounds.height - imageViewSize.height) / 5.0
        
        imageView.frame = CGRect(origin: CGPoint(x: originX, y: originY), size: imageViewSize)
        
        //imageView.frame = view.bounds
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "sasaka logo big.png")
        imageView.clipsToBounds = true // Add this line
        view.addSubview(imageView)
    }
    
    @IBAction func signUp() {
        print("signup clicked")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let loginViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController {
            loginViewController.modalPresentationStyle = .fullScreen
            loginViewController.signUp = true
            self.present(loginViewController, animated: true, completion: nil)
            print("signup is true")
        }
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
            
            // Set the thickness of the line
            let lineWidth: CGFloat = 2.0
            
            // Create a UIView for the line
            let lineView = UIView()
            lineView.backgroundColor = UIColor.white.withAlphaComponent(0.21) // White with 21% transparency
            lineView.frame = CGRect(x: 190, y: 490, width: lineWidth, height: 59)

            // Rotate the line to be vertical
            let rotationAngle = CGFloat.pi / 2.0
                    lineView.transform = CGAffineTransform(rotationAngle: rotationAngle)
            
            // Add the line to the view controller's view
            view.addSubview(lineView)
    }
    
}

