//
//  EndViewController.swift
//  Fast_Walk
//
//  Created by visitor on 2023/12/22.
//

import UIKit
import CoreMotion



class EndViewController: EndScreenViewController{

    let pedometer = CMPedometer()
    @IBOutlet weak var steps: UILabel!
    @IBOutlet weak var stepcounter: UILabel!
    var receivedStepCount: Double = 0
    
    override func viewDidLoad(){
        super.viewDidLoad()
        DispatchQueue.main.async{
            self.steps.text = String(Int(self.receivedStepCount))
        }
        // Do any additional setup after loading the view.
    }
    
    @IBAction func updatePedometer(_ sender: Any) {
        
        startPedometerUpdates()
        print ("view did appear, loaded pedometer")
    }
    
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

                print("Pedometer data received: \(pedometerData.numberOfSteps)")
                
                DispatchQueue.main.async {
                    self?.stepcounter.text = "Steps: \(pedometerData.numberOfSteps)"
                    print("UI Updated")
                }
            }
        } else {
            print("Step counting is not available")
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

       

       override func viewWillDisappear(_ animated: Bool) {
           stopPedometerUpdates()
           print("stopped")
           super.viewWillDisappear(animated)
           
       }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

