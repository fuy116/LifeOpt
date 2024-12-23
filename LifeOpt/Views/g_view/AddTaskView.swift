import SwiftUI

struct AddTaskView: View {
    @Environment(\.dismiss) var dismiss
    let subGoalId: UUID
    let onSave: (Task) -> Void
    
    @State private var taskName: String = ""
    @State private var taskDescription: String = ""
    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var taskType: TaskType = .daily
    @State private var progressType: ProgressType = .percentage
    @State private var targetValue: Double = 100
    @State private var weight: Int = 1
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // 任務名稱
                    VStack(alignment: .leading, spacing: 16) {
                        Text("任務名稱")
                            .font(.headline)
                        TextField("", text: $taskName)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color(UIColor.systemGray6))
                            .cornerRadius(8)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(16)
                    
                    // 任務說明
                    VStack(alignment: .leading, spacing: 16) {
                        Text("任務說明")
                            .font(.headline)
                        TextField("描述你的任務", text: $taskDescription)
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
                    // 日期設置
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("開始日期")
                                .font(.headline)
                            Spacer()
                            DatePicker("", selection: $startDate, displayedComponents: .date)
                                .labelsHidden()
                        }
                        
                        HStack {
                            Text("結束日期")
                                .font(.headline)
                            Spacer()
                            DatePicker("", selection: $endDate, displayedComponents: .date)
                                .labelsHidden()
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(16)
                    
                    // 任務類型
                    VStack(alignment: .leading, spacing: 16) {
                        Text("任務類型")
                            .font(.headline)
                        Picker("任務類型", selection: $taskType) {
                            Text("每日").tag(TaskType.daily)
                            Text("每週").tag(TaskType.weekly)
                            Text("每月").tag(TaskType.monthly)
                            Text("自定義").tag(TaskType.custom)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(16)
                    
                    // 進度類型
                    VStack(alignment: .leading, spacing: 16) {
                        Text("進度類型")
                            .font(.headline)
                        Picker("進度類型", selection: $progressType) {
                            Text("百分比").tag(ProgressType.percentage)
                            Text("數值").tag(ProgressType.value)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        
                        if progressType == .value {
                            Text("目標值")
                                .font(.headline)
                            TextField("設定目標值", value: $targetValue, format: .number)
                                .keyboardType(.decimalPad)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color(UIColor.systemGray6))
                                .cornerRadius(8)
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(16)
                }
                .padding()
            }
            .navigationTitle("新增任務")
            .navigationBarItems(
                leading: Button("取消") { dismiss() },
                trailing: Button("保存") { saveTask() }
            )
            .background(Color(UIColor.systemGray6))
        }
    }
    
    private func saveTask() {
        let newTask = Task(
            name: taskName,
            description: taskDescription,
            startDate: startDate,
            endDate: endDate,
            taskType: taskType,
            progressType: progressType,
            currentValue: 0,
            targetValue: targetValue,
            weight: weight,
            subGoalId: subGoalId
        )
        onSave(newTask)
        //dismiss()
    }
}
