import SwiftUI

struct AddTargetView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: GoalVM
    @State private var targetName: String = ""
    @State private var targetDescription: String = ""
    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var subGoalName: String = ""
    @State private var subGoals: [SubGoal] = []
    @State private var color: Color = .blue
    @State private var selectedWeight: Int = 1
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // 目標名稱
                VStack(alignment: .leading, spacing: 16) {
                    Text("目標名稱")
                        .font(.headline)
                    TextField("", text: $targetName)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(8)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(16)
                
                // 目標內容
                VStack(alignment: .leading, spacing: 16) {
                    Text("目標內容")
                        .font(.headline)
                    TextField("寫下你想達成的目標吧！", text: $targetDescription)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(8)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(16)
                
                // 日期和顏色選擇
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("開始日期")
                            .font(.headline)
                        Spacer()
                        DatePicker("", selection: $startDate, displayedComponents: .date)
                            .labelsHidden()
                            .environment(\.locale, Locale(identifier: "zh_TW"))
                    }
                    
                    HStack {
                        Text("結束日期")
                            .font(.headline)
                        Spacer()
                        DatePicker("", selection: $endDate, displayedComponents: .date)
                            .labelsHidden()
                            .environment(\.locale, Locale(identifier: "zh_TW"))
                    }
                    
                    HStack {
                        Text("選擇目標顏色")
                            .font(.headline)
                        ColorPicker("", selection: $color)
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(16)
                
                // 子目標
                VStack(alignment: .leading, spacing: 16) {
                    Text("子目標")
                        .font(.headline)
                    
                    HStack {
                        TextField("新增子目標", text: $subGoalName)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color(UIColor.systemGray6))
                            .cornerRadius(8)
                        
                        Button(action: {
                            if !subGoalName.isEmpty {
                                // 創建新的子目標，targetId 會在保存主目標時設置
                                let subGoal = SubGoal(
                                    name: subGoalName,
                                    weight: selectedWeight,
                                    tasks: [],
                                    targetId: UUID() // 臨時 ID，會在保存時更新
                                )
                                subGoals.append(subGoal)
                                subGoalName = ""
                            }
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(.blue)
                        }
                        .padding(.leading, 8)
                    }
                    
                    if !subGoals.isEmpty {
                        VStack(spacing: 12) {
                            ForEach(subGoals.indices, id: \.self) { index in
                                HStack {
                                    Text(subGoals[index].name)
                                    Spacer()
                                    
                                    // 權重選擇器
                                    Picker("權重", selection: Binding(
                                        get: { subGoals[index].weight },
                                        set: { newWeight in
                                            subGoals[index] = SubGoal(
                                                id: subGoals[index].id,
                                                name: subGoals[index].name,
                                                weight: newWeight,
                                                tasks: subGoals[index].tasks,
                                                targetId: subGoals[index].targetId
                                            )
                                        }
                                    )) {
                                        ForEach(1...5, id: \.self) { weight in
                                            HStack {
                                                ForEach(0..<weight, id: \.self) { _ in
                                                    Image(systemName: "star.fill")
                                                }
                                            }.tag(weight)
                                        }
                                    }
                                    .frame(width: 120)
                                    
                                    // 刪除按鈕
                                    Button(action: {
                                        subGoals.remove(at: index)
                                    }) {
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
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(16)
                
                Spacer()
                
                // 建立目標按鈕
                Button(action: {
                    addTarget()
                }) {
                    Text("建立目標")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            }
            .padding()
        }
        .navigationTitle("新增目標")
        .background(Color(UIColor.systemGray6))
    }
    
    private func addTarget() {
        let hexColor = color.toHex() ?? "#007AFF" // 需要實現 Color 擴展方法
        let newTarget = Target(
            name: targetName,
            description: targetDescription,
            startDate: startDate,
            endDate: endDate,
            subGoals: subGoals,
            color: hexColor
        )
        viewModel.addTarget(newTarget)
        dismiss()
    }
}

// Color 擴展，用於轉換顏色為十六進制字串
extension Color {
    func toHex() -> String? {
        guard let components = UIColor(self).cgColor.components else { return nil }
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        return String(format: "#%02lX%02lX%02lX",
                     lroundf(r * 255),
                     lroundf(g * 255),
                     lroundf(b * 255))
    }
}
