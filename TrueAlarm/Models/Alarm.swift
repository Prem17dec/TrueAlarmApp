//
//  Alarm.swift
//  TrueAlarm
//
//  Created by Prem Kumar Nallamothu on 11/12/25.
//

import Foundation
import SwiftData

@Model
final class Alarm {
    @Attribute(.unique) var id: UUID
    var scheduledTime: Date
    var title: String
    var note: String?
    
    var category: AlarmCategory
    var isCritical: Bool
    
    var isRepeating: Bool
    var isSnoozeEnabled: Bool
    
    var quickActionType: ActionType
    var quickActionTarget: String?
    
    init(scheduledTime: Date, title: String, note: String? = nil, category: AlarmCategory,
    isCritical: Bool, isRepeating: Bool = false, isSnoozeEnabled: Bool = false,
         quickActionType: ActionType, quickActionTarget: String? = nil) {
        self.id = UUID()
        self.scheduledTime = scheduledTime
        self.title = title
        self.note = note
        self.category = category
        self.isCritical = isCritical
        self.isRepeating = isRepeating
        self.isSnoozeEnabled = isSnoozeEnabled
        self.quickActionType = quickActionType
        self.quickActionTarget = quickActionTarget
    }
}
