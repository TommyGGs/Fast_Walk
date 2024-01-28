//
//  FigmaTestViewController.swift
//  Fast_Walk
//
//  Created by Jiaxu Zhao (FIS) on 2024/01/27.
//

import Foundation
import UIKit

class FigmaTestViewController: UIViewController{
    override func viewDidLoad() {
        super.viewDidLoad()
        // Auto layout, variables, and unit scale are not yet supported
        setupViews()
    }
    func setupViews(){
        setupFrameView()
        setupCircularView()
    }
    func setupFrameView(){
        var view = UIView()
        view.frame = CGRect(x: 0, y: 0, width: 396, height: 852)
        view.layer.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1).cgColor
        view.layer.cornerRadius = 20
        setupScreenShot(parent: view)
        setupTopGradient(parent: view)
        setupSasakaLabel(parent: view)
    }
    func setupCircularView(){
        
    }
    func setupScreenShot(parent: UIView){
        var view = UIView()
        view.frame = CGRect(x: 0, y: 0, width: 400, height: 382)
        let image0 = UIImage(named: "スクリーンショット 2024-01-06 午後3.43.png")?.cgImage
        let layer0 = CALayer()
        layer0.contents = image0
        layer0.transform = CATransform3DMakeAffineTransform(CGAffineTransform(a: 1.42, b: 0, c: 0, d: 1, tx: -0.21, ty: 0))
        layer0.bounds = view.bounds
        layer0.position = view.center
        view.layer.addSublayer(layer0)
        view.layer.cornerRadius = 6
        var parent = parent
        parent.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.widthAnchor.constraint(equalToConstant: 400).isActive = true
        view.heightAnchor.constraint(equalToConstant: 382).isActive = true
        view.leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: -7).isActive = true
        view.topAnchor.constraint(equalTo: parent.topAnchor, constant: -224).isActive = true
    }
    func setupTopGradient(parent: UIView){
        var view = UIView()
        view.frame = CGRect(x: 0, y: 0, width: 393, height: 317)
        let layer0 = CAGradientLayer()
        layer0.colors = [
        UIColor(red: 1, green: 1, blue: 1, alpha: 1).cgColor,
        UIColor(red: 1, green: 1, blue: 1, alpha: 0).cgColor
        ]
        layer0.locations = [0, 1]
        layer0.startPoint = CGPoint(x: 0.25, y: 0.5)
        layer0.endPoint = CGPoint(x: 0.75, y: 0.5)
        layer0.transform = CATransform3DMakeAffineTransform(CGAffineTransform(a: 0, b: -0.18, c: 0.39, d: -0.01, tx: 0.33, ty: 0.29))
        layer0.bounds = view.bounds.insetBy(dx: -0.5*view.bounds.size.width, dy: -0.5*view.bounds.size.height)
        layer0.position = view.center
        view.layer.addSublayer(layer0)
        var parent = parent
        parent.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.widthAnchor.constraint(equalToConstant: 393).isActive = true
        view.heightAnchor.constraint(equalToConstant: 317).isActive = true
        view.leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: 0).isActive = true
        view.topAnchor.constraint(equalTo: parent.topAnchor, constant: -11).isActive = true
    }
    func setupSasakaLabel(parent: UIView){
        // Auto layout, variables, and unit scale are not yet supported
        var view = UILabel()
        view.frame = CGRect(x: 0, y: 0, width: 81, height: 30)
        view.textColor = UIColor(red: 0.219, green: 0.447, blue: 0.945, alpha: 1)
        view.font = UIFont(name: "NotoSansJP-Black", size: 18)
        // Line height: 26.06 pt
        view.textAlignment = .center
        view.text = "SaSaka"

        var parent = parent
        parent.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.widthAnchor.constraint(equalToConstant: 81).isActive = true
        view.heightAnchor.constraint(equalToConstant: 30).isActive = true
        view.leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: 17).isActive = true
        view.topAnchor.constraint(equalTo: parent.topAnchor, constant: 12).isActive = true
    }
    
}
