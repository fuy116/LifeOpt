import SwiftUI

struct AddSubGoalView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: GoalVM
    let targetId: UUID // 關聯的主目標ID
    
    @State private var subGoalName: String = ""
    @State private var weight: Int = 1
    @State private var taskName: String = ""
    @State private var tasks: [Task] = []
    
    // 添加狀態管理
    @State private var showingTaskView = false
    @State private var selectedTask: Task?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // 子目標名稱
                VStack(alignment: .leading, spacing: 16) {
                    Text("子目標名稱")
                        .font(.headline)
                    TextField("", text: $subGoalName)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(8)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(16)
                
                // 權重設置
                VStack(alignment: .leading, spacing: 16) {
                    Text("目標權重")
                        .font(.headline)
                    HStack {
                        ForEach(1...5, id: \.self) { index in
                            Image(systemName: index <= weight ? "star.fill" : "star")
                                .foregroundColor(index <= weight ? .yellow : .gray)
                                .onTapGesture {
                                    weight = index
                                }
                        }
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(16)
                
                // 關聯任務
                VStack(alignment: .leading, spacing: 16) {
                    Text("關聯任務")
                        .font(.headline)
                    
                    HStack {
                        TextField("新增任務", text: $taskName)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color(UIColor.systemGray6))
                            .cornerRadius(8)
                        
                        Button(action: {
                            showingTaskView = true
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(.blue)
                        }
                        .padding(.leading, 8)
                    }
                    
                    ForEach(tasks) { task in
                        TaskRow(task: task, onDelete: { deleteTask(task) })
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(16)
                
                Button(action: {
                    saveSubGoal()
                }) {
                    Text("建立子目標")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            }
            .padding()
        }
        .navigationTitle("新增子目標")
        .background(Color(UIColor.systemGray6))
        .sheet(isPresented: $showingTaskView) {
            AddTaskView(subGoalId: UUID()) { task in
                tasks.append(task)
                showingTaskView = false
            }
        }
    }
    
    private func saveSubGoal() {
        let newSubGoal = SubGoal(
            name: subGoalName,
            weight: weight,
            tasks: tasks,
            targetId: targetId
        )
        viewModel.addSubGoal(newSubGoal, to: viewModel.targets.first(where: { $0.id == targetId })!)
        dismiss()
    }
    
    private func deleteTask(_ task: Task) {
        tasks.removeAll { $0.id == task.id }
    }
}

struct TaskRow: View {
    let task: Task
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            Text(task.name)
            Spacer()
            Button(action: onDelete) {
                Image(systemName: "trash.circle.fill")
                    .foregroundColor(.red)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color(UIColor.systemGray6))
        .cornerRadius(8)
    }
}


