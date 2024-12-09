//
//  GoalVM.swift
//  LiftOpt
//
//  Created by Sean Fu on 2024/12/9.
//

import SwiftUI

class GoalVM: ObservableObject {
    @Published var Goalblock: [Goal] = [
        Goal(title: "提升職場競爭力", progress: 0.75, color: .blue),
        Goal(title: "保持健康生活", progress: 0.60, color: .green),
        Goal(title: "學習新技能", progress: 0.40, color: .orange)
    ]
    
    func addGoal(_ item: Goal) {
        Goalblock.append(item)
    }
}
