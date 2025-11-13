//
//  ContentView.swift
//  TrueAlarm
//
//  Created by Prem Kumar Nallamothu on 11/12/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext

    @Query(sort: [SortDescriptor(\Alarm.scheduledTime, order: .forward)]) private var alarms: [Alarm]

    var body: some View {
        NavigationStack {
            List {
                
                if(alarms.isEmpty){
                    ContentUnavailableView("No alarms scheduled", systemImage: "alarm.fill")
                        .listRowSeparator(.hidden)
                }
                else {
                    ForEach(alarms) { alarm in
                        AlarmRow(alarm: alarm)
                            
                        }
                    .onDelete(perform: deleteAlarm)
                }
            }
            .navigationTitle("True Alarm")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    EditButton()
                }
                ToolbarItem(placement: .topBarTrailing) {
                    
                    //Actual Button
                    Button{
                        if(alarms.isEmpty){
                            generateDummyAlarms()
                        }
                        
                    } label: {
                        Label("Add Alarm", systemImage: "plus.circle.fill")
                    }
                }
            }
        }
    }
    
    private func generateDummyAlarms(){
        
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
        
        modelContext.insert(flightAlarm)
        
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

        modelContext.insert(billsAlarm)
        
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
        
        modelContext.insert(standupCallAlarm)
    }

    private func addAlarm() {
        withAnimation {
//            let newItem = Item(timestamp: Date())
//            modelContext.insert(newItem)
        }
    }

    private func deleteAlarm(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(alarms[index])
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Alarm.self, inMemory: true)
}
