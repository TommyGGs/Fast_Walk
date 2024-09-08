//
//  EndScreenViewController.swift
//  Fast_Walk
//
//  Created by Jianjun Zhao on 2024/01/05.
//

//
//  EndScreenViewController.swift
//  Fast_Walk
//
//  Created by Jianjun Zhao on 2024/01/05.
//

import Foundation
import UIKit
import HealthKit
import CareKitUI
import CareKit
import CoreMotion


class EndScreenViewController: FigmaTestViewController {
    
    
//    @IBOutlet weak var chartFrame: UIView!
    @IBOutlet weak var diseaseLabel: UILabel!
    
    @IBOutlet weak var diseaseProgressView: UIProgressView!
    
    @IBOutlet weak var diseaseBackGround: UIView!
    
    var stepButtons: [UIButton] = []
    var todaySteps: Int = 0
    var progressNodes: [UIView] = []
    //
    let progressView = UIProgressView(progressViewStyle: .default)
       
       // Define the maximum step count for 100% progress
       let maximumSteps = 12000
    //
    let store = HealthAndCareKitHelp.healthStore
    var help = HealthAndCareKitHelp()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        authorizeHealthKit()
        setupProgressView()
        fetchStepData() { results in
            if let today = results.last{
                self.todaySteps = today
                //
                
                //
                let diseasesPrevented = self.getDiseasesPrevented(steps: today)
                print(diseasesPrevented)
            }
            
            DispatchQueue.main.async{
//                self.createCharts(results)
                self.updateProgressView(with: self.todaySteps)
            }
        }
        diseaseBackGround.layer.cornerRadius = 20
        diseaseBackGround.clipsToBounds = true
        
        
    }
    
    //Authorize HealthKit
    func authorizeHealthKit() {
        guard HKHealthStore.isHealthDataAvailable() else {
            return
        }
        
        let readTypes = Set([HKObjectType.quantityType(forIdentifier: .stepCount)!])
        
        store.requestAuthorization(toShare: nil, read: readTypes) { (success, error) in
            if !success {
                // Handle errors here.
                print("error requesting authorization")
            }
        }
    }
    //fetchSteps for last 7 days, by day.
    func fetchStepData(completion: @escaping ([Int]) -> Void) {
        guard let stepsQuantityType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            completion([])
            return
        }

        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let startDate = Calendar.current.date(byAdding: .day, value: -6, to: startOfDay) // last 7 days including today
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: now, options: .strictStartDate)

        var dateComponents = DateComponents()
        dateComponents.day = 1

        let query = HKStatisticsCollectionQuery(quantityType: stepsQuantityType,
                                                quantitySamplePredicate: predicate,
                                                options: .cumulativeSum,
                                                anchorDate: startDate!,
                                                intervalComponents: dateComponents)

        query.initialResultsHandler = { query, results, error in
            guard let statsCollection = results else {
                completion([])
                return
            }

            var dailySteps = [Int]()
            let endDate = Calendar.current.startOfDay(for: now)
            statsCollection.enumerateStatistics(from: startDate!, to: endDate) { statistics, stop in
                let count = statistics.sumQuantity()?.doubleValue(for: HKUnit.count()) ?? 0
                dailySteps.append(Int(count))
                print(Int(count)) //debug
            }

            completion(dailySteps)
            
            print(dailySteps.last) //most recent steps
            
        }

        store.execute(query)
    }
    
