//
//  TrueAlarmApp.swift
//  TrueAlarm
//
//  Created by Prem Kumar Nallamothu on 11/12/25.
//

import SwiftUI
import SwiftData

@main
struct TrueAlarmApp: App {
  
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
                .task {
                    NotificationService.shared.requestAuthorization()
                }
        }
        .modelContainer(for: Alarm.self)
    }
}
