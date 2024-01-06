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

class EndScreenViewController: UIViewController {
    
    
    let store = HealthAndCareKitHelp.healthStore
    var help = HealthAndCareKitHelp()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        authorizeHealthKit()
        fetchStepData() { results in
            DispatchQueue.main.async{
                self.createChart(results)
            }
            
        }
        
        
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
            }

            completion(dailySteps)
        }

        store.execute(query)
    }
    
    func createChart(_ stepsArray: [Int]) {
        let series = OCKDataSeries(
                values: stepsArray.map { CGFloat($0) },
                title: "Steps",
                size: 10,
                color: .systemBlue
            )

        let chartView = OCKCartesianChartView(type: .bar)
        chartView.translatesAutoresizingMaskIntoConstraints = false
        chartView.headerView.titleLabel.text = "Steps"
        chartView.graphView.horizontalAxisMarkers = help.createHorizontalAxisMarkers()

        chartView.graphView.dataSeries = [series]
        view.addSubview(chartView)
        }
    
    
}

