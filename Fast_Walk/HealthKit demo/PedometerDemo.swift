//
//  PedometerDemo.swift
//  Fast_Walk
//
//  Created by Jiaxu Zhao (FIS) on 2024/01/19.
//

import Foundation
import UIKit
import CoreMotion

class PedometerDemoViewController: UIViewController{
    
    @IBOutlet weak var stepcounter: UILabel!
    
    
    let pedometer = CMPedometer()

       override func viewWillAppear(_ animated: Bool) {
           super.viewWillAppear(animated)
           startPedometerUpdates()
       }

       override func viewWillDisappear(_ animated: Bool) {
           super.viewWillDisappear(animated)
           stopPedometerUpdates()
       }

    func startPedometerUpdates() {
        if CMPedometer.isStepCountingAvailable() {
            pedometer.startUpdates(from: Date()) { [weak self] data, error in
                guard let strongSelf = self, let pedometerData = data, error == nil else {
                    print("There was an error retrieving the data: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }

                // Update your UI with pedometer data
                DispatchQueue.main.async {
                    // Example: Update step count label
                    strongSelf.updateUI(with: pedometerData)
                    print("UI Updated")
                }
            }
        } else {
            print("Step counting not available")
        }
    }

    func updateUI(with data: CMPedometerData) {
        stepcounter.text = "Steps: \(data.numberOfSteps)"
        print(data.numberOfSteps)
        // Example: Update a label with the step count
        // yourStepCountLabel.text = "Steps: \(data.numberOfSteps)"
    }
    
    func stopPedometerUpdates() {
        pedometer.stopUpdates()
    }

}
