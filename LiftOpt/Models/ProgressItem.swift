//
//  ProgressItem.swift
//  LiftOpt
//
//  Created by Sean Fu on 2024/10/19.
//

import SwiftUI

public struct ProgressItem: Identifiable {
    public let id = UUID()
    public let title: String
    public var progress: Double
    public let color: Color
 

}
