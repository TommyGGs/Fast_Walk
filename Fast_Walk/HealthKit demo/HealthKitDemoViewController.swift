import UIKit
import HealthKit
import CareKit
import CareKitUI

class HealthKitDemoViewController: UIViewController {
    
    @IBOutlet weak var stepsLabel: UILabel!

    let healthStore = HKHealthStore()
    var anchor: HKQueryAnchor?
    //var timer: Timer!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        authorizeHealthKit()
    }

    func startWorkoutSession() {
        startObservingSteps()
//        timer = Timer.scheduledTimer(timeInterval: 180, target: self, selector: #selector(updateStepCount), userInfo: nil, repeats: true)
    }

    func endWorkoutSession() {
//        timer?.invalidate()
//        timer = nil
    }

    @objc func updateStepCount() {
        fetchStepData()
    }

    // Authorization
    func authorizeHealthKit() {
        guard HKHealthStore.isHealthDataAvailable() else {
            return
        }
        
        let readTypes = Set([HKObjectType.quantityType(forIdentifier: .stepCount)!])
        
        healthStore.requestAuthorization(toShare: nil, read: readTypes) { (success, error) in
            if !success {
                // Handle errors here.
                print("Error requesting authorization: \(String(describing: error))")
            }
        }
    }

    // Fetch Steps
    func fetchStepData() {
        guard let stepsType = HKObjectType.quantityType(forIdentifier: .stepCount) else {
            return
        }

        let query = HKAnchoredObjectQuery(type: stepsType, predicate: nil, anchor: anchor, limit: HKObjectQueryNoLimit) { [weak self] query, sampleObjects, deletedObjects, newAnchor, error in
            guard let self = self else { return }
            
            if let newAnchor = newAnchor {
                self.anchor = newAnchor
            }

            if let samples = sampleObjects as? [HKQuantitySample] {
                let totalSteps = samples.map { $0.quantity.doubleValue(for: HKUnit.count()) }.reduce(0, +)
                DispatchQueue.main.async {
                    self.stepsLabel.text = "Steps: \(Int(totalSteps))"
                }
            }
        }

        healthStore.execute(query)
    }
    

    // Start Observing Steps
    func startObservingSteps() {
        fetchStepData()
    }
    
  }

