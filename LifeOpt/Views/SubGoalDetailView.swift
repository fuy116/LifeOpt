import SwiftUI

struct SubGoalDetailView: View {
    @ObservedObject var viewModel: GoalVM
    let subGoal: SubGoal
    let targetColor: String
    @State private var showingAddTask = false
    @State private var showingEditTask: Task?
    
    // 移除多餘的 init 宣告，使用預設的 memberwise initializer
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // 進度概覽卡片
                VStack(spacing: 12) {
                    // 進度條
                    VStack(alignment: .leading) {
                        Text("進度")
                            .font(.headline)
                        
                        Text("\(Int(subGoal.progress))%")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(Color(hex: targetColor))
                        
                        ProgressView(value: subGoal.progress,total: 100)
                            .progressViewStyle(LinearProgressViewStyle(tint: Color(hex: targetColor)))
                            .scaleEffect(x: 1, y: 2, anchor: .center)
                    }
                    
                    HStack {
                        Text("目標權重")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                        HStack(spacing: 2) {
                            ForEach(0..<subGoal.weight, id: \.self) { _ in
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                            }
                        }
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                
                // 任務列表
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("任務列表")
                            .font(.headline)
                        Spacer()
                        Button(action: { showingAddTask = true }) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.blue)
                        }
                    }
                    
                    if subGoal.tasks.isEmpty {
                        Text("尚無任務")
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                    } else {
                        ForEach(subGoal.tasks) { task in
                            TaskRowView(
                                task: task,
                                targetColor: targetColor,
                                onEdit: { showingEditTask = task },
                                onDelete: { deleteTask(task) }
                            )
                        }
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(10)
            }
            .padding()
        }
        .navigationTitle(subGoal.name)
        .background(Color(UIColor.systemGray6))
        .sheet(isPresented: $showingAddTask) {
            if let target = findTargetForSubGoal() {
                AddTaskView(subGoalId: subGoal.id) { task in
                    viewModel.addTask(task, to: subGoal, in: target)
                }
            }
        }
        .sheet(item: $showingEditTask) { task in
            TaskDetailView(viewModel: viewModel, task: task, subGoalId: subGoal.id)
        }
    }
    
    private func deleteTask(_ task: Task) {
        if let target = findTargetForSubGoal() {
            viewModel.deleteTask(task, from: subGoal, in: target)
        }
    }
    
    private func findTargetForSubGoal() -> Target? {
        return viewModel.targets.first { target in
            target.subGoals.contains { $0.id == subGoal.id }
        }
    }
}

struct TaskRowView: View {
    let task: Task
    let targetColor: String
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(task.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
                
                Button(action: onEdit) {
                    Image(systemName: "pencil.circle.fill")
                        .foregroundColor(.gray)
                }
                
                Button(action: onDelete) {
                    Image(systemName: "trash.circle.fill")
                        .foregroundColor(.red)
                }
            }
            
            if !task.description.isEmpty {
                Text(task.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            ProgressView(value: task.progressPercentage, total: 100)
                .progressViewStyle(LinearProgressViewStyle(tint: Color(hex: targetColor)))
            
            HStack {
                // 進度顯示
                if task.progressType == .value {
                    Text("\(Int(task.currentValue))/\(Int(task.targetValue))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else {
                    Text("\(Int(task.progressPercentage))%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // 任務類型標籤
                Text(task.taskType.rawValue.capitalized)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(hex: targetColor).opacity(0.1))
                    .foregroundColor(Color(hex: targetColor))
                    .cornerRadius(4)
            }
        }
        .padding()
        .background(Color(UIColor.systemGray6))
        .cornerRadius(8)
    }
}
