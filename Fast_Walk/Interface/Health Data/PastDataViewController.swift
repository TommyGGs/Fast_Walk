//
//  PastDataViewController.swift
//  Fast_Walk
//
//  Created by visitor on 2024/01/27.
//

import Foundation
import UIKit
import GoogleMaps
import CoreLocation
import GooglePlaces
import HealthKitUI
import HealthKit
import CareKitUI


class PastDataViewController: UIViewController{
    var help = HealthAndCareKitHelp()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLabels()
    }
    func setupLabels(){
        // Auto layout, variables, and unit scale are not yet supported
        var view = UILabel()
        view.frame = CGRect(x: 0, y: 0, width: 219, height: 43)
        view.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        view.font = UIFont(name: "NotoSansJP-Medium", size: 29)
        // Line height: 41.99 pt
        view.text = "ウォーキング"

        var parent = self.view!
        parent.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.widthAnchor.constraint(equalToConstant: 219).isActive = true
        view.heightAnchor.constraint(equalToConstant: 43).isActive = true
        view.leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: 12).isActive = true
        view.topAnchor.constraint(equalTo: parent.topAnchor, constant: 62).isActive = true
        
        
        
    }
    
    func setupButton(){
        // Auto layout, variables, and unit scale are not yet supported
        var buttonview = UIView()
        buttonview.frame = CGRect(x: 0, y: 0, width: 177, height: 178)

        var parent = self.view!
        parent.addSubview(view)
        buttonview.translatesAutoresizingMaskIntoConstraints = false
        buttonview.widthAnchor.constraint(equalToConstant: 177).isActive = true
        buttonview.heightAnchor.constraint(equalToConstant: 178).isActive = true
        buttonview.leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: 108).isActive = true
        buttonview.topAnchor.constraint(equalTo: parent.topAnchor, constant: 647).isActive = true
        
        // Auto layout, variables, and unit scale are not yet supported
        var buttonEclipseView = UIView()
        buttonEclipseView.frame = CGRect(x: 0, y: 0, width: 144, height: 150)
        var shadows = UIView()
        shadows.frame = buttonEclipseView.frame
        shadows.clipsToBounds = false
        buttonEclipseView.addSubview(shadows)

        let shadowPath0 = UIBezierPath(roundedRect: shadows.bounds, cornerRadius: 0)
        let layer0 = CALayer()
        layer0.shadowPath = shadowPath0.cgPath
        layer0.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        layer0.shadowOpacity = 1
        layer0.shadowRadius = 4
        layer0.shadowOffset = CGSize(width: 0, height: 4)
        layer0.bounds = shadows.bounds
        layer0.position = shadows.center
        shadows.layer.addSublayer(layer0)

        var shapes = UIView()
        shapes.frame = view.frame
        shapes.clipsToBounds = true
        view.addSubview(shapes)

        let layer1 = CALayer()
        layer1.backgroundColor = UIColor(red: 0.027, green: 0.075, blue: 0.167, alpha: 1).cgColor
        layer1.bounds = shapes.bounds
        layer1.position = shapes.center
        shapes.layer.addSublayer(layer1)

        shapes.layer.borderWidth = 2
        shapes.layer.borderColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1).cgColor

       buttonview.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.widthAnchor.constraint(equalToConstant: 144).isActive = true
        view.heightAnchor.constraint(equalToConstant: 150).isActive = true
        view.leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: 16).isActive = true
        view.topAnchor.constraint(equalTo: parent.topAnchor, constant: 14).isActive = true
        
    }
    
    //testing for past cadence average.
    
    
    func createCharts(_ stepsArray: [Int]) {
        let series = OCKDataSeries(
                values: stepsArray.map { CGFloat($0) },
                title: "今週の歩数",
                size: 10,
                color: .systemBlue
            )

        let chartView = OCKCartesianChartView(type: .bar)
        chartView.translatesAutoresizingMaskIntoConstraints = false
        chartView.headerView.titleLabel.text = "今週の歩数"
        chartView.graphView.horizontalAxisMarkers = help.createWeeklyHorizontalAxisMarkers()
        chartView.graphView.dataSeries = [series]
        chartView.headerView.iconImageView?.image = UIImage(named: "sasaka logo4.png")
        
        view.addSubview(chartView)

        NSLayoutConstraint.activate([
            chartView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            chartView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            chartView.widthAnchor.constraint(equalTo: view.widthAnchor), // Adjust width as per requirement
            chartView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1) // Adjust height as per requirement
        ])
        
    }
}
