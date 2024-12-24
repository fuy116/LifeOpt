import SwiftUI

struct HomePageView: View {
    @StateObject private var viewModel = GoalVM()
    @State private var isAddingNewItem = false
    
    private var overviewItems: [OverviewItem] {
        [
            OverviewItem(icon: "clock", title: "專注時間", value: "3h 20m", color: .green),
            OverviewItem(icon: "chart.bar", title: "完成任務",
                        value: "\(getTodayCompletedTasksCount())/\(getTodayTasks().count)",
                        color: .blue)
        ]
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    HStack {
                        Text("您好，User")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        Spacer()
                    }
                    todayOverview()
                    progressView()
                    weeklyView()
                }
                .padding()
            }
            .background(Color(UIColor.systemGray6))
        }
    }
    
    // Overview Card
    private func overviewCard(item: OverviewItem) -> some View {
        HStack(spacing: 12) {
            Image(systemName: item.icon)
                .font(.title2)
                .foregroundColor(item.color)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(item.value)
                    .font(.title3)
                    .fontWeight(.semibold)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(UIColor.systemGray6))
        .cornerRadius(10)
    }
    
    // Today Overview
    private func todayOverview() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("今日概覽")
                    .font(.headline)
                Spacer()
                
                Button {
                    print("open calender")
                } label: {
                    Image(systemName: "calendar")
                }
            }
            
            HStack(spacing: 12) {
                overviewCard(item: overviewItems[0])
                overviewCard(item: overviewItems[1])
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
    }
    
    // Progress Card
    private func progressCard(item: Target) -> some View {
        NavigationLink(destination: TargetDetailView(viewModel: viewModel, target: item)) {
            VStack(alignment: .leading, spacing: 8) {
                Text(item.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                HStack {
                    Text("\(Int(item.totalProgress))%")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color(hex: item.color))
                    
                    Spacer()
                }
                
                ProgressView(value: item.totalProgress, total: 100)
                    .progressViewStyle(LinearProgressViewStyle(tint: Color(hex: item.color)))
            }
            .padding()
            .background(Color(hex: item.color).opacity(0.1))
            .cornerRadius(10)
        }
    }
    
    // Progress View
    private func progressView() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("進度概覽")
                    .font(.headline)
                Spacer()
                NavigationLink(destination: AddTargetView(viewModel: viewModel)) {
                    Image(systemName: "plus.app")
                }
            }
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(viewModel.targets) { target in
                    progressCard(item: target)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
    }
    
    // Get Today's Tasks
    private func getTodayTasks() -> [Task] {
        let calendar = Calendar.current
        let today = Date()
        
        return viewModel.targets.flatMap { target in
            target.subGoals.flatMap { subGoal in
                subGoal.tasks.filter { task in
                    let isInDateRange = task.startDate <= today && today <= task.endDate
                    
                    switch task.taskType {
                    case .daily:
                        return isInDateRange
                    case .weekly:
                        return calendar.isDate(task.startDate, equalTo: today, toGranularity: .weekOfYear)
                    case .monthly:
                        return calendar.isDate(task.startDate, equalTo: today, toGranularity: .month)
                    case .custom:
                        return isInDateRange
                    }
                }
            }
        }
    }
    
    struct TaskRow: View {
        let task: Task
        let viewModel: GoalVM
        @State private var isCompleted: Bool
        
        init(task: Task, viewModel: GoalVM) {
            self.task = task
            self.viewModel = viewModel
            self._isCompleted = State(initialValue: task.progressPercentage >= 100)
        }
        
        var body: some View {
            HStack {
                Button(action: {
                    isCompleted.toggle()
                    if task.taskType == .daily {
                        viewModel.updateTaskProgress(task, isCompleted: isCompleted)
                    }
                }) {
                    Circle()
                        .stroke(lineWidth: 2)
                        .fill(isCompleted ? Color.green : Color.gray)
                        .frame(width: 20, height: 20)
                        .overlay(
                            isCompleted ?
                            Image(systemName: "checkmark")
                                .foregroundColor(.green)
                                .font(.system(size: 12, weight: .bold))
                            : nil
                        )
                }
                
                Text(task.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .padding(.leading, 8)
                
                Spacer()
                
                if task.taskType != .daily {
                    Text(task.taskType.rawValue)
                        .font(.caption2)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(4)
                }
            }
            .padding(.vertical, 8)
        }
    }
    // Get Completed Tasks Count
    private func getTodayCompletedTasksCount() -> Int {
        return getTodayTasks().filter { $0.progressPercentage >= 100 }.count
    }
    
    // Weekly View
    private func weeklyView() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("本日任務")
                    .font(.headline)
                Spacer()
            }
            
            let todayTasks = getTodayTasks()
            
            if todayTasks.isEmpty {
                Text("今天沒有待辦任務")
                    .foregroundColor(.secondary)
                    .padding(.vertical)
            } else {
                ForEach(todayTasks) { task in
                    TaskRow(task: task, viewModel: viewModel)
                }
                }
            
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
    }
}



// Color Extension
extension Color {
    init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let r = Double((rgb & 0xFF0000) >> 16) / 255.0
        let g = Double((rgb & 0x00FF00) >> 8) / 255.0
        let b = Double(rgb & 0x0000FF) / 255.0
        
        self.init(red: r, green: g, blue: b)
    }
}

#Preview {
    HomePageView()
}
