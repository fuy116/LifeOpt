//
//  a.swift
//  LiftOpt
//
//  Created by Sean Fu on 2024/10/19.
//

import SwiftUI

struct AddProgressItemView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: ProgressViewModel
    
    @State private var title: String = ""
    @State private var progress: Double = 0.0
    @State private var color: Color = .blue
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("項目詳情")) {
                    TextField("標題", text: $title)
                    
                    VStack {
                        Text("進度: \(Int(progress * 100))%")
                        Slider(value: $progress, in: 0...1, step: 0.01)
                    }
                    
                    ColorPicker("選擇顏色", selection: $color)
                }
                
                Section {
                    Button("添加項目") {
                        addItem()
                    }
                }
            }
            .navigationTitle("新增進度項目")
            .navigationBarItems(trailing: Button("取消") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    private func addItem() {
        let newItem = ProgressItem(title: title, progress: progress, color: color)
        viewModel.addProgressItem(newItem)
        presentationMode.wrappedValue.dismiss()
    }
}
