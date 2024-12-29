//
//  ContentView.swift
//  LiftOpt
//
//  Created by Sean Fu on 2024/10/18.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    var body: some View {
        ZStack{
            TabView(selection: $selectedTab) {
                HomePageView()
                    .tabItem {
                        Image(systemName: "house.fill")
                        Text("概覽")
                    }
                    .tag(0)
                TimeTrackerView(viewModel: GoalVM())
                    .tabItem{
                        Image(systemName: "chart.bar")
                        Text("時間追蹤")
                    }
                    .tag(1)
                
                TimerView(viewModel: GoalVM())
                    .tabItem{
                        Image(systemName:"timer")
                        Text("計時器")
                    }
                    .tag(2)

//                DailyReviewView()
//                    .tabItem{
//                        Image(systemName: "square.and.pencil")
//                        Text("每日反思")
//                    }.tag(3)
//                
//                    .tag(2)
//              SettingView()
//                   .tabItem{
//                       Image(systemName: "gear")
//                       Text("設定")
//                   }
//                   .tag(3)
       
            }
            
        }
    }
}

#Preview {
    ContentView()
}
