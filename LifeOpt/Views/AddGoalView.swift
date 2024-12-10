import SwiftUI

struct AddGoalView: View {
    @Environment(\.dismiss) var dismiss //跳出視窗用的
    @ObservedObject var viewModel: GoalVM
    @State private var goalName: String = ""
    @State private var goalContent: String = ""
    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var subGoalName: String = ""
    @State private var subGoals: [SubGoal] = []
    @State private var color: Color = .blue
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("目標名稱")
                        .font(.headline)
                    TextField("", text: $goalName)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(8)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(16)
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("目標內容")
                        .font(.headline)
                    TextField("寫下你想達成的目標吧！", text: $goalContent)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(8)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(16)
                
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
                    HStack{
                        Text("選擇任務顏色")
                            .font(.headline)
                        ColorPicker("", selection: $color)
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(16)
                
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
                                subGoals.append(SubGoal(name: subGoalName))
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
                                    
                                    Button(action: {
                                        subGoals[index].isEditing.toggle()
                                    }) {
                                        Image(systemName: "pencil.circle.fill")
                                            .foregroundColor(.gray)
                                    }
                                    Button(action: {
                                        print("編輯weight")
                                    }) {
                                        Image(systemName: "star.circle.fill")
                                            .foregroundColor(.gray)
                                    }
                                    Picker(selection: /*@START_MENU_TOKEN@*/.constant(1)/*@END_MENU_TOKEN@*/, label: Text("Picker")) {
                                        Image(systemName: "star.fill").tag(1)
                                        
                                        HStack{
                                            Image(systemName: "star.fill")
                                            Image(systemName: "star.fill")
                                        }.tag(2)
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
                
                Button(action: {
                    addGoal()
                    print("新增目標：\(goalName), 子目標：\(subGoals)")
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
    private func addGoal(){
        let newGoal = Goal(title: goalName, description: goalContent, progress: 0.66, color: color, startDate: startDate, dueDate: endDate)
        viewModel.addGoal(newGoal)
        dismiss()
    }
}


