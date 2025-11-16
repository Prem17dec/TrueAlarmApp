//
//  AlarmListViewModel.swift
//  TrueAlarm
//
//  Created by Prem Kumar Nallamothu on 11/15/25.
//

import Foundation
import SwiftData

@Observable
final class AlarmListViewModel {
    
    func deleteAlarms(offsets: IndexSet, alarms: [Alarm], context: ModelContext) {
        
        DispatchQueue.main.async {
            for index in offsets {
                context.delete(alarms[index])
            }
        }
    }
    
    func generateDummyAlarms(context: ModelContext){
        
        DispatchQueue.main.async {
            
            //Flight
            let flightTime = Calendar.current.date(byAdding: .day, value: 7, to: Date())!
            
            let flightAlarm = Alarm(
                scheduledTime: flightTime,
                title: "Flight to India",
                note: "Don't forget your passport and boarding pass",
                category: .travel,
                isCritical: true,
                quickActionType: .openURL,
                quickActionTarget: "https://www.airindia.in/"
            )
            
            context.insert(flightAlarm)
            
            //Bills
            let billsTime = Calendar.current.date(byAdding: .day, value: 30, to: Date())!
            
            let billsAlarm = Alarm(
                scheduledTime: billsTime,
                title: "Credit card payments",
                note: "Must pay by end of the month",
                category: .bills,
                isCritical: true,
                isRepeating: true,
                quickActionType: .none
            )
            
            context.insert(billsAlarm)
            
            //Message
            let callTime = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
            
            let standupCallAlarm = Alarm(
                scheduledTime: callTime,
                title: "Stand up Call",
                note: "Week day 10:00 - 10:20 CST",
                category: .project,
                isCritical: true,
                isRepeating: true,
                quickActionType: .openApp,
                quickActionTarget: "Stand up on zoom."
            )
            
            context.insert(standupCallAlarm)
        }
    }
    
}
