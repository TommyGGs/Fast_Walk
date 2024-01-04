//
//  Healthdata.swift
//  Fast_Walk
//
//  Created by visitor on 2024/01/02.
//

import Foundation
import UIKit
import HealthKit

class HealthKitDemoViewController: UIViewController {
    
    @IBOutlet weak var stepsLabel: UILabel!
    
    
    let store = HealthKitData.healthStore
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        authorizeHealthKit()
        
        
    }
    
    @IBAction func press(_ sender: Any) {
        
        fetchStepData { steps in
            DispatchQueue.main.async {
                self.stepsLabel.text = "\(steps) steps"
                self.updateStepsLabel(steps)
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
    
    private func updateStepsLabel(_ stepsArray: [Int]) {
            let stepsString = stepsArray.map { String($0) }.joined(separator: ",")
            stepsLabel.text = stepsString
        }
}
