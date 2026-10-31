//
//  SettingsView.swift
//  wordleclone
//
//  Created by Shameem Reza on 1/3/22.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var csManager: ColorSchemeManager
    @EnvironmentObject var dm: WordleDataModel
    @Environment(\.dismiss) var dismiss
    @AppStorage("colorBlindMode") private var colorBlindMode = false
    @AppStorage("soundEnabled") private var soundEnabled = true
    @AppStorage("hapticsEnabled") private var hapticsEnabled = true
    var body: some View {
        NavigationView {
            Form {
                Section {
                    Toggle(isOn: $dm.hardMode) {
                        Label("Hard Mode", systemImage: "flame.fill")
                    }
                    Text("Every revealed hint must be used in later guesses.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } header: {
                    Text("Gameplay")
                }

                Section {
                    Toggle(isOn: $colorBlindMode) {
                        Label("Color-blind mode", systemImage: "eye")
                    }
                    Text("Uses blue and orange with symbols so feedback never relies on color alone.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } header: {
                    Text("Accessibility")
                }

                Section {
                    Toggle(isOn: $soundEnabled) {
                        Label("Game sounds", systemImage: "speaker.wave.2.fill")
                    }
                    Toggle(isOn: $hapticsEnabled) {
                        Label("Haptics", systemImage: "hand.tap.fill")
                    }
                    Button {
                        SoundManager.shared.play(.win)
                        Haptics.play(.win)
                    } label: {
                        Label("Preview feedback", systemImage: "play.circle")
                    }
                } header: {
                    Text("Sound & feedback")
                }

                Section {
                    VStack(alignment: .leading, spacing: 10) {
                        Label("Appearance", systemImage: "circle.lefthalf.filled")
                        Picker("Display Mode", selection: $csManager.colorScheme) {
                            Text("System").tag(ColorScheme.unspecified)
                            Text("Light").tag(ColorScheme.light)
                            Text("Dark").tag(ColorScheme.dark)
                        }
                        .pickerStyle(.segmented)
                    }
                }

                Section {
                    HStack {
                        Text("LexiGrid")
                        Spacer()
                        Text("Version 1.1")
                            .foregroundColor(.secondary)
                    }
                    Link("Built by awaisdev5765", destination: URL(string: "https://github.com/awaisdev5765")!)
                } header: {
                    Text("About")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .font(.body.weight(.semibold))
                }
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(ColorSchemeManager())
            .environmentObject(WordleDataModel())
    }
}
