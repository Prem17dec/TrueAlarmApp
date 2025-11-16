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
    
    @State private var viewModel = AlarmListViewModel()
    
    @State private var isShowingAddAlarmSheet = false
    
    @State private var quickAlarmDate: Date?

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
                                        
                    //Add Button
                    HStack {
                        Button{
                            
                            quickAlarmDate = nil
                            isShowingAddAlarmSheet = true
                            
                        } label: {
                            
                            Image(systemName: "plus.circle.fill")
                                .font(.title3)
                        }
                        .simultaneousGesture(
                            
                            LongPressGesture(minimumDuration: 0.5)
                                .onEnded{ _ in
                                    
                                    var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
                                    
                                    components.day! += 1
                                    components.hour = 7
                                    components.minute = 0
                                    
                                    quickAlarmDate = Calendar.current.date(from: components) ?? Date()
                                    
                                    isShowingAddAlarmSheet = true
                                }
                        )
                    }
                }
            }
            .sheet(isPresented: $isShowingAddAlarmSheet) {
                
                AddAlarmView(quickAlarmDate: $quickAlarmDate)
            }
//            .task {
//                if alarms.isEmpty {
//                    viewModel.generateDummyAlarms(context: modelContext)
//                }
//            }
        }
    }
    
    private func deleteAlarm(offsets: IndexSet) {
        withAnimation {
            
            viewModel.deleteAlarms(offsets: offsets, alarms: alarms, context: modelContext)

        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Alarm.self, inMemory: true)
}
