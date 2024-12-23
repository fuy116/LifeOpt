import SwiftUI

struct TimeTrackerView: View {
    @State private var selectedTab: String = "天" // 預設選中 "天"
    @State private var selectedType: String = "長條圖" // 預設選中 "長條圖"
    @State private var selectedDate: Date = Date() // 選中的日期
    @State private var showDatePicker: Bool = false // 控制日曆的 Sheet 彈出

    var body: some View
    {
        VStack {
            // 按鈕切換區
            buttonGroup(options: ["天", "週", "月"], selected: $selectedTab)
            
            buttonGroup(options: ["長條圖", "圓餅圖"], selected: $selectedType)
            
            // 日期調整與選擇按鈕
            dateSelectionView()
            datapresent()
            Spacer()
        }
        .frame(maxHeight: .infinity, alignment: .top) // 確保整體視圖對齊頂部
        .background(Color.white.edgesIgnoringSafeArea(.all)) // 整體背景顏色
            // 顯示選擇的日期
        
    }
    private func datapresent() -> some View
    {
        return(
            ZStack {
            Color.gray.opacity(0.2) // 背景色
                .cornerRadius(12)

            Text("選中的日期: \(formattedDate())")
                .font(.title2)
                .padding()
        }
        .frame(width: 400, height: 500)
        .shadow(radius: 5)
        )
        
    }
   
    // 提取出來的日期選擇和顯示視圖
    private func dateSelectionView() -> some View {
        // 這裡用一個 `Group` 包裹多個視圖，以便在不同條件下返回不同的內容
        Group {
            if selectedTab == "天" {
                // 顯示 "天" 相關的按鈕
                AnyView(
                    HStack {
                        Button(action: {
                            adjustDate(by: -1)
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.title)
                                .padding()
                                .background(Color.blue.opacity(0.7))
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }

                        Button(action: {
                            showDatePicker = true
                        }) {
                            HStack {
                                Image(systemName: "calendar")
                                Text("選擇日期")
                                    .fontWeight(.bold)
                            }
                            .padding()
                            .background(Color.blue.opacity(0.7))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        .sheet(isPresented: $showDatePicker) {
                            VStack {
                                DatePicker(
                                    "選擇日期",
                                    selection: $selectedDate,
                                    displayedComponents: [.date]
                                )
                                .datePickerStyle(GraphicalDatePickerStyle())
                                .padding()

                                Button("完成") {
                                    showDatePicker = false
                                }
                                .padding()
                                .background(Color.blue.opacity(0.7))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }
                            .padding()
                        }

                        Button(action: {
                            adjustDate(by: 1)
                        }) {
                            Image(systemName: "chevron.right")
                                .font(.title)
                                .padding()
                                .background(Color.blue.opacity(0.7))
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                    .padding(.all, 10)
                )
            } else if selectedTab == "週" {
                // 顯示 "週" 相關的按鈕
                AnyView(
                    HStack {
                        Button(action: {
                            adjustDate(by: -1)
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.title)
                                .padding()
                                .background(Color.blue.opacity(0.7))
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        
                        Button(action: {
                            adjustDate(by: 1)
                        }) {
                            Image(systemName: "chevron.right")
                                .font(.title)
                                .padding()
                                .background(Color.blue.opacity(0.7))
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                    .padding(.all, 10)
                )
            } else if selectedTab == "月" {
                // 顯示 "週" 相關的按鈕
                AnyView(
                    HStack {
                        Button(action: {
                            adjustDate(by: -1)
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.title)
                                .padding()
                                .background(Color.blue.opacity(0.7))
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        
                        Button(action: {
                            adjustDate(by: 1)
                        }) {
                            Image(systemName: "chevron.right")
                                .font(.title)
                                .padding()
                                .background(Color.blue.opacity(0.7))
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                    .padding(.all, 10)
                )
            }else {
                // 如果不是 "天" 或 "週"，返回空視圖
                AnyView(EmptyView())
            }
        }
    }

    private func buttonGroup(options: [String], selected: Binding<String>) -> some View {
        HStack(spacing: 20) {
            ForEach(options, id: \.self) { option in
                Button(action: {
                    selected.wrappedValue = option
                }) {
                    Text(option)
                        .fontWeight(.bold)
                        .padding(12)
                        .frame(maxWidth: .infinity)
                        .background(selected.wrappedValue == option ? Color.blue : Color.clear)
                        .foregroundColor(selected.wrappedValue == option ? .white : .gray)
                        .cornerRadius(10)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color(UIColor.systemGray6))
        .cornerRadius(12)
    }

    private func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: selectedDate)
    }

    private func adjustDate(by days: Int) {
        if let newDate = Calendar.current.date(byAdding: .day, value: days, to: selectedDate) {
            selectedDate = newDate
        }
    }
}

#Preview {
    TimeTrackerView()
}
