import SwiftUI

struct TimerView: View {
    @ObservedObject var viewModel: GoalVM
    @State private var timerValue: Int = 0
    @State private var timerIsRunning: Bool = false
    @State private var timer: Timer? = nil
    @State private var selectedTarget: Target? = nil
    @State private var selectedTag: TimerTag? = nil
    @State private var showAddTagField: Bool = false
    @State private var newTagName: String = ""
    @State private var tags: [TimerTag] = []
    
    init(viewModel: GoalVM) {
        self.viewModel = viewModel
        if let savedTags = UserDefaults.standard.array(forKey: "tags") as? [[String: Any]] {
            _tags = State(initialValue: savedTags.compactMap { dict -> TimerTag? in
                guard let idString = dict["id"] as? String,
                      let name = dict["name"] as? String,
                      let accumulatedTime = dict["accumulatedTime"] as? TimeInterval else {
                    return nil
                }
                return TimerTag(id: UUID(uuidString: idString) ?? UUID(), name: name, accumulatedTime: accumulatedTime)
            })
            if let firstTag = savedTags.first {
                _selectedTag = State(initialValue: TimerTag(
                    id: UUID(uuidString: firstTag["id"] as? String ?? "") ?? UUID(),
                    name: firstTag["name"] as? String ?? "",
                    accumulatedTime: firstTag["accumulatedTime"] as? TimeInterval ?? 0)
                )
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    VStack(spacing: 20) {
                        Picker("選擇目標", selection: $selectedTarget) {
                            Text("選擇目標")
                                .tag(nil as Target?)
                            ForEach(viewModel.targets, id: \.id) { target in
                                Text(target.name).tag(target as Target?)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .padding()
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(10)
                        
                        Menu {
                            ForEach(tags, id: \.id) { tag in
                                Button(action: { selectedTag = tag }) {
                                    Text(tag.name)
                                }
                            }
                            Button(action: { showAddTagField = true }) {
                                Label("新增標籤", systemImage: "plus")
                            }
                        } label: {
                            HStack {
                                Text("選擇標籤")
                                Spacer()
                                Text(selectedTag?.name ?? "未選擇標籤")
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color(UIColor.systemGray6))
                            .cornerRadius(10)
                        }
                        
                        Divider()
                            .padding(.vertical, 8)
                        
                        Text(formatTime(seconds: timerValue))
                            .font(.system(size: 60, weight: .bold))
                            .padding()
                        
                        HStack(spacing: 20) {
                            Button(action: toggleStartPause) {
                                Text(timerIsRunning ? "暫停" : "開始")
                                    .frame(width: 100, height: 50)
                                    .background(timerIsRunning ? Color.yellow : Color.green)
                                    .foregroundColor(timerIsRunning ? .black : .white)
                                    .cornerRadius(10)
                            }
                            
                            Button(action: resetTimer) {
                                Text("結束")
                                    .frame(width: 100, height: 50)
                                    .background(Color.red)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                }
                .padding()
            }
            .background(Color(UIColor.systemGray6))
            .navigationTitle("計時器")
        }
        .sheet(isPresented: $showAddTagField) {
            VStack {
                Text("新增標籤")
                    .font(.title)
                    .padding()
                
                TextField("請輸入新標籤名稱", text: $newTagName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                
                HStack {
                    Button(action: addNewTag) {
                        Text("新增")
                            .frame(width: 100, height: 50)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    
                    Button(action: {
                        showAddTagField = false
                        newTagName = ""
                    }) {
                        Text("取消")
                            .frame(width: 100, height: 50)
                            .background(Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding()
            }
            .padding()
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
    }
    
    func addNewTag() {
        if !newTagName.isEmpty {
            let newTag = TimerTag(name: newTagName)
            tags.append(newTag)
            selectedTag = newTag
            showAddTagField = false
            newTagName = ""
            let savedTags = tags.map { ["id": $0.id.uuidString, "name": $0.name, "accumulatedTime": $0.accumulatedTime] }
            UserDefaults.standard.set(savedTags, forKey: "tags")
        }
    }
    
    func formatTime(seconds: Int) -> String {
        let minutes = seconds / 60
        let seconds = seconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    func toggleStartPause() {
        if timerIsRunning {
            timer?.invalidate()
            timer = nil
        } else {
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                timerValue += 1
                if var selectedTarget = selectedTarget {
                    selectedTarget.addTime(1)
                    if let index = viewModel.targets.firstIndex(where: { $0.id == selectedTarget.id }) {
                        viewModel.targets[index] = selectedTarget
                    }
                    // 即時保存到 UserDefaults
                    saveTargetsToUserDefaults()
                }

                if var selectedTag = selectedTag {
                    selectedTag.addTime(1)
                    if let index = tags.firstIndex(where: { $0.id == selectedTag.id }) {
                        tags[index] = selectedTag
                        let savedTags = tags.map { ["id": $0.id.uuidString, "name": $0.name, "accumulatedTime": $0.accumulatedTime] }
                        UserDefaults.standard.set(savedTags, forKey: "tags")
                    }
                }
            }
        }
        timerIsRunning.toggle()
    }
  
    func resetTimer() {
        if var selectedTarget = selectedTarget {
            selectedTarget.addTime(TimeInterval(timerValue))
            if let index = viewModel.targets.firstIndex(where: { $0.id == selectedTarget.id }) {
                viewModel.targets[index] = selectedTarget
            }
            saveTargetsToUserDefaults()
        }
        
        timer?.invalidate()
        timer = nil
        timerValue = 0
        timerIsRunning = false
    }
    
    func saveTargetsToUserDefaults() {
        let savedTargets = viewModel.targets.map { target in
            ["id": target.id.uuidString, "name": target.name, "accumulatedTime": target.accumulatedTime]
        }
        UserDefaults.standard.set(savedTargets, forKey: "targets")
    }
}
