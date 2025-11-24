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
    
    //Delete alarm by swipe
    func deleteAlarms(offsets: IndexSet, alarms: [Alarm], context: ModelContext) {
        
        DispatchQueue.main.async {
            for index in offsets {
                
                //Cancel notification before deletion
                NotificationService.shared.cancel(alarm: alarms[index])
                
                context.delete(alarms[index])
            }
        }
    }
    
    func generateDummyAlarms(context: ModelContext){
        
        DispatchQueue.main.async {
            
            //Flight
            let flightTime = Calendar.current.date(byAdding: .minute, value: 1, to: Date())!
            
            let flightAlarm = Alarm(
                scheduledTime: flightTime,
                title: "Flight to India",
                note: "Don't forget your passport and boarding pass",
                category: .travel,
                isCritical: true,
                isRepeating: false,
                isSnoozeEnabled: false,
                soundName: "india",
                quickActionType: .openURL,
                quickActionTarget: "https://www.airindia.in/"
            )
            
            context.insert(flightAlarm)
            //Add system notification
            NotificationService.shared.schedule(alarm: flightAlarm)
            
            //Bills
            let billsTime = Calendar.current.date(byAdding: .minute, value: 3, to: Date())!
            
            let billsAlarm = Alarm(
                scheduledTime: billsTime,
                title: "Credit card payments",
                note: "Must pay by end of the month",
                category: .bills,
                isCritical: true,
                isRepeating: true,
                isSnoozeEnabled: true,
                soundName: "clock",
                quickActionType: .none,
                quickActionTarget: nil
            )
            
            context.insert(billsAlarm)
            //Add system notification
            NotificationService.shared.schedule(alarm: billsAlarm)

            
            //Message
            let callTime = Calendar.current.date(byAdding: .minute, value: 2, to: Date())!
            
            let standupCallAlarm = Alarm(
                scheduledTime: callTime,
                title: "Stand up Call",
                note: "Week day 10:00 - 10:20 CST",
                category: .project,
                isCritical: true,
                isRepeating: true,
                isSnoozeEnabled: false,
                soundName: "alarm",
                quickActionType: .openApp,
                quickActionTarget: "Zoom"
            )
            
            context.insert(standupCallAlarm)
            //Add system notification
            NotificationService.shared.schedule(alarm: standupCallAlarm)

        }
    }
    
}
