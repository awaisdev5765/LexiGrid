//
//  LexiGridApp.swift
//  LexiGrid
//
//  Created by Shameem Reza on 1/3/22.
//

import SwiftUI

@main
struct LexiGridApp: App {
    @StateObject var dm = WordleDataModel()
    @StateObject var csManager = ColorSchemeManager()
    var body: some Scene {
        WindowGroup {
            AppRootView()
                .environmentObject(dm)
                .environmentObject(csManager)
        }
    }
}
