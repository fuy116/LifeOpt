//
//  ProgressViewModel.swift
//  LiftOpt
//
//  Created by Sean Fu on 2024/10/19.
//

import SwiftUI

class ProgressViewModel: ObservableObject {
    @Published var progressItems: [ProgressItem] = [
        ProgressItem(title: "提升職場競爭力", progress: 0.75, color: .blue),
        ProgressItem(title: "保持健康生活", progress: 0.60, color: .green),
        ProgressItem(title: "學習新技能", progress: 0.40, color: .orange)
    ]
    
    func addProgressItem(_ item: ProgressItem) {
        progressItems.append(item)
    }
}
