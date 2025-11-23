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
    
    let sharedModelContainer: ModelContainer = {
        let schema = Schema([Alarm.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: Alarm.self, configurations: config)
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    init() {
        // Inject the ModelContainer into the NotificationService FIRST.
        NotificationService.shared.setup(with: sharedModelContainer)
        
        // 2. Request notification permission early.
        NotificationService.shared.requestAuthorization()
    }
  
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
        }
        .modelContainer(for: Alarm.self)
    }
}
