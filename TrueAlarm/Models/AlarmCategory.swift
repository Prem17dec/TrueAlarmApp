//
//  AlarmCategory.swift
//  TrueAlarm
//
//  Created by Prem Kumar Nallamothu on 11/12/25.
//

import Foundation
import UIKit

enum AlarmCategory: String, Codable, CaseIterable{
    
    case travel = "Travel"
    case bills = "Bills"
    case messages = "Messages"
    case health = "Health"
    case study = "Study"
    case project = "Project"
    case custom = "Custom"
    
    var color: UIColor {
        switch self {
        case .travel:
            return .blue
        case .bills:
            return .orange
        case .messages:
            return .green
        case .health:
            return .purple
        case .study:
            return .yellow
        case .project:
            return .cyan
        case .custom:
            return .gray
        }
    }
}
