//
//  NotificationService.swift
//  TrueAlarm
//
//  Created by Prem Kumar Nallamothu on 11/18/25.
//

import Foundation
import UserNotifications
import UIKit
import SwiftData

final class NotificationService{
    
    static let shared = NotificationService()
    
    private let delegate: NotificationDelegate
    
    private init() {
        self.delegate = NotificationDelegate()
        
        self.delegate.parentService = self
    }
    
    private var modelContainer: ModelContainer?
    
    func setup(with container: ModelContainer){
        self.modelContainer = container
    }
    
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
        
        let soundFile = "\(alarm.soundName).mp3"
        
        content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: soundFile))
        
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
        
        weak var parentService: NotificationService?
        
        //When notification is in foreground
        func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
            
            await self.handleAlarmTrigger(notification: notification)
            return [.banner]
        }
        
        //When user interacts with notification
        func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
            
            await self.handleAlarmTrigger(notification: response.notification)
            
            print( "User responded to notification: \(response.notification.request.identifier)")
            
            
            switch response.actionIdentifier {
                
            case UNNotificationDefaultActionIdentifier:
                print("User tapped on the notification")
                
            case UNNotificationDismissActionIdentifier:
                print("User Dismissed the notification")
                
            default:
                print("Custom action identifier: \(response.actionIdentifier) ")
            }
        }
        
        private func handleAlarmTrigger(notification: UNNotification) async {
            
            let userInfo = notification.request.content.userInfo
            
            guard let alarmIDString = userInfo["alarmID"] as? String,
                  let alarmID = UUID(uuidString: alarmIDString) else{
                
                print("Couldn't extract alarmID from notification userInfo")
                return
            }
            
            guard let container = parentService?.modelContainer else {
                
                print("Model Container not set up in Notification Service")
                return
            }
            
            do{
                let context = ModelContext(container)
                let predicate = #Predicate<Alarm> { $0.id == alarmID}
                
                let descriptor = FetchDescriptor(predicate: predicate)
                
                guard let alarm = try context.fetch(descriptor).first else {
                    print("Couldn't find Alarm with \(alarmIDString) in Swift Data")
                    return
                }
                
                AudioService.shared.startAlarm(soundName: alarm.soundName)
            }
            catch {
                print("Error fetching Alarm from Swift Data: \(error)")
            }
        }
    }
}
