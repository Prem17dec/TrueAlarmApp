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


/*
 
 // MARK: - Notification Manager Class
 class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
 
 static let shared = NotificationManager()
 private let notificationCenter = UNUserNotificationCenter.current()
 
 private override init() {
 super.init()
 notificationCenter.delegate = self
 // Request authorization and configure categories on initialization
 requestAuthorization()
 configureNotificationCategories()
 }
 
 // MARK: - Authorization & Configuration
 
 func requestAuthorization() {
 notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
 if granted {
 print("Notification authorization granted.")
 } else if let error = error {
 print("Notification authorization error: \(error.localizedDescription)")
 }
 }
 }
 
 private func configureNotificationCategories() {
 // 1. Bills Category with a 'Quick Pay' action
 let quickPayAction = UNNotificationAction(identifier: "QUICK_PAY_ACTION", title: "Quick Pay 💳", options: [.foreground])
 let billsCategory = UNNotificationCategory(
 identifier: TrueAlarmCategory.bills.notificationCategoryID,
 actions: [quickPayAction], intentIdentifiers: [], options: .customDismissAction
 )
 
 // 2. Messages Category with 'Call' and 'Message' actions
 let callAction = UNNotificationAction(identifier: "CALL_ACTION", title: "Call Person 📞", options: [.foreground])
 let messageAction = UNNotificationAction(identifier: "MESSAGE_ACTION", title: "Open Message App 💬", options: [.foreground])
 let messagesCategory = UNNotificationCategory(
 identifier: TrueAlarmCategory.messages.notificationCategoryID,
 actions: [callAction, messageAction], intentIdentifiers: [], options: .customDismissAction
 )
 
 notificationCenter.setNotificationCategories([billsCategory, messagesCategory])
 }
 
 // MARK: - Scheduling
 
 func scheduleAlarm(alarm: TrueAlarm) {
 // If the alarm is disabled, ensure any pending notification is cancelled
 guard alarm.isEnabled else {
 cancelAlarm(alarmID: alarm.id)
 return
 }
 
 let content = UNMutableNotificationContent()
 content.title = alarm.title
 content.body = "\(alarm.category.rawValue): \(alarm.notes ?? "Time to take action!")"
 content.categoryIdentifier = alarm.category.notificationCategoryID
 // Note: You must add a file named 'TrueAlarm_Ring.mp3' (or .wav/.aiff) to your Xcode project to use this custom sound
 content.sound = UNNotificationSound(named: UNNotificationSoundName("TrueAlarm_Ring.mp3"))
 
 let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: alarm.date)
 let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
 
 let request = UNNotificationRequest(identifier: alarm.id.uuidString, content: content, trigger: trigger)
 
 notificationCenter.add(request) { error in
 if let error = error {
 print("Error scheduling alarm \(alarm.title): \(error.localizedDescription)")
 } else {
 print("Scheduled: \(alarm.title) for \(alarm.date)")
 }
 }
 }
 
 func cancelAlarm(alarmID: UUID) {
 notificationCenter.removePendingNotificationRequests(withIdentifiers: [alarmID.uuidString])
 print("Cancelled alarm with ID: \(alarmID)")
 }
 
 // MARK: - UNUserNotificationCenterDelegate (Action Handling)
 
 func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
 
 switch response.actionIdentifier {
 case "QUICK_PAY_ACTION":
 // Placeholder: Attempts to open a specific banking app scheme
 if let url = URL(string: "bankingapp://pay") {
 UIApplication.shared.open(url)
 }
 
 case "CALL_ACTION":
 // Placeholder: Attempts to open the Phone app
 if let url = URL(string: "tel://1-555-555-5555") {
 UIApplication.shared.open(url)
 }
 
 case "MESSAGE_ACTION":
 // Placeholder: Attempts to open a messaging app
 if let url = URL(string: "whatsapp://") {
 UIApplication.shared.open(url)
 }
 
 default:
 break
 }
 
 completionHandler()
 }
 
 // Critical: Allows the notification to present itself even when the app is foregrounded
 func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
 completionHandler([.banner, .sound])
 }
 }

 */
