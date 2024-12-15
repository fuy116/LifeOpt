import SwiftUI

func overviewCard(item: OverviewItem) -> some View {
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

func todayOverview() -> some View {
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
            overviewCard(item: OverviewItem(icon: "clock", title: "專注時間", value: "3h 20m", color: .green))
            overviewCard(item: OverviewItem(icon: "chart.bar", title: "完成任務", value: "5/8", color: .blue))
        }
    }
    .padding()
    .background(Color.white)
    .cornerRadius(10)
}

func weeklyView() -> some View {
    VStack(alignment: .leading, spacing: 16) {
        HStack {
            Text("本日任務")
                .font(.headline)
            Spacer()
        }
    }
    .padding()
    .background(Color.white)
    .cornerRadius(10)
}

struct HomePageView: View {
    @StateObject private var viewModel = GoalVM()
    @State private var isAddingNewItem = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    HStack {
                        Text("您好，User")
                               .font(.largeTitle)
                               .fontWeight(.bold)
                        Spacer()
                        //使用者頭像可以放這
                        // Circle()
                          //  .fill(Color.gray)
                            //.frame(width: 40, height: 40)
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
    
    private func progressCard(item: Target) -> some View {
        NavigationLink(destination: TargetDetailView(viewModel: viewModel, target: item)) {
            VStack(alignment: .leading, spacing: 8) {
                Text(item.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                HStack {
                    Text("\(Int(item.totalProgress ))%")
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
}

// 用色碼表示顏色
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