//    func createCharts(_ stepsArray: [Int]) {
//        let series = OCKDataSeries(
//                values: stepsArray.map { CGFloat($0) },
//                title: "今週の歩数",
//                size: 10,
//                color: .systemBlue
//            )
//
////        let chartView = OCKCartesianChartView(type: .bar)
////        chartView.translatesAutoresizingMaskIntoConstraints = false
////        chartView.headerView.titleLabel.text = "今週の歩数"
////        chartView.graphView.horizontalAxisMarkers = help.createWeeklyHorizontalAxisMarkers()
////        chartView.graphView.dataSeries = [series]
////        chartView.headerView.iconImageView?.image = UIImage(named: "sasaka logo4.png")
//        
////        chartFrame.addSubview(chartView)
//
//        NSLayoutConstraint.activate([
//            chartView.centerXAnchor.constraint(equalTo: chartFrame.centerXAnchor),
//            chartView.centerYAnchor.constraint(equalTo: chartFrame.centerYAnchor),
//            chartView.widthAnchor.constraint(equalTo: chartFrame.widthAnchor), // Adjust width as per requirement
//            chartView.heightAnchor.constraint(equalTo: chartFrame.heightAnchor, multiplier: 1) // Adjust height as per requirement
//        ])
//        
//    }
    
    func getDiseasesPrevented(steps: Int) -> [String] {
        switch steps {
        case ..<2000:
            return ["なし"]
        case 2000..<4000:
            return ["寝たきり"]
        case 4000..<5000:
            return ["うつ病"]
        case 5000..<7000:
            return ["要支援・要介護", "認知症", "心疾患", "脳卒中"]
        case 7000..<7500:
            return ["ガン", "動脈硬化", "骨粗しょう症", "骨折"]
        case 7500..<8000:
            return ["筋減少症", "体力の低下"]
        case 8000..<9000:
            return ["高血圧", "糖尿病", "脂質異常症", "メタボ（75歳以上）"]
        case 9000..<10000:
            return ["高血圧（正常高値血圧）", "高血糖"]
        case 10000..<12000:
            return ["メタボリックシンドローム（75歳未満）"]
        case 12000...:
            return ["肥満"]
        default:
            return []
        }
    }
    
    func setupProgressView() {
        // Add nodes to the progress view
        let nodePositions = [0, 3000, 6000, 9000, 12000]  // The step values for each node
        let progressViewWidth = diseaseProgressView.frame.width  // Assuming 20 points padding on each side
        let totalSteps = Float(maximumSteps)

        for stepValue in nodePositions {
            let nodeView = UIView()
            nodeView.backgroundColor = .gray  // Default color
              // Half the height to make it circular
            nodeView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(nodeView)
            
            // Calculate the x position of the node based on step values
            let xPosition = progressViewWidth * CGFloat(Float(stepValue) / totalSteps)
            
            NSLayoutConstraint.activate([
                nodeView.centerXAnchor.constraint(equalTo: diseaseProgressView.leadingAnchor, constant: xPosition),
                nodeView.centerYAnchor.constraint(equalTo: diseaseProgressView.centerYAnchor),
                nodeView.widthAnchor.constraint(equalToConstant: 20),
                nodeView.heightAnchor.constraint(equalToConstant: 20),
                diseaseProgressView.heightAnchor.constraint(equalToConstant: 10)
            ])
            
            nodeView.layer.cornerRadius = 10
            
            // Store the node in an array for later reference
            progressNodes.append(nodeView)
        }
    }
    func updateProgressView(with steps: Int) {
        let progress = Float(steps) / Float(maximumSteps)
        diseaseProgressView.setProgress(progress, animated: true)
        
        // Update the nodes colors based on current steps
        for (index, node) in progressNodes.enumerated() {
            let stepThresholds = [0, 3000, 6000, 9000, 12000]
            if steps >= stepThresholds[index] {
                node.backgroundColor = UIColor(red: 83/255, green: 131/255, blue: 236/255, alpha: 1.0) // #5383EC
            } else {
                node.backgroundColor = .gray  // Default color
            }
        }
        
        // Call the function to get diseases prevented and do something with the results
        let diseasesPrevented = getDiseasesPrevented(steps: steps)
        // Update the disease label with the latest disease that can be prevented
        DispatchQueue.main.async{
            self.diseaseLabel.text = diseasesPrevented.last
        }
        
    }

    
}

