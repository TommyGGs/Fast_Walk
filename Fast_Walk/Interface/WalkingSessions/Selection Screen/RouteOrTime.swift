//
//  RouteOrTime.swift
//  Fast_Walk
//
//  Created by Tom  on 2024/07/18.
//

import Foundation
import UIKit

class RouteOrTimeViewController: UIViewController{
    @IBAction func TimeButton(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let mainNavController = storyboard.instantiateViewController(withIdentifier: "MainNavigationController") as? UINavigationController {
            mainNavController.modalPresentationStyle = .fullScreen
            self.present(mainNavController, animated: true, completion: nil)
        }
    }
    
    @IBAction func RouteButton(){
        let storyboard = UIStoryboard(name: "RouteStoryboard", bundle: nil)
        if let mainNavController = storyboard.instantiateViewController(withIdentifier: "RouteNavigationController") as? UINavigationController {
            mainNavController.modalPresentationStyle = .fullScreen
            self.present(mainNavController, animated: true, completion: nil)
        }
    }
}
