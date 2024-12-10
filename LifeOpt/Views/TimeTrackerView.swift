import SwiftUI

struct TimeTrackerView: View {
    @State private var selectedTab: String = "天" // 預設選中 "天"
    @State private var selected_type: String = "長條圖" // 預設選中 "天"

    var body: some View {
        VStack {
            // 開始計時按鈕
            Button("開始計時") {
                print("被點擊")
            }
            .frame(width: 300, height: 60) // 調整按鈕高度，減少佔用空間
            .foregroundColor(.white)
            .background(Color.blue)
            .cornerRadius(12)
            .padding(.vertical, 20) // 與頂部保留適當空間

            // 按鈕切換區
            HStack(spacing: 20) { // 控制按鈕間距
                Button(action: {
                    selectedTab = "天"
                }) {
                    Text("天")
                        .fontWeight(.bold)
                        .padding(12)
                        .frame(maxWidth: .infinity)
                        .background(selectedTab == "天" ? Color.blue : Color.clear)
                        .foregroundColor(selectedTab == "天" ? .white : .gray)
                        .cornerRadius(10)
                }

                Button(action: {
                    selectedTab = "週"
                }) {
                    Text("週")
                        .fontWeight(.bold)
                        .padding(12)
                        .frame(maxWidth: .infinity)
                        .background(selectedTab == "週" ? Color.blue : Color.clear)
                        .foregroundColor(selectedTab == "週" ? .white : .gray)
                        .cornerRadius(10)
                }
                Button(action: {
                    selectedTab = "月"
                }) {
                    Text("月")
                        .fontWeight(.bold)
                        .padding(12)
                        .frame(maxWidth: .infinity)
                        .background(selectedTab == "月" ? Color.blue : Color.clear)
                        .foregroundColor(selectedTab == "月" ? .white : .gray)
                        .cornerRadius(10)
                }

            }
            .padding(.horizontal, 16) // 增加按鈕區域的左右內邊距
            .padding(.vertical, 10) // 與按鈕保持距離
            .background(Color(UIColor.systemGray6))
            .cornerRadius(12)
            HStack(spacing: 20)
            {
                Button(action: {
                    selected_type = "長條圖"
                }) {
                    Text("長條圖")
                        .fontWeight(.bold)
                        .padding(12)
                        .frame(maxWidth: .infinity)
                        .background(selected_type == "長條圖" ? Color.blue : Color.clear)
                        .foregroundColor(selected_type == "長條圖" ? .white : .gray)
                        .cornerRadius(10)
                }
                Button(action: {
                    selected_type = "圓餅圖"
                }) {
                    Text("圓餅圖")
                        .fontWeight(.bold)
                        .padding(12)
                        .frame(maxWidth: .infinity)
                        .background(selected_type == "圓餅圖" ? Color.blue : Color.clear)
                        .foregroundColor(selected_type == "圓餅圖" ? .white : .gray)
                        .cornerRadius(10)
                }
            }
            .padding(.horizontal, 16) // 增加按鈕區域的左右內邊距
            .padding(.vertical, 10) // 與按鈕保持距離
            .background(Color(UIColor.systemGray6))
            .cornerRadius(12)

            // 內容顯示區
            Spacer() // 將內容與按鈕分隔
            if selectedTab == "天"
            {
                if selected_type == "長條圖"
                {
                    Text("今天長條圖的數據")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                }
                else
                {
                    Text("今天圓餅圖的數據")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                }
                
            } else if selectedTab == "週" {
                if selected_type == "長條圖"
                {
                    Text("這週長條圖的數據")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                }
                else
                {
                    Text("這週圓餅圖的數據")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                }

            }
            else if selectedTab == "月" {
                if selected_type == "長條圖"
                {
                    Text("今月長條圖的數據")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                }
                else
                {
                    Text("今月圓餅圖的數據")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                }
            }

            Spacer()
        }
        .frame(maxHeight: .infinity, alignment: .top) // 確保整體視圖對齊頂部
        .background(Color.white.edgesIgnoringSafeArea(.all)) // 整體背景顏色
    }
}

#Preview {
    TimeTrackerView()
}
