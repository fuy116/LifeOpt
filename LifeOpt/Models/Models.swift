//
//  Models.swift
//  LiftOpt
//
//  Created by Sean Fu on 2024/12/9.
//

// Models.swift'
import SwiftUI
struct OverviewItem: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let value: String
    let color: Color
}

struct ProgressItem: Identifiable {
    let id = UUID()
    let title: String
    var progress: Double
    let color: Color
}

struct AchievementItem: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let subtitle: String
}

struct Goal:Identifiable{
    let id = UUID()
    let title: String
    var description: String?
    var progress: Double
    let color: Color
    var startDate: Date?
    var dueDate: Date?
    
}
struct SubGoal {
    var name: String
    var isEditing: Bool = false
}

struct Task{
    var name: String
    var isFinish: Bool = false
    var startDate: Date?
    var dueDate: Date?
    
}
