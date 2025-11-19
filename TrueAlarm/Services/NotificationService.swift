//
//  NotificationService.swift
//  TrueAlarm
//
//  Created by Prem Kumar Nallamothu on 11/18/25.
//

import Foundation
import UserNotifications

final class NotificationService{
    
    static let shared = NotificationService()
    
    private init() {}
    
    func requestAuthorization() {
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge, .criticalAlert]) { granted, error in
            
            if(granted){
                DispatchQueue.main.async{
                    print("Notifications authorization granted")
                    UNUserNotificationCenter.current().delegate = self.delegate
                }
            }else if let error = error{
                print("Notification authorization failed: \(error.localizedDescription)")
            }else {
                print("Notifications authorization denied")
            }
        }
    }
    
    func schedule(alarm: Alarm){
        
        guard alarm.scheduledTime > Date() else {
            print( "Alarm is already scheduled or already passed")
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = alarm.title
        content.body = alarm.note ?? "Scheduled Alarm"
        content.sound = .default
        
        if alarm.isCritical {
            content.interruptionLevel = .critical
        }
        else{
            content.interruptionLevel = .active
        }
        
        //Custom User Info
        content.userInfo["alarmID"] = alarm.id.uuidString
        
        let calendar = Calendar.current
        var dateComponents: DateComponents
        
        if alarm.isRepeating {
            dateComponents = calendar.dateComponents([.hour, .minute, .second], from: alarm.scheduledTime)
        } else {
            dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: alarm.scheduledTime)
        }
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: alarm.isRepeating)
        
        let requestIdentifier = alarm.id.uuidString
        
        let request = UNNotificationRequest(identifier: requestIdentifier, content: content, trigger: trigger)
        
        //Schedule notification
        UNUserNotificationCenter.current().add(request) { error in
            
            if let error = error {
                print("Error scheduling notification for \(alarm.title): \(error.localizedDescription)")
            }
            else{
                print("Successfully scheduled notification for \(alarm.title) with ID: \(requestIdentifier)")
            }
        }
    }
    
    //Cancel one alarm
    func cancel(alarm: Alarm){
        let requestIdentifier = alarm.id.uuidString
        
        print("Cancelling pending notification for alarm ID: \(requestIdentifier)")
        
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [requestIdentifier])
    }
    
    //Cancel all alarms
    func cancelAllPending(){
        
        print( "Cancelling all pending notifications")
        
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    //Dummy delegate
    private final class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
        
        //When notification is in foreground
        func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
            
            return [.banner, .sound, .badge]
        }
        
        //When user interacts with notification
        func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
            
            print( "User responded to notification: \(response.notification.request.identifier)")
            
            let userInfo = response.notification.request.content.userInfo
            
            if let alarmID = userInfo["alarmID"] as? String{
                print("Alarm ID associated with this notification is: \(alarmID)")
            }
            
            switch response.actionIdentifier {
                
            case UNNotificationDefaultActionIdentifier:
                print("User tapped on the notification")
                
            case UNNotificationDismissActionIdentifier:
                print("User Dismissed the notification")
                
            default:
                print("Custom action identifier: \(response.actionIdentifier) ")
            }
        }
    }
    private let delegate = NotificationDelegate()
}
