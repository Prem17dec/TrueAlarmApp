//
//  AddAlarmView.swift
//  TrueAlarm
//
//  Created by Prem Kumar Nallamothu on 11/15/25.
//

import SwiftUI
import SwiftData

struct AddAlarmView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Binding var quickAlarmDate: Date?
    
    @State private var viewModel: AddAlarmViewModel
    
    init(quickAlarmDate: Binding<Date?>){
        
        self._quickAlarmDate = quickAlarmDate
        
        self._viewModel = State(initialValue: AddAlarmViewModel(quickAlarmDate: quickAlarmDate.wrappedValue))
        
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Alarm Details"){
                    
                    DatePicker("When?", selection: $viewModel.scheduledTime, displayedComponents: [.date, .hourAndMinute]).datePickerStyle(.compact)
                    
                    TextField("Title (e.g., Boarding Time)",
                              text: $viewModel.title
                    ).textInputAutocapitalization(.words)
                    TextField("Note (Optional)",
                              text: $viewModel.note,
                              axis: .vertical
                    ).textInputAutocapitalization(.sentences)
                    
                    Picker("Sound", selection: $viewModel.soundName){
                        
                        ForEach(viewModel.availableSounds, id: \.self){ sound in
                            Text(sound.replacingOccurrences(of: "_", with: " ").capitalized).tag(sound)
                        }
                    }
                    
                }
                
                Section("Priority & Classification"){
                    
                    Picker("Category", selection: $viewModel.category){
                        
                        ForEach(AlarmCategory.allCases, id: \.self){ category in
                            
                            Text(category.rawValue).tag(category)
                        }
                    }
                    
                    Toggle(isOn: $viewModel.isCritical) {
                        Label("Critical Alarm", systemImage: "exclamationmark.triangle.fill")
                            .foregroundStyle(viewModel.isCritical ? .red : .primary)
                    }
                    
                    Text("If you mark an alarm as critical, it will bypass Do Not Disturb settings.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Section("Recurrence"){
                    
                    Toggle("Repeat Daily", isOn: $viewModel.isRepeating)
                    
                    Toggle(isOn: $viewModel.isSnoozeEnabled) {
                        
                        Label("Enable Snooze", systemImage: "clock.arrow.2.circlepath")
                    }
                }
                
                Section("Quick Actions"){
                    
                    Picker("Action Type", selection: $viewModel.quickActionType){
                        
                        ForEach(ActionType.allCases, id: \.self){action in
                            
                            Text(action.rawValue).tag(action)
                        }
                    }
                    
                    if viewModel.quickActionType != .none {
                        
                        TextField(targetPlaceholder(for: viewModel.quickActionType), text: $viewModel.quickActionTarget)
                            .textInputAutocapitalization(.never)
                    }
                }
                
                Button("Save Alarm"){
                    saveAndDismiss()
                }
                .frame(maxWidth: .infinity)
                .controlSize(.large)
                .buttonStyle(.borderedProminent)
                .disabled(!viewModel.isTitleValid)
            }
            .navigationTitle("New True Alarm")
            .toolbar{
                ToolbarItem(placement: .topBarLeading){
                    Button("Cancel"){
                        quickAlarmDate = nil
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func saveAndDismiss(){
        
        viewModel.saveAlarm(context: modelContext)
        
        quickAlarmDate = nil
        
        dismiss()
    }
    
    private func targetPlaceholder(for type: ActionType) -> String {
        
        switch type {
            
        case .none:
            return ""
            
        case .openURL:
            return "URL"
        case .openContact:
            return "Contact Name"
        case .openApp:
            return "App Name"
        }
    }
    
}

#Preview {
    AddAlarmView(quickAlarmDate: .constant(Date.now))
        .modelContainer(for: Alarm.self, inMemory: true)
}
