import SwiftUI

struct TaskDetailView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: GoalVM
    let task: Task
    let subGoalId: UUID
    
    @State private var selectedDate: Date = Date()
    @State private var isEditing = false
    @State private var weight: Int
    @State private var customProgress: Double
    
    init(viewModel: GoalVM, task: Task, subGoalId: UUID) {
        self.viewModel = viewModel
        self.task = task
        self.subGoalId = subGoalId
        _weight = State(initialValue: task.weight)
        _customProgress = State(initialValue: Double(task.completedDates.count))
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("任務進度")) {
                    if task.taskType == .custom {
                        if task.progressType == .value {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("當前進度: \(Int(customProgress))/\(Int(task.targetValue))")
                                
                                HStack {
                                    Button {
                                        if customProgress > 0 {
                                            customProgress -= 1
                                        }
                                    } label: {
                                        Image(systemName: "minus.circle.fill")
                                            .foregroundColor(.blue)
                                            .font(.title2)
                                    }
                                    .buttonStyle(BorderlessButtonStyle())
                                    
                                    Spacer()
                                    
                                    TextField("進度", value: $customProgress, format: .number)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .frame(width: 80)
                                        .multilineTextAlignment(.center)
                                        .keyboardType(.numberPad)
                                        .onSubmit {  // 改用 onSubmit
                                            updateCustomProgress()
                                        }
                                    
                                    Spacer()
                                    
                                    Button {
                                        if customProgress < task.targetValue {
                                            customProgress += 1
                                        }
                                    } label: {
                                        Image(systemName: "plus.circle.fill")
                                            .foregroundColor(.blue)
                                            .font(.title2)
                                    }
                                    .buttonStyle(BorderlessButtonStyle())
                                }
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(10)
                                
                                // 新增確認按鈕
                                Button(action: updateCustomProgress) {
                                    Text("更新進度")
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 8)
                                }
                                .buttonStyle(.borderedProminent)
                                .padding(.top, 8)
                            }
                        } else {
                            // percentage 類型的部分也做相同修改
                            VStack(alignment: .leading, spacing: 10) {
                                Text("完成度: \(Int(customProgress))%")
                                
                                HStack {
                                    Button {
                                        if customProgress > 0 {
                                            customProgress -= 1
                                        }
                                    } label: {
                                        Image(systemName: "minus.circle.fill")
                                            .foregroundColor(.blue)
                                            .font(.title2)
                                    }
                                    .buttonStyle(BorderlessButtonStyle())
                                    
                                    Spacer()
                                    
                                    TextField("進度", value: $customProgress, format: .number)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .frame(width: 80)
                                        .multilineTextAlignment(.center)
                                        .keyboardType(.numberPad)
                                        .onSubmit {
                                            updateCustomProgress()
                                        }
                                    
                                    Spacer()
                                    
                                    Button {
                                        if customProgress < 100 {
                                            customProgress += 1
                                        }
                                    } label: {
                                        Image(systemName: "plus.circle.fill")
                                            .foregroundColor(.blue)
                                            .font(.title2)
                                    }
                                    .buttonStyle(BorderlessButtonStyle())
                                }
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(10)
                                
                                // 新增確認按鈕
                                Button(action: updateCustomProgress) {
                                    Text("更新進度")
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 8)
                                }
                                .buttonStyle(.borderedProminent)
                                .padding(.top, 8)
                            }
                        }
                    } else {
                        VStack(alignment: .leading, spacing: 10) {
                            if task.progressType == .value {
                                Text("當前進度: \(Int(task.currentValue))/\(Int(task.targetValue))")
                            } else {
                                Text("完成度: \(Int(task.progressPercentage))%")
                            }
                            
                            DatePicker("選擇日期", selection: $selectedDate, displayedComponents: .date)
                                .datePickerStyle(.compact)
                                .labelsHidden()
                            
                            Button(action: toggleDateCompletion) {
                                HStack {
                                    Image(systemName: isDateCompleted(selectedDate) ? "checkmark.circle.fill" : "circle")
                                    Text(isDateCompleted(selectedDate) ? "取消完成" : "標記完成")
                                }
                                .foregroundColor(isDateCompleted(selectedDate) ? .green : .blue)
                            }
                        }
                    }
                }
                
                Section(header: Text("任務權重")) {
                    HStack {
                        ForEach(1...5, id: \.self) { index in
                            Image(systemName: index <= weight/2 ? "star.fill" : "star")
                                .foregroundColor(index <= weight/2 ? .yellow : .gray)
                                .onTapGesture {
                                    weight = index * 2
                                }
                        }
                    }
                }
                
                Section(header: Text("完成記錄")) {
                    if task.completedDates.isEmpty {
                        Text("尚無完成記錄")
                            .foregroundColor(.gray)
                    } else {
                        ForEach(Array(task.completedDates).sorted(by: >), id: \.self) { date in
                            HStack {
                                Text(date.formatted(date: .abbreviated, time: .omitted))
                                Spacer()
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
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
    
    private func isDateCompleted(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let standardizedDate = calendar.startOfDay(for: date)
        return task.completedDates.contains(standardizedDate)
    }
    
    private func toggleDateCompletion() {
        if let subGoal = viewModel.targets
            .flatMap({ $0.subGoals })
            .first(where: { $0.id == subGoalId }),
           let target = viewModel.targets
            .first(where: { $0.subGoals.contains(where: { $0.id == subGoalId }) }) {
            
            var updatedTask = task
            let calendar = Calendar.current
            let standardizedDate = calendar.startOfDay(for: selectedDate)
            
            if isDateCompleted(standardizedDate) {
                updatedTask.completedDates.remove(standardizedDate)
            } else {
                updatedTask.completedDates.insert(standardizedDate)
            }
            
            viewModel.updateTask(updatedTask, in: subGoal, in: target)
        }
    }
    
    private func updateCustomProgress() {
        if let subGoal = viewModel.targets
            .flatMap({ $0.subGoals })
            .first(where: { $0.id == subGoalId }),
           let target = viewModel.targets
            .first(where: { $0.subGoals.contains(where: { $0.id == subGoalId }) }) {
            
            var updatedTask = task
            let requiredDates = Int(customProgress)
            var newDates: Set<Date> = []
            
            // 生成對應數量的日期記錄
            for i in 0..<requiredDates {
                let date = Calendar.current.date(byAdding: .second, value: i, to: task.startDate) ?? task.startDate
                newDates.insert(date)
            }
            
            updatedTask.completedDates = newDates
            viewModel.updateTask(updatedTask, in: subGoal, in: target)
        }
    }
    
    private func saveChanges() {
        var updatedTask = task
        updatedTask.weight = weight
        
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
    @State private var targetValue: Double
    @State private var progressType: ProgressType
    
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
                            Image(systemName: index <= (weight/2) ? "star.fill" : "star")
                                .foregroundColor(index <= (weight/2) ? .yellow : .gray)
                                .onTapGesture {
                                    weight = index * 2
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

