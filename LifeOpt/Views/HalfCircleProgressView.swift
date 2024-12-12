//
//  Untitled.swift
//  LifeOpt
//
//  Created by Sean Fu on 2024/12/11.
//

import SwiftUI

struct HalfCircleProgressView: View {
    var progress: CGFloat
    var totalSteps: CGFloat
    var minValue: CGFloat
    var maxValue: CGFloat
    
    var body: some View {
        ZStack {
            // 背景灰色半圓
            Circle()
                .trim(from: 0, to: 0.5)
                .stroke(
                    Color.gray.opacity(0.2),
                    style: StrokeStyle(
                        lineWidth: 20,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(180))

            // 進度半圓
            Circle()
                .trim(from: 0, to: progress / totalSteps * 0.5)
                .stroke(
                    Color.blue,
                    style: StrokeStyle(
                        lineWidth: 20,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(180))
            

            VStack {
                Text("\(Int((progress / totalSteps) * 100))%")
                    .font(.system(size: 32, weight: .bold))
   
            }
            .offset(y: -15)
        }
        .frame(height: 200)
    }
}
