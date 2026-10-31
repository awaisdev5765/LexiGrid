//
//  Color+Extensions.swift
//  wordleclone
//
//  Created by Shameem Reza on 1/3/22.
//

import SwiftUI

extension Color {
    static var wrong: Color {
        Color(UIColor(named: "wrong")!)
    }
    static var misplaced: Color {
        Color(UIColor(named: "misplaced")!)
    }
    static var correct: Color {
        Color(UIColor(named: "correct")!)
    }
    static var unused: Color {
        Color(UIColor(named: "unused")!)
    }
    static var systemBackground: Color {
        Color(.systemBackground)
    }
    static var accessibleCorrect: Color {
        Color(red: 0.05, green: 0.45, blue: 0.78)
    }
    static var accessibleMisplaced: Color {
        Color(red: 0.95, green: 0.50, blue: 0.08)
    }
    static func feedback(_ color: Color, colorBlind: Bool) -> Color {
        guard colorBlind else { return color }
        if color == .correct { return .accessibleCorrect }
        if color == .misplaced { return .accessibleMisplaced }
        return color
    }
}
