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
        guard !subGoals.isEmpty else { return 0 }
        
        let totalWeight = subGoals.reduce(0) { $0 + $1.weight }
        let weightedProgress = subGoals.reduce(0.0) { sum, subgoal in
            let weightRatio = Double(subgoal.weight) / Double(totalWeight)
           
            return sum + (subgoal.progress * weightRatio)
        }
        
        // 確保不會超過 100%
        return min(weightedProgress, 100)
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
            let weightRatio = Double(task.weight) / Double(totalWeight)

            return sum + (task.progressPercentage * weightRatio)
        }
        
        // 確保不會超過 100%
        return min(weightedProgress, 100)
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


struct Task: Identifiable, Codable {
    let id: UUID
    var name: String
    var description: String
    var startDate: Date
    var endDate: Date
    var taskType: TaskType
    var progressType: ProgressType
    var completedDates: Set<Date>
    var targetValue: Double
    var weight: Int
    var subGoalId: UUID
    
    var totalDays: Int {
        let calendar = Calendar.current
        // 使用 startOfDay 來標準化日期
        let start = calendar.startOfDay(for: startDate)
        let end = calendar.startOfDay(for: endDate)
        // 計算天數差異並加1（因為包含開始日期）
        return calendar.dateComponents([.day], from: start, to: end).day! + 1
    }
    
    // 計算進度百分比
    var progressPercentage: Double {
        switch (progressType, taskType) {
        case (.percentage, .daily):
            // 計算已完成的天數佔總天數的百分比
            let completedCount = Double(completedDates.count)
            let total = Double(totalDays)
            return (completedCount / total) * 100
            
        case (.percentage, _):
            // 其他類型的任務保持原有邏輯
            return min(Double(completedDates.count), 100)
            
        case (.value, _):
            // 數值型進度保持原有邏輯
            return min((Double(completedDates.count) / targetValue) * 100, 100)
        }
    }
    
    var currentValue: Double {
        Double(completedDates.count)
    }
    
    
    init(id: UUID = UUID(),
         name: String,
         description: String = "",
         startDate: Date = Date(),
         endDate: Date = Date().addingTimeInterval(7*24*60*60),
         taskType: TaskType = .daily,
         progressType: ProgressType = .percentage,
         completedDates: Set<Date> = [],
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
        self.completedDates = completedDates
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
