//
//  HealthKitData.swift
//  Fast_Walk
//
//  Created by visitor on 2024/01/02.
//

import Foundation
import HealthKit
import CareKit
import CareKitUI

class HealthAndCareKitHelp {
    static let healthStore: HKHealthStore = HKHealthStore()
    
    func addGraph (){
        
    }
    
    private func createMonthDayDateFormatter() -> DateFormatter {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "MM/dd"
        
        return dateFormatter
    }
    
    func createHorizontalAxisMarkers(lastDate: Date = Date(), useWeekdays: Bool = true) -> [String] {
        let calendar: Calendar = .current
        let weekdayTitles = ["日", "月", "火", "水", "木", "金", "土"]
        
        var titles: [String] = []
        
        if useWeekdays {
            titles = weekdayTitles
            
            let weekday = calendar.component(.weekday, from: lastDate)
            
            return Array(titles[weekday..<titles.count]) + Array(titles[0..<weekday])
        } else {
            let numberOfTitles = weekdayTitles.count
            let endDate = lastDate
            let startDate = calendar.date(byAdding: DateComponents(day: -(numberOfTitles - 1)), to: endDate)!
            
            let dateFormatter = createMonthDayDateFormatter()

            var date = startDate
            
            while date <= endDate {
                titles.append(dateFormatter.string(from: date))
                date = calendar.date(byAdding: .day, value: 1, to: date)!
            }
            
            return titles
        }
    }
    func createConstraints(){}
}

