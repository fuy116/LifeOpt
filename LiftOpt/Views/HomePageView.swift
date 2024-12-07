import SwiftUI

struct OverviewItem {
    let icon: String
    let title: String
    let value: String
    let color: Color
}


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
    .background(Color(UIColor.systemGray6)) // 使用淺灰色背景
    .cornerRadius(10)
}

func progressCard(item: ProgressItem) -> some View {
    VStack(alignment: .leading, spacing: 8) {
        Text(item.title)
            .font(.subheadline)
            .fontWeight(.medium)
        
        HStack {
            Text("\(Int(item.progress * 100))%")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(item.color)
            
            Spacer()
        }
        
        ProgressView(value: item.progress)
            .progressViewStyle(LinearProgressViewStyle(tint: item.color))
    }
    .padding()
    .background(item.color.opacity(0.1))
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
            Text("本週進度")
                .font(.headline)
            Spacer()
   
        }
        
    }
    .padding()
    .background(Color.white)
    .cornerRadius(10)
}
func achievementView() -> some View {
    VStack(alignment: .leading, spacing: 16) {
        HStack {
            Text("最近成就")
                .font(.headline)
            Spacer()
   
        }
        
    }
    .padding()
    .background(Color.white)
    .cornerRadius(10)
}
struct HomePageView: View {
    @StateObject private var viewModel = ProgressViewModel()
    @State private var isAddingNewItem = false

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                HStack {
                    Text("您好，User")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Spacer()
                    Circle()
                        .fill(Color.gray)
                        .frame(width: 40, height: 40)
                }
                todayOverview()
                progressView(viewModel: viewModel, isAddingNewItem: $isAddingNewItem)
                weeklyView()
                achievementView()
            }
            .padding()
        }
        .background(Color(UIColor.systemGray6))
        .sheet(isPresented: $isAddingNewItem) {
            AddProgressItemView(viewModel: viewModel)
        }
    }

    private func progressView(viewModel: ProgressViewModel, isAddingNewItem: Binding<Bool>) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("進度概覽")
                    .font(.headline)
                Spacer()
                Button {
                    isAddingNewItem.wrappedValue = true
                } label: {
                    Image(systemName: "plus.app")
                }
            }
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(viewModel.progressItems) { item in
                    progressCard(item: item)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
    }
}

#Preview {
    HomePageView()
}
