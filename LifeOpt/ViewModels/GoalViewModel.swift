import SwiftUI
import Combine

class GoalVM: ObservableObject {
    // MARK: - Published Properties
    @Published var targets: [Target] = [
        Target(name: "提升職場競爭力",
             description: "透過學習新技能提升競爭力",
             color: "#007AFF"),
        Target(name: "保持健康生活",
             description: "養成運動習慣",
             color: "#34C759")
    ]
    
    // MARK: - Initialization
    init() {
        loadData()
    }
    
    // MARK: - Target (原 Goal) CRUD
    func addTarget(_ target: Target) {
        targets.append(target)
        saveData()
    }
    
    func updateTarget(_ target: Target) {
        if let index = targets.firstIndex(where: { $0.id == target.id }) {
            targets[index] = target
            saveData()
        }
    }
    
    func deleteTarget(_ target: Target) {
        targets.removeAll { $0.id == target.id }
        saveData()
    }
    
    // MARK: - SubGoal CRUD
    func addSubGoal(_ subGoal: SubGoal, to target: Target) {
        if let index = targets.firstIndex(where: { $0.id == target.id }) {
            var updatedTarget = target
            updatedTarget.subGoals.append(subGoal)
            targets[index] = updatedTarget
            saveData()
        }
    }
    
    func updateSubGoal(_ subGoal: SubGoal, in target: Target) {
        if let targetIndex = targets.firstIndex(where: { $0.id == target.id }),
           let subGoalIndex = targets[targetIndex].subGoals.firstIndex(where: { $0.id == subGoal.id }) {
            var updatedTarget = targets[targetIndex]
            updatedTarget.subGoals[subGoalIndex] = subGoal
            targets[targetIndex] = updatedTarget
            saveData()
        }
    }
    
    func deleteSubGoal(_ subGoal: SubGoal, from target: Target) {
        if let targetIndex = targets.firstIndex(where: { $0.id == target.id }) {
            var updatedTarget = targets[targetIndex]
            updatedTarget.subGoals.removeAll { $0.id == subGoal.id }
            targets[targetIndex] = updatedTarget
            saveData()
        }
    }
    
    // MARK: - Task CRUD
    func addTask(_ task: Task, to subGoal: SubGoal, in target: Target) {
        if let targetIndex = targets.firstIndex(where: { $0.id == target.id }),
           let subGoalIndex = targets[targetIndex].subGoals.firstIndex(where: { $0.id == subGoal.id }) {
            var updatedTarget = targets[targetIndex]
            var updatedSubGoal = updatedTarget.subGoals[subGoalIndex]
            updatedSubGoal.tasks.append(task)
            updatedTarget.subGoals[subGoalIndex] = updatedSubGoal
            targets[targetIndex] = updatedTarget
            saveData()
        }
    }
    
    func updateTask(_ task: Task, in subGoal: SubGoal, in target: Target) {
        if let targetIndex = targets.firstIndex(where: { $0.id == target.id }),
           let subGoalIndex = targets[targetIndex].subGoals.firstIndex(where: { $0.id == subGoal.id }),
           let taskIndex = targets[targetIndex].subGoals[subGoalIndex].tasks.firstIndex(where: { $0.id == task.id }) {
            var updatedTarget = targets[targetIndex]
            var updatedSubGoal = updatedTarget.subGoals[subGoalIndex]
            updatedSubGoal.tasks[taskIndex] = task
            updatedTarget.subGoals[subGoalIndex] = updatedSubGoal
            targets[targetIndex] = updatedTarget
            saveData()
        }
    }
    
    func deleteTask(_ task: Task, from subGoal: SubGoal, in target: Target) {
        if let targetIndex = targets.firstIndex(where: { $0.id == target.id }),
           let subGoalIndex = targets[targetIndex].subGoals.firstIndex(where: { $0.id == subGoal.id }) {
            var updatedTarget = targets[targetIndex]
            var updatedSubGoal = updatedTarget.subGoals[subGoalIndex]
            updatedSubGoal.tasks.removeAll { $0.id == task.id }
            updatedTarget.subGoals[subGoalIndex] = updatedSubGoal
            targets[targetIndex] = updatedTarget
            saveData()
        }
    }
    
    // MARK: - Data Persistence
    private func saveData() {
        if let encodedTargets = try? JSONEncoder().encode(targets) {
            UserDefaults.standard.set(encodedTargets, forKey: "targets")
        }
    }
    
    private func loadData() {
        if let savedTargets = UserDefaults.standard.data(forKey: "targets"),
           let decodedTargets = try? JSONDecoder().decode([Target].self, from: savedTargets) {
            self.targets = decodedTargets
        }
    }
    
    // MARK: - Helper Methods
    func getSubGoals(for target: Target) -> [SubGoal] {
        if let targetIndex = targets.firstIndex(where: { $0.id == target.id }) {
            return targets[targetIndex].subGoals
        }
        return []
    }
    
    func getTasks(for subGoal: SubGoal, in target: Target) -> [Task] {
        if let targetIndex = targets.firstIndex(where: { $0.id == target.id }),
           let subGoalIndex = targets[targetIndex].subGoals.firstIndex(where: { $0.id == subGoal.id }) {
            return targets[targetIndex].subGoals[subGoalIndex].tasks
        }
        return []
    }
    
    // MARK: - Data Validation
    func validateTarget(_ target: Target) -> Bool {
        return !target.name.isEmpty && target.startDate < target.endDate
    }
    
    func validateSubGoal(_ subGoal: SubGoal) -> Bool {
        return !subGoal.name.isEmpty && subGoal.weight > 0 && subGoal.weight <= 10
    }
    
    func validateTask(_ task: Task) -> Bool {
        return !task.name.isEmpty &&
               task.startDate < task.endDate &&
               task.weight > 0 &&
               task.weight <= 10 &&
               task.targetValue > 0
    }
    
    func updateTaskProgress(_ task: Task, isCompleted: Bool) {
        for (targetIndex, target) in targets.enumerated() {
            for (subGoalIndex, subGoal) in target.subGoals.enumerated() {
                if let taskIndex = subGoal.tasks.firstIndex(where: { $0.id == task.id }) {
                    var updatedTask = task
                    updatedTask.currentValue = isCompleted ? updatedTask.targetValue : 0
                    
                    var updatedSubGoal = subGoal
                    updatedSubGoal.tasks[taskIndex] = updatedTask
                    
                    var updatedTarget = target
                    updatedTarget.subGoals[subGoalIndex] = updatedSubGoal
                    
                    targets[targetIndex] = updatedTarget
                    saveData()
                    return
                }
            }
        }
    }
}
