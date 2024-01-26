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
    @IBOutlet weak var stepsLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var paceLabel: UILabel!
    
    @IBOutlet weak var homeButton: UIButton!
    
    var receivedStepCount: Double = 0
    var receivedDistance: Double = 0
    var receivedTime: Int = 0
    var receivedAvgPace: Float = 0
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        let durationMinutes: Int = self.receivedTime / 60
        let durationSeconds: Int = self.receivedTime % 60
        let roundedAvgPace = round(receivedAvgPace * 100) / 100.0
        
        DispatchQueue.main.async{
            self.setupLabels()
            self.stepsLabel.text = (String(Int(self.receivedStepCount)) + " 歩")
            self.distanceLabel.text = ( "距離：\n" + String(Int(self.receivedDistance)) + "m")
            self.timeLabel.text =  String(format: "%02d分%02d秒", durationMinutes, durationSeconds)
            self.paceLabel.text = ("平均速度: " + String(1 / self.receivedAvgPace) + "m/s")
            
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
                    self?.stepsLabel.text = "Steps: \(pedometerData.numberOfSteps)"
                    print("UI Updated")
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
    
    func setupLabels(){
        stepsLabel.layer.cornerRadius = 20
        distanceLabel.layer.cornerRadius = 20
        distanceLabel.clipsToBounds = true
        distanceLabel.backgroundColor = #colorLiteral(red: 0.6540186405, green: 0.78854388, blue: 0.9540631175, alpha: 1)
        paceLabel.backgroundColor = #colorLiteral(red: 0.6540186405, green: 0.78854388, blue: 0.9540631175, alpha: 1)
        paceLabel.layer.cornerRadius = 20
        paceLabel.clipsToBounds = true
        homeButton.backgroundColor = #colorLiteral(red: 0.5374762416, green: 0.7084607482, blue: 0.9500582814, alpha: 1)
        homeButton.layer.cornerRadius = homeButton.frame.height / 2
        
    }

       

       override func viewWillDisappear(_ animated: Bool) {
           stopPedometerUpdates()
           print("stopped")
           super.viewWillDisappear(animated)
           
       }
}

