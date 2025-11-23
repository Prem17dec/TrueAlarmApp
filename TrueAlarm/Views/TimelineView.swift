//
//  TimelineView.swift
//  TrueAlarm
//
//  Created by Prem Kumar Nallamothu on 11/22/25.
//

import SwiftUI
import SwiftData

struct TimelineView: View {
    
    @Environment(\.modelContext) private var modelContext
    
    
    @Query(sort: [SortDescriptor(\Alarm.scheduledTime, order: .forward)]) private var alarms: [Alarm]
    
    @State private var viewModel = AlarmListViewModel()
    
    @StateObject private var audioService = AudioService.shared
    
    @State private var isShowingAddAlarmSheet = false
    @State private var quickAlarmDate: Date?

    
    var body: some View {
        
        NavigationStack {
            
            if audioService.isRinging {
                
                VStack {
                    
                    Spacer()
                    
                    Button("Dismiss Alarm") {
                        audioService.stopAlarm()
                    }
                    .font(.title2)
                    .fontWeight(.heavy)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red.opacity(0.7))
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.horizontal, 20)
                    .padding(.bottom, 25)
                }
                .transition(.opacity.animation(.easeInOut))
                .zIndex(1)
            }
            
            List{
                
                if alarms.isEmpty {
                    ContentUnavailableView("No Alarms Scheduled", systemImage: "alarm.fill")
                        .listRowSeparator(.hidden)
                }
                else{
                    ForEach(alarms) { alarm in
                        
                        AlarmRow(alarm: alarm)
                    }.onDelete(perform: deleteAlarms)
                }
            }
            .navigationTitle("True Alarm Timeline")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    EditButton()
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button{
                        
                        quickAlarmDate = nil
                        isShowingAddAlarmSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                    .simultaneousGesture(LongPressGesture(minimumDuration: 0.5)
                        .onEnded { _ in
                            var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
                            
                            components.day! += 1
                            components.hour = 0
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
    }
    
    private func deleteAlarms(at offsets: IndexSet) {
        
        withAnimation {
            viewModel.deleteAlarms(offsets: offsets, alarms: alarms, context: modelContext)
        }
    }
}

#Preview {
    TimelineView()
}
