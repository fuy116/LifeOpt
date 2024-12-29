import SwiftUI
import Charts

struct TimeTrackerView: View {
    @ObservedObject var viewModel: GoalVM
    @State private var selectedTab: String = "天"
    @State private var selectedType: String = "長條圖"
    @State private var selectedDate: Date = Date()
    @State private var showDatePicker: Bool = false
    @State private var Target: Target? = nil

    var body: some View {
        VStack {
            buttonGroup(options: ["天", "週", "月"], selected: $selectedTab)
            buttonGroup(options: ["長條圖", "圓餅圖"], selected: $selectedType)
            dateSelectionView()
            
            if selectedType == "長條圖" {
                BarChartView(targets: viewModel.targets)
            } else {
                PieChartView(targets: viewModel.targets)
            }
            
            Spacer()
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .background(Color.white.edgesIgnoringSafeArea(.all))
    }

    // MARK: - Button Group
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

    // MARK: - Date Selection View
    private func dateSelectionView() -> some View {
        Group {
            if selectedTab == "天" {
                HStack {
                    // 左箭頭按鈕
                    dateNavigationButton(systemName: "chevron.left") {
                        adjustDate(by: -1)
                    }
                    
                    // 日期選擇按鈕
                    Button(action: { showDatePicker = true }) {
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
                        DatePickerView(selectedDate: $selectedDate, showDatePicker: $showDatePicker)
                    }
                    
                    // 右箭頭按鈕
                    dateNavigationButton(systemName: "chevron.right") {
                        adjustDate(by: 1)
                    }
                }
                .padding(.all, 10)
            } else {
                HStack {
                    dateNavigationButton(systemName: "chevron.left") {
                        adjustDate(by: -1)
                    }
                    dateNavigationButton(systemName: "chevron.right") {
                        adjustDate(by: 1)
                    }
                }
                .padding(.all, 10)
            }
        }
    }
    
    // MARK: - Helper Views
    private func dateNavigationButton(systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.title)
                .padding()
                .background(Color.blue.opacity(0.7))
                .foregroundColor(.white)
                .cornerRadius(8)
        }
    }
    
    // MARK: - Helper Methods
    private func adjustDate(by value: Int) {
        if selectedTab == "天" {
            selectedDate = Calendar.current.date(byAdding: .day, value: value, to: selectedDate) ?? selectedDate
        } else if selectedTab == "週" {
            selectedDate = Calendar.current.date(byAdding: .weekOfYear, value: value, to: selectedDate) ?? selectedDate
        } else {
            selectedDate = Calendar.current.date(byAdding: .month, value: value, to: selectedDate) ?? selectedDate
        }
    }
}

// MARK: - Bar Chart View
struct BarChartView: View {
    let targets: [Target]
    
    var body: some View {
        VStack {
            Chart {
                ForEach(targets) { target in
                    BarMark(
                        x: .value("目標", target.name),
                        y: .value("時間", target.accumulatedTime / 60.0) // 轉換為分鐘
                    )
                    .foregroundStyle(Color(hex: target.color))
                }
            }
            .frame(height: 300)
            .padding(.vertical)

            TimeList(targets: targets)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
    }
}

// MARK: - Pie Chart View
struct PieChartView: View {
    let targets: [Target]
    
    var body: some View {
        VStack {
            GeometryReader { geometry in
                ZStack {
                    ForEach(0..<targets.count, id: \.self) { index in
                        PieSliceView(
                            target: targets[index],
                            index: index,
                            totalTargets: targets
                        )
                    }
                }
                .frame(width: min(geometry.size.width, geometry.size.height),
                       height: min(geometry.size.width, geometry.size.height))
                .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
            }
            .frame(height: 300)
            
            TimeList(targets: targets)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
    }
}

// MARK: - Pie Slice View
struct PieSliceView: View {
    let target: Target
    let index: Int
    let totalTargets: [Target]
    
    private var total: Double {
        totalTargets.reduce(0.0) { $0 + $1.accumulatedTime }
    }
    
    private var startAngle: Double {
        if index == 0 { return 0.0 }
        return totalTargets[0..<index].reduce(0.0) { $0 + ($1.accumulatedTime / total) } * 360
    }
    
    private var percentage: Double {
        target.accumulatedTime / total
    }
    
    var body: some View {
        PieSlice(
            startAngle: Angle(degrees: startAngle),
            endAngle: Angle(degrees: startAngle + percentage * 360)
        )
        .fill(Color(hex: target.color))
    }
}

// MARK: - Time List View
struct TimeList: View {
    let targets: [Target]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(targets) { target in
                    HStack {
                        Circle()
                            .fill(Color(hex: target.color))
                            .frame(width: 10, height: 10)
                        Text(target.name)
                            .foregroundColor(.primary)
                        Spacer()
                        Text(formatTime(seconds: target.accumulatedTime))
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
    
    private func formatTime(seconds: TimeInterval) -> String {
        let hours = Int(seconds) / 3600
        let minutes = Int(seconds) / 60 % 60
        return String(format: "%02d:%02d", hours, minutes)
    }
}

// MARK: - Date Picker View
struct DatePickerView: View {
    @Binding var selectedDate: Date
    @Binding var showDatePicker: Bool
    
    var body: some View {
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
}

// MARK: - Pie Slice Shape
struct PieSlice: Shape {
    var startAngle: Angle
    var endAngle: Angle
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        
        path.move(to: center)
        path.addArc(center: center,
                   radius: radius,
                   startAngle: startAngle - .degrees(90),
                   endAngle: endAngle - .degrees(90),
                   clockwise: false)
        path.closeSubpath()
        
        return path
    }
}

#Preview {
    TimeTrackerView(viewModel: GoalVM())
}
