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
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Alarm.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
