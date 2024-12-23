import SwiftUI

// 定義 UserTask 結構體
struct UserTask {
    var name: String
    var tag: String
}

struct TimerView: View {
    @State private var timerValue: Int = 0 // 計時器的數值（以秒為單位）
    @State private var timerIsRunning: Bool = false // 記錄計時器是否正在運行
    @State private var timer: Timer? = nil // 計時器的實例
    @State private var selectedTask: String = "任務 1" // 當前選擇的任務
    @State private var selectedTag: String = "標籤 1" // 當前選擇的標籤
    @State private var userTasks: [UserTask] = [UserTask(name: "任務 1", tag: "標籤 1"),
                                                UserTask(name: "任務 2", tag: "標籤 2"),
                                                UserTask(name: "任務 3", tag: "標籤 1")] // 任務資料庫
    @State private var tags: [String] = ["標籤 1", "標籤 2", "標籤 3"] // 標籤資料庫
    @State private var showAddTagField: Bool = false // 控制顯示新增標籤輸入框
    @State private var newTagName: String = "" // 用來保存用戶輸入的新標籤名稱
    @State private var showAddTaskField: Bool = false // 控制顯示新增任務輸入框
    @State private var newTaskName: String = "" // 用來保存用戶輸入的新任務名稱

    var body: some View {
        VStack(spacing: 20) {
            // 新增任務按鈕
            Button(action: {
                showAddTaskField = true
            }) {
                Text("新增任務")
                    .frame(width: 150, height: 50)
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            


            // 顯示任務輸入框讓用戶輸入新的任務名稱
            if showAddTaskField {
                VStack {
                    TextField("請輸入新任務名稱", text: $newTaskName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                        .autocapitalization(.none)
                        .disableAutocorrection(true)

                    // 顯示標籤選擇框
                    Menu {
                        ForEach(tags, id: \.self) { tag in
                            Button(action: {
                                selectedTag = tag
                            }) {
                                Text(tag)
                            }
                        }
                    } label: {}
                       

                    Button(action: addNewTask) {
                        Text("新增")
                            .frame(width: 100, height: 50)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.top, 10)
                    
                    Button(action: {
                        showAddTaskField = false
                        newTaskName = "" // 清空輸入框
                    }) {
                        Text("取消")
                            .frame(width: 100, height: 50)
                            .background(Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.top, 5)
                }
                .padding()
            }

            // 任務選擇器
            Picker("選擇任務", selection: $selectedTask) {
                ForEach(userTasks, id: \.name) { task in
                    Text(task.name).tag(task.name)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .padding()
            .background(Color(UIColor.systemGray5))
            .cornerRadius(10)

            // 標籤選擇器（放在選擇任務的下方）
            Button(action: {
                showAddTagField = true
            }) {
                Text("新增標籤")
                    .frame(width: 150, height: 50)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
           

            // 新增標籤按鈕
            
            // 顯示標籤輸入框讓用戶輸入新的標籤名稱
            if showAddTagField {
                VStack {
                    TextField("請輸入新標籤名稱", text: $newTagName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                        .autocapitalization(.none)
                        .disableAutocorrection(true)

                    Button(action: addNewTag) {
                        Text("新增")
                            .frame(width: 100, height: 50)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.top, 10)
                    
                    Button(action: {
                        showAddTagField = false
                        newTagName = "" // 清空輸入框
                    }) {
                        Text("取消")
                            .frame(width: 100, height: 50)
                            .background(Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.top, 5)
                }
                .padding()
            }
            Menu {
                ForEach(tags, id: \.self) { tag in
                    Button(action: {
                        selectedTag = tag
                    }) {
                        Text(tag)
                    }
                }
            } label: {
                HStack {
                    Text("選擇標籤")
                    Spacer()
                    Text(selectedTag)
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color(UIColor.systemGray5))
                .cornerRadius(10)
            }

            // 顯示計時
            Text(formatTime(seconds: timerValue))
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
            
            // 按鈕區域
            HStack(spacing: 20) {
                // 開始按鈕
                Button(action: startTimer) {
                    Text("開始")
                        .frame(width: 100, height: 50)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(timerIsRunning) // 計時中時禁用按鈕

                // 暫停/繼續按鈕
                Button(action: togglePauseResume) {
                    Text(timerIsRunning ? "暫停" : "繼續")
                        .frame(width: 100, height: 50)
                        .background(timerIsRunning ? Color.yellow : Color.blue)
                        .foregroundColor(timerIsRunning ? .black : .white)
                        .cornerRadius(10)
                }
                .disabled(!timerIsRunning && timerValue == 0) // 計時器尚未啟動時禁用按鈕

                // 結束按鈕
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
        .background(Color(UIColor.systemGray6).edgesIgnoringSafeArea(.all))
    }

    // 添加新標籤
    func addNewTag() {
        if !newTagName.isEmpty {
            tags.append(newTagName)
            selectedTag = newTagName // 設置選擇的標籤為剛剛新增的標籤
            showAddTagField = false // 隱藏輸入框
            newTagName = "" // 清空輸入框
        }
    }

    // 添加新任務
    func addNewTask() {
        if !newTaskName.isEmpty && !selectedTag.isEmpty {
            userTasks.append(UserTask(name: newTaskName, tag: selectedTag))
            selectedTask = newTaskName // 設置選擇的任務
            newTaskName = "" // 清空輸入框
            showAddTaskField = false // 隱藏輸入框
        }
    }

    // 開始計時
    func startTimer() {
        timerIsRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            timerValue += 1
        }
    }

    // 暫停或繼續計時
    func togglePauseResume() {
        if timerIsRunning {
            // 暫停計時
            timerIsRunning = false
            timer?.invalidate()
            timer = nil
        } else {
            // 繼續計時
            startTimer()
        }
    }

    // 重置計時
    func resetTimer() {
        timerIsRunning = false
        timer?.invalidate() // 停止計時器
        timer = nil
        timerValue = 0 // 設定時間歸零
    }

    // 格式化時間（將秒數轉換為 "mm:ss" 格式）
    func formatTime(seconds: Int) -> String {
        let minutes = seconds / 60
        let seconds = seconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview {
    TimerView()
}
