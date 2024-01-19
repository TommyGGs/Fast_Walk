import UIKit
import HealthKit
import CareKit
import CareKitUI
import CoreMotion

class HealthKitDemoViewController: PedometerDemoViewController {
    
    @IBOutlet weak var stepsLabel: UILabel!
    
    let healthStore = HKHealthStore()
    var anchor: HKQueryAnchor?
    //var timer: Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setGradientBackground()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        authorizeHealthKit()
    }
    
    func startWorkoutSession() {
        startObservingSteps()
        print("workoutsession works")
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
    func startPedometer(){
        
    }

    // Start Observing Steps
    func startObservingSteps() {
        fetchStepData()
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

