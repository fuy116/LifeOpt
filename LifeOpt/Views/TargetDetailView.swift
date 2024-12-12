import SwiftUI

struct TargetDetailView: View {
    @ObservedObject var viewModel: GoalVM
    let target: Target
    @State var progress: CGFloat = 0
    @State var displayedProgress: CGFloat = 0
    
    var body: some View {
        ScrollView {
            VStack(spacing: 15) {
                // 整體進度卡片
                VStack(spacing: 0) {
                    HalfCircleProgressView(
                        progress: CGFloat(target.totalProgress),
                        totalSteps: 100,
                        minValue: 0,
                        maxValue: 100
                    )
                    
                    .padding(.bottom, -60)
                    .padding(.top,10)
                    
                  
                    HStack {
                        DateInfoView(title: "開始時間", date: target.startDate)
                        Spacer()
                        DateInfoView(title: "預計完成", date: target.endDate)
                    }
                    
                }
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("目標描述")
                        .font(.headline)
                    Text(target.description)
                        .foregroundColor(.secondary)
                        .font(.subheadline)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white)
                .cornerRadius(10)
                
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("子目標")
                            .font(.headline)
                        Spacer()
                        NavigationLink(destination: AddSubGoalView(viewModel: viewModel, targetId: target.id)) {
                            Image(systemName: "plus.app")
                                .foregroundColor(.blue)
                        }
                    }
                    
                    ForEach(target.subGoals) { subGoal in
                        SubGoalRow(viewModel: viewModel, subGoal: subGoal, color: Color(hex: target.color), targetColor: target.color)
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(10)
            }
            .padding()
        }
        .navigationTitle(target.name)
        .background(Color(UIColor.systemGray6))
    }
}

struct DateInfoView: View {
    let title: String
    let date: Date
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text(date.formatted(date: .abbreviated, time: .omitted))
                .font(.subheadline)
        }
    }
}

struct SubGoalRow: View {
    @ObservedObject var viewModel: GoalVM
    let subGoal: SubGoal
    let color: Color
    let targetColor: String
    
    var body: some View {
        NavigationLink(destination: SubGoalDetailView(
            viewModel: viewModel,
            subGoal: subGoal,
            targetColor: targetColor
        )) {
            VStack(alignment: .leading, spacing: 8) {
                Text(subGoal.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                ProgressView(value: subGoal.progress,total: 100)
                    .progressViewStyle(LinearProgressViewStyle(tint: color))
                
                HStack {
                    Text("\(Int(subGoal.progress))%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    
                    // 顯示權重星星
                    HStack(spacing: 2) {
                        ForEach(0..<subGoal.weight, id: \.self) { _ in
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                                .font(.caption)
                        }
                    }
                }
            }
            .padding()
            .background(Color(UIColor.systemGray6))
            .cornerRadius(8)
        }
    }
}

// 為了預覽功能
#Preview {
    NavigationView {
        TargetDetailView(
            viewModel: GoalVM(),
            target: Target(
                name: "提升職場競爭力",
                description: "透過持續學習和實踐來提升工作技能，包含技術能力提升、溝通能力加強、以及專案管理經驗累積",
                subGoals: [
                    SubGoal(
                        name: "學習 SwiftUI 開發",
                        weight: 3,
                        tasks: [],
                        targetId: UUID()
                    ),
                    SubGoal(
                        name: "完成個人作品集",
                        weight: 3,
                        tasks: [],
                        targetId: UUID()
                    ),
                    SubGoal(
                        name: "參加技術研討會",
                        weight: 2,
                        tasks: [],
                        targetId: UUID()
                    )
                ],
                color: "#007AFF"
            )
        )
    }
}
