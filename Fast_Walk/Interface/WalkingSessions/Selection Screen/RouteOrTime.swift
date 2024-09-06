//
//  RouteOrTime.swift
//  Fast_Walk
//
//  Created by Tom  on 2024/07/18.
//

import Foundation
import UIKit

class RouteOrTimeViewController: UIViewController{
    var titleLabel: UILabel!
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addTitleLabel()
        setupBackButton()
        addGradientLayer()
    }
    
    override func viewDidAppear(_ animated: Bool) {
                super.viewDidAppear(animated)
                
                // Trigger the animation when the view appears
                animateTitleLabel()
            }
        
        func addTitleLabel() {
            // Create the label
            titleLabel = UILabel()
            titleLabel.text = "さっさかコース選択"
            titleLabel.font = UIFont(name: "NotoSansJP-SemiBold", size: 30) // Noto Sans JP Medium font
            titleLabel.textColor = .black
            titleLabel.alpha = 0.0 // Initially set the label to be fully transparent (for the animation)
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            
            // Add the label to the view
            self.view.addSubview(titleLabel)
            
            // Set constraints for the label (align to top and left)
            NSLayoutConstraint.activate([
                titleLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 50),
                titleLabel.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 100)
            ])
            self.view.bringSubviewToFront(titleLabel)
        }
        
        func animateTitleLabel() {
            // Animate the label from blurry to clear
            UIView.animate(withDuration: 0.2, animations: {
                self.titleLabel.alpha = 0.8 // Fully visible after the animation
            })
        }
    func addGradientLayer() {
            // CAGradientLayer 생성
            let gradientLayer = CAGradientLayer()

            // 시작 색상: #B4E4FF, 100% 투명도
            let topColor = UIColor(red: 180/255, green: 228/255, blue: 255/255, alpha: 0.8).cgColor // #B4E4FF, 100% 투명
        
        // 중간 색상: 흰색, 75% 투명도
            let middleColor = UIColor(white: 1.0, alpha: 0.65).cgColor // 흰색 75% 투명도
        
            // 끝 색상: #D7F1FF, 25% 투명도
            let bottomColor = UIColor(red: 215/255, green: 241/255, blue: 255/255, alpha: 0.25).cgColor // #D7F1FF, 25% 투명

            // 그라데이션의 색상 배열 설정
            gradientLayer.colors = [topColor, middleColor, bottomColor]
        
        // 그라데이션의 각 색상이 적용될 위치 (0.0이 상단, 1.0이 하단)
           gradientLayer.locations = [0.0, 0.5, 1.0] // 중간 색상이 50% 위치에 오도록 설정

            // 그라데이션 레이어의 프레임 설정
            gradientLayer.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 140) // 높이 조절 가능

            // 그라데이션 위치 설정 (0.0이 상단, 1.0이 하단)
            gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
            gradientLayer.endPoint = CGPoint(x: 0.5, y: 2.0)

            // view의 레이어에 그라데이션 레이어 추가
            self.view.layer.addSublayer(gradientLayer)
        }
        
        func setupBackButton(){
            let backButton = UIButton(type: .system)
            backButton.setImage(UIImage(named: "Backbutton.png"), for: .normal)
            backButton.tintColor = UIColor(red: 84/255.0, green: 84/255.0, blue: 84/255.0, alpha: 0.9)
            backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
            
            backButton.frame = CGRect(x: 20, y: 50, width: 22, height: 22)
            
            // Add the button to the view
            view.addSubview(backButton)
            view.bringSubviewToFront(backButton)
        }
        
        @objc func backButtonTapped() {
            print("button tapped")
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let chooseVC = storyboard.instantiateViewController(withIdentifier: "WelcomeViewController") as? WelcomeViewController {
                chooseVC.modalPresentationStyle = .fullScreen
                self.present(chooseVC, animated: true, completion: nil)
            }
        }
    }
