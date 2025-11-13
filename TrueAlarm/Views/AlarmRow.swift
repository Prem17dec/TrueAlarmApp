//
//  AlarmRow.swift
//  TrueAlarm
//
//  Created by Prem Kumar Nallamothu on 11/12/25.
//

import SwiftUI

struct AlarmRow: View {
    
    let alarm: Alarm
    
    var body: some View {
        
        
        VStack {
            VStack (alignment: .leading) {
                
                Text(alarm.title)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(Color(alarm.category.color))
                    .opacity(0.9)
                
                
                HStack {
                    if alarm.isCritical {
                        Image(systemName: "exclamationmark.circle.fill")
                            .font(.title3)
                            .foregroundStyle(Color(alarm.category.color))
                    }
                    
                    if alarm.quickActionType != .none {
                        
                        HStack (spacing: 4) {
                            
                            Image(systemName: alarm.quickActionType == .openURL ? "link.circle.fill" : "message.circle.fill")
                            
                            Text(alarm.quickActionType.rawValue)
                        }
                        .font(.title2)
                        .foregroundStyle(Color(alarm.category.color)).opacity(0.7)
                        
                    }
                }.padding(10)
            }
            
            HStack (alignment: .top) {
                
                VStack(alignment: .leading, spacing: 7) {
                    
                    Text(alarm.scheduledTime, style: .time)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color(alarm.category.color))
                        .opacity(0.9)
                    
                    Text("\(alarm.scheduledTime, style: .date)")
                        .font(.title2)
                        .fontWeight(.light)
                        .foregroundStyle(Color(alarm.category.color))
                        .opacity(0.9)
                }
                
                Spacer()
                
                Text(alarm.category.rawValue)
                    .font(.title3)
                    .fontWeight(.medium)
                    .padding()
                    .background(Color(alarm.category.color))
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
                    .padding(.vertical, 5)
                    .padding(.horizontal, 10)
                    .shadow(color: Color.black.opacity(0.1), radius: 5)
                    .cornerRadius(10)
                
            }.padding(.horizontal, 17)
        }
    }
}
#Preview {
    AlarmRow(alarm: Alarm(scheduledTime: Date.now, title: "Preview", category: .health, isCritical: true, quickActionType: .openApp))
}
