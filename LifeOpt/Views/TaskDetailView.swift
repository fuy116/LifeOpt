import SwiftUI

struct TaskDetailView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: GoalVM
    let task: Task
    let subGoalId: UUID
    
    @State private var currentValue: Double
    @State private var isEditing = false
    @State private var weight: Int // 新增權重狀態
    
    init(viewModel: GoalVM, task: Task, subGoalId: UUID) {
        self.viewModel = viewModel
        self.task = task
        self.subGoalId = subGoalId
        _currentValue = State(initialValue: task.currentValue)
        _weight = State(initialValue: task.weight) // 初始化權重
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("任務進度")) {
                    if task.progressType == .value {
                        VStack(alignment: .leading) {
                            Text("當前進度: \(Int(currentValue))/\(Int(task.targetValue))")
                            Slider(value: $currentValue,
                                   in: 0...task.targetValue,
                                   step: 1)
                        }
                    } else {
                        VStack(alignment: .leading) {
                            Text("完成度: \(Int(currentValue))%")
                            Slider(value: $currentValue,
                                   in: 0...100,
                                   step: 1)
                        }
                    }
                }
                
                Section(header: Text("任務權重")) {
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
                
                Section(header: Text("任務資訊")) {
                    Text("開始日期: \(task.startDate.formatted())")
                    Text("結束日期: \(task.endDate.formatted())")
                    Text("任務類型: \(task.taskType.rawValue.capitalized)")
                    Text("描述: \(task.description)")
                }
            }
            .navigationTitle(task.name)
            .navigationBarItems(
                leading: Button("取消") { dismiss() },
                trailing: HStack {
                    Button("編輯") {
                        isEditing = true
                    }
                    Button("保存") {
                        saveChanges()
                    }
                }
            )
        }
        .sheet(isPresented: $isEditing) {
            EditTaskView(viewModel: viewModel, task: task, subGoalId: subGoalId)
        }
    }
    
    private func saveChanges() {
        var updatedTask = task
        updatedTask.currentValue = currentValue
        updatedTask.weight = weight // 保存權重
        
        if let subGoal = viewModel.targets
            .flatMap({ $0.subGoals })
            .first(where: { $0.id == subGoalId }),
           let target = viewModel.targets
            .first(where: { $0.subGoals.contains(where: { $0.id == subGoalId }) }) {
            viewModel.updateTask(updatedTask, in: subGoal, in: target)
        }
        dismiss()
    }
}

struct EditTaskView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: GoalVM
    let task: Task
    let subGoalId: UUID
    
    @State private var name: String
    @State private var description: String
    @State private var startDate: Date
    @State private var endDate: Date
    @State private var taskType: TaskType
    @State private var weight: Int
    @State private var targetValue: Double // 新增目標值
    @State private var progressType: ProgressType // 新增進度類型
    
    init(viewModel: GoalVM, task: Task, subGoalId: UUID) {
        self.viewModel = viewModel
        self.task = task
        self.subGoalId = subGoalId
        _name = State(initialValue: task.name)
        _description = State(initialValue: task.description)
        _startDate = State(initialValue: task.startDate)
        _endDate = State(initialValue: task.endDate)
        _taskType = State(initialValue: task.taskType)
        _weight = State(initialValue: task.weight)
        _targetValue = State(initialValue: task.targetValue)
        _progressType = State(initialValue: task.progressType)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("基本資訊")) {
                    TextField("任務名稱", text: $name)
                    TextField("任務描述", text: $description)
                }
                
                Section(header: Text("時間設定")) {
                    DatePicker("開始日期", selection: $startDate, displayedComponents: .date)
                    DatePicker("結束日期", selection: $endDate, displayedComponents: .date)
                }
                
                Section(header: Text("任務設定")) {
                    Picker("任務類型", selection: $taskType) {
                        Text("每日").tag(TaskType.daily)
                        Text("每週").tag(TaskType.weekly)
                        Text("每月").tag(TaskType.monthly)
                        Text("自定義").tag(TaskType.custom)
                    }
                    
                    Picker("進度類型", selection: $progressType) {
                        Text("百分比").tag(ProgressType.percentage)
                        Text("數值").tag(ProgressType.value)
                    }
                    
                    if progressType == .value {
                        TextField("目標值", value: $targetValue, format: .number)
                            .keyboardType(.decimalPad)
                    }
                }
                
                Section(header: Text("任務權重")) {
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
            }
            .navigationTitle("編輯任務")
            .navigationBarItems(
                leading: Button("取消") { dismiss() },
                trailing: Button("保存") { saveChanges() }
            )
        }
    }
    
    private func saveChanges() {
        var updatedTask = task
        updatedTask.name = name
        updatedTask.description = description
        updatedTask.startDate = startDate
        updatedTask.endDate = endDate
        updatedTask.taskType = taskType
        updatedTask.weight = weight
        updatedTask.progressType = progressType
        updatedTask.targetValue = targetValue
        
        if let subGoal = viewModel.targets
            .flatMap({ $0.subGoals })
            .first(where: { $0.id == subGoalId }),
           let target = viewModel.targets
            .first(where: { $0.subGoals.contains(where: { $0.id == subGoalId }) }) {
            viewModel.updateTask(updatedTask, in: subGoal, in: target)
        }
        dismiss()
    }
}
