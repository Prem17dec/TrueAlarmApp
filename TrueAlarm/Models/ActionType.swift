//
//  ActionType.swift
//  TrueAlarm
//
//  Created by Prem Kumar Nallamothu on 11/12/25.
//

enum ActionType: String, Codable, CaseIterable {
    case none = "none"
    case openURL = "Open URL"
    case openContact = "Open Contact"
    case openApp = "Open App"
}
