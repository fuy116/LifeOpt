import SwiftUI

struct TimerView: View {
    @State private var timerValue: Int = 0 // 計時器的數值（以秒為單位）
    @State private var timerIsRunning: Bool = false // 記錄計時器是否正在運行
    @State private var timer: Timer? = nil // 計時器的實例
    @State private var selectedTask: String = "任務 1" // 當前選擇的任務
    @State private var tasks: [String] = ["任務 1", "任務 2", "任務 3"] // 可選任務列表

    var body: some View {
        VStack(spacing: 20) {
            // 任務選擇器
            Picker("選擇任務", selection: $selectedTask) {
                ForEach(tasks, id: \.self) { task in
                    Text(task).tag(task)
                }
            }
            .pickerStyle(MenuPickerStyle()) // 使用菜單樣式
            .padding()
            .background(Color(UIColor.systemGray5))
            .cornerRadius(10)

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
