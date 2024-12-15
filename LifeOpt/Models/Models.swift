//
//  Models.swift
//  LiftOpt
//
//  Created by Sean Fu on 2024/12/9.
//

// Models.swift'
import SwiftUI
import Foundation
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

struct Target: Identifiable, Codable {
    let id: UUID
    var name: String
    var description: String
    var startDate: Date
    var endDate: Date
    var subGoals: [SubGoal]
    var color: String // 用hex 存
    
 
    var totalProgress: Double {

        if subGoals.isEmpty {
                return 0
            }
          let totalWeight = subGoals.reduce(0) { $0 + $1.weight }
          let weightedProgress = subGoals.reduce(0.0) { sum, subgoal in
              // 每個子目標的權重佔比
              let weightRatio = Double(subgoal.weight) / Double(totalWeight)
              return sum + (subgoal.progress * weightRatio * 100)
          }
          
          return weightedProgress / 100
        
      }
    
    init(id: UUID = UUID(),
         name: String,
         description: String = "",
         startDate: Date = Date(),
         endDate: Date = Date().addingTimeInterval(7*24*60*60),
         subGoals: [SubGoal] = [],
         color: String = "#007AFF") {
        self.id = id
        self.name = name
        self.description = description
        self.startDate = startDate
        self.endDate = endDate
        self.subGoals = subGoals
        self.color = color
    }
    
}



struct SubGoal: Identifiable, Codable {
    let id: UUID
    var name: String
    var weight: Int // 權重 1-10 每個星星佔2
    var tasks: [Task]
    var targetId: UUID // 關聯到主目標
    

    var progress: Double {
        guard !tasks.isEmpty else { return 0 }
        
        let totalWeight = tasks.reduce(0) { $0 + $1.weight }
        let weightedProgress = tasks.reduce(0.0) { sum, task in
            // 每個任務的權重佔比
            let weightRatio = Double(task.weight) / Double(totalWeight)
            return sum + (task.progressPercentage * weightRatio * 100)
        }
        
        return weightedProgress / 100
    }
    
    init(id: UUID = UUID(),
         name: String,
         weight: Int = 1,
         tasks: [Task] = [],
         targetId: UUID) {
        self.id = id
        self.name = name
        self.weight = weight
        self.tasks = tasks
        self.targetId = targetId
    }
}

// MARK: - 任務模型
struct Task: Identifiable, Codable {
    let id: UUID
    var name: String
    var description: String
    var startDate: Date
    var endDate: Date
    var taskType: TaskType
    var progressType: ProgressType
    var currentValue: Double
    var targetValue: Double
 
    var weight: Int // 權重 1-10
    var subGoalId: UUID // 關聯到子目標
    
    // 計算進度百分比
    var progressPercentage: Double {
        switch progressType {
        case .percentage:
            return currentValue
        case .value:
            return (currentValue / targetValue) * 100
        }
    }
    
    init(id: UUID = UUID(),
         name: String,
         description: String = "",
         startDate: Date = Date(),
         endDate: Date = Date().addingTimeInterval(7*24*60*60),
         taskType: TaskType = .daily,
         progressType: ProgressType = .percentage,
         currentValue: Double = 0,
         targetValue: Double = 100,
         weight: Int = 1,
         subGoalId: UUID) {
        self.id = id
        self.name = name
        self.description = description
        self.startDate = startDate
        self.endDate = endDate
        self.taskType = taskType
        self.progressType = progressType
        self.currentValue = currentValue
        self.targetValue = targetValue
        self.weight = weight
        self.subGoalId = subGoalId
    }
}


enum TaskType: String, Codable {
    case daily = "daily"
    case weekly = "weekly"
    case monthly = "monthly"
    case custom = "custom"
}

enum ProgressType: String, Codable {
    case percentage
    case value     // 數值進度
}
