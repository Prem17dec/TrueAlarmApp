//
//  AddAlarmViewModel.swift
//  TrueAlarm
//
//  Created by Prem Kumar Nallamothu on 11/15/25.
//

import Foundation
import SwiftData

@Observable
final class AddAlarmViewModel{
    
    var scheduledTime: Date
    var title: String = ""
    var note: String = ""
    
    var category: AlarmCategory = .custom
    var isCritical: Bool = false
    
    var isRepeating: Bool = false
    var isSnoozeEnabled: Bool = false
    
    var quickActionType: ActionType = .none
    var quickActionTarget: String = ""

    var isTitleValid: Bool { !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    
    init(quickAlarmDate: Date?){
        
        let initialDate = quickAlarmDate ?? Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
        
        self.scheduledTime = initialDate
        
        if quickAlarmDate != nil {
            self.isCritical = true
            self.isSnoozeEnabled = true
        }
    }
    
    
    func saveAlarm(context: ModelContext){
        
        guard isTitleValid else { return }
        
        let newAlarm = Alarm(
            scheduledTime: scheduledTime,
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            note: note.isEmpty ? nil : note.trimmingCharacters(in: .whitespacesAndNewlines),
            category: category,
            isCritical: isCritical,
            isSnoozeEnabled: isSnoozeEnabled,
            quickActionType: quickActionType,
            quickActionTarget: quickActionTarget.isEmpty ? nil : quickActionTarget
        )
        
        DispatchQueue.main.async {
            context.insert(newAlarm)
        }
    }
}
