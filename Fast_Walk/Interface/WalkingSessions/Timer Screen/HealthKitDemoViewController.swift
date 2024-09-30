import UIKit
import HealthKit
import CareKit
import CareKitUI
import CoreMotion

class HealthKitDemoViewController: UIViewController {
    
    @IBOutlet weak var stepsLabel: UILabel!
    let pedometer = CMPedometer()
    
    var totalSteps: Double = 0
    var totalDistance: Double = 0
    let healthStore = HKHealthStore()
    var anchor: HKQueryAnchor?
    var averagePace: Float = 0
    var duration: Int = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        setGradientBackground()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        authorizeHealthKit()
    }
    
    func startWorkoutSession() {
//        startObservingSteps()
        startPedometerUpdates()
        print("workoutsession works")
    }
    
    func endWorkoutSession() {
    }
    
    @objc func updateStepCount() {
//        fetchStepData()
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
//    func fetchStepData() {
//        guard let stepsType = HKObjectType.quantityType(forIdentifier: .stepCount) else {
//            return
//        }
//        
//        // Define the start and end of the day
//        let calendar = Calendar.current
//        let startDate = calendar.startOfDay(for: Date()) // Start of the current day
//        let endDate = calendar.date(byAdding: .day, value: 1, to: startDate) // End of the current day
//
//        // Create the predicate
//        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
//
//        let query = HKAnchoredObjectQuery(type: stepsType, predicate: predicate, anchor: anchor, limit: HKObjectQueryNoLimit) { [weak self] query, sampleObjects, deletedObjects, newAnchor, error in
//            guard let self = self else { return }
//            
//            if let newAnchor = newAnchor {
//                self.anchor = newAnchor
//            }
//            
//            if let samples = sampleObjects as? [HKQuantitySample] {
//                totalSteps = samples.map { $0.quantity.doubleValue(for: HKUnit.count()) }.reduce(0, +)
//                DispatchQueue.main.async {
//                    self.stepsLabel.text = "Steps: \(Int(self.totalSteps))"
//                }
//            }
//        }
//        
//        healthStore.execute(query)
//    }
//    
//
//    // Start Observing Steps
//    func startObservingSteps() {
//        fetchStepData()
//    }
    
    
//    func setGradientBackground() {
//        let gradientLayer = CAGradientLayer()
//        gradientLayer.frame = view.bounds
//        
//        // Set your custom colors
//        gradientLayer.colors = [
//            UIColor(red: 0x45/255.0, green: 0xB1/255.0, blue: 0xFF/255.0, alpha: 1.0).cgColor,
//            UIColor(red: 0x00/255.0, green: 0x21/255.0, blue: 0xCD/255.0, alpha: 1.0).cgColor
//        ]
//
//        // You can customize the direction of the gradient if needed
//        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.8)
//        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.0)
//
//        // Add the gradient layer to your view's layer
//        view.layer.insertSublayer(gradientLayer, at: 0)
//    }
    
    
    func startPedometerUpdates() {
        if CMPedometer.isStepCountingAvailable() {
            print("Step counting is available")

            pedometer.startUpdates(from: Date()) { [weak self] data, error in
                if let error = error {
                    print("There was an error retrieving the data: \(error.localizedDescription)")
                    return
                }

                guard let pedometerData = data else {
                    print("No pedometer data received")
                    return
                }
//printing out received data
                print("Pedometer data received: \(pedometerData.numberOfSteps)")
                print("Pedometer distance received: \(pedometerData.distance)")
                print("Pedometer current pace received: \(pedometerData.currentPace)")
                print("Pedometer current cadence received: \(pedometerData.currentCadence)")
                
                
                DispatchQueue.main.async {
                    self?.stepsLabel.text = "合計: \(pedometerData.numberOfSteps)歩"
                    print("UI Updated")
                }
//                self?.totalSteps = Double(pedometerData.numberOfSteps)
//                if let distance = pedometerData.distance{
//                    self?.totalDistance = Double(distance)
//                }
//                if let pace = pedometerData.averageActivePace{
//                    self?.averagePace = Float(pace)
//                    print("pace is" + String(describing: pace))
//                }
                
                guard let totalSteps = self?.totalSteps, let totalDistance = self?.totalDistance, let averagePace = self?.averagePace else {
                    return
                }
                self!.totalSteps = Double(pedometerData.numberOfSteps)
                
                // Handle optional distance
                if let distance = pedometerData.distance {
                    // Check for sudden spikes in distance (e.g., > 100m in a short time might be unreasonable)
                    if distance.doubleValue > 0 && distance.doubleValue < 1000 {
                        self!.totalDistance = Double(distance)
                    }
                }

                // Handle optional average pace
                if let pace = pedometerData.averageActivePace {
                    // Ignore unreasonable paces
                    if pace.doubleValue > 0 && pace.doubleValue < 10 {
                        self!.averagePace = Float(pace.doubleValue)
                    }
                }
                
            }
        } else {
            print("Step counting is not available")
        }
    }
    

    func updateUI(with data: CMPedometerData) {
        stepsLabel.text = "Steps: \(data.numberOfSteps)"
        print(data.numberOfSteps)
        
        // Example: Update a label with the step count
        // yourStepCountLabel.text = "Steps: \(data.numberOfSteps)"
    }
    
    func stopPedometerUpdates() {
        pedometer.stopUpdates()
    }
    
    func calculateAvgPace(){
        
    }

       

       override func viewWillDisappear(_ animated: Bool) {
           stopPedometerUpdates()
           print("stopped")
           super.viewWillDisappear(animated)
           
       }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        if let endVC = segue.destination as? EndViewController {
            endVC.receivedStepCount = self.totalSteps
            print("this is the steps", self.totalSteps)
            endVC.receivedDistance = self.totalDistance
            endVC.receivedAvgPace = self.averagePace
            endVC.receivedTime = self.duration
        }
    }
}

