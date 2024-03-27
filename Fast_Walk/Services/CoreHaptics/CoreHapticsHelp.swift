//
//  CoreHapticsHelp.swift
//  Fast_Walk
//
//  Created by Jiaxu Zhao (FIS) on 2024/03/27.
//

import Foundation
import CoreHaptics

class CoreHapticsHelp {
    static let shared = CoreHapticsHelp() // Singleton instance
    private var hapticEngine: CHHapticEngine?
    
    private init() { // Private initialization to ensure singleton usage
        prepareHapticEngine()
    }
    
    private func prepareHapticEngine() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        do {
            hapticEngine = try CHHapticEngine()
            try hapticEngine?.start()
            
            // Handle engine reset to automatically restart the engine
            hapticEngine?.resetHandler = { [weak self] in
                do {
                    try self?.hapticEngine?.start()
                } catch {
                    print("Failed to restart haptic engine: \(error)")
                }
            }
            
        } catch {
            print("Haptic engine Creation Error: \(error)")
        }
    }
    
    func makeHapticEvent(_ type: String) -> [CHHapticEvent]{
        switch type{
//        case "fast":
//            let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.3)
//            let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1)
//            let attackTime = CHHapticEventParameter(parameterID: .attackTime, value: 0)
//            let decayTime = CHHapticEventParameter(parameterID: .decayTime, value: 1.7)
//            let event = CHHapticEvent(eventType: .hapticContinuous, parameters: [intensity, sharpness, attackTime, decayTime], relativeTime: 0, duration: 2)
//            return [event]
//        case "slow":
//            
//            let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
//            let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1)
//            let attackTime = CHHapticEventParameter(parameterID: .attackTime, value: 0)
//            let decayTime = CHHapticEventParameter(parameterID: .decayTime, value: 1)
//            let event = CHHapticEvent(eventType: .hapticContinuous, parameters: [intensity, sharpness, attackTime, decayTime], relativeTime: 0, duration: 2)
//            return [event]
        case "fast":
            var events = [CHHapticEvent]()
            let initialSharpness: Float = 0.2 // Starting sharpness
            let sharpnessIncrease: Float = 0.1 // Sharpness increase per event
            var currentTime: Float = 0
            let timeIncrease: Float = 0.15 // Decrease time increase to make it faster initially and slow down towards the end

            for i in 0..<11 {
                let sharpnessValue = initialSharpness + sharpnessIncrease * Float(i)
                let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpnessValue)
                let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1 - (sharpnessValue - initialSharpness)) // Adjust intensity inversely to sharpness
                let event = CHHapticEvent(eventType: .hapticTransient, parameters: [sharpness, intensity], relativeTime: TimeInterval(currentTime))
                events.append(event)
                currentTime += (0.1 + Float(i) * timeIncrease / 10) // Decrease increment to increase speed of succession
            }
            return events
        case "slow":
            var events = [CHHapticEvent]()
            let initialSharpness: Float = 1.0 // Starting sharpness
            let sharpnessDecrease: Float = 0.1 // Sharpness decrease per event
            var currentTime: Float = 0
            let timeDecrease: Float = 0.2 // Increase time decrease to slow down initially and speed up towards the end

            for i in 0..<11 {
                let sharpnessValue = initialSharpness - sharpnessDecrease * Float(i)
                let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpnessValue)
                let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: sharpnessValue) // Match intensity with sharpness
                let event = CHHapticEvent(eventType: .hapticTransient, parameters: [sharpness, intensity], relativeTime: TimeInterval(currentTime))
                events.append(event)
                currentTime += (0.4 - Float(i) * timeDecrease / 10) // Decrease increment to make the events closer together over time
            }
            return events
        default:
            let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
            let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1)
            let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0)
            return [event]
        }

    
        
    }
    
    func playHapticPattern(_ type:String) {
        let event = self.makeHapticEvent(type)
        guard let engine = hapticEngine else { return }

        
        do {
            let pattern = try CHHapticPattern(events: event, parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            print("Failed to play pattern: \(error)")
        }
    }
}
