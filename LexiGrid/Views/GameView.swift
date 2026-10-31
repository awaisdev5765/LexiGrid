//
//  ContentView.swift
//  wordleclone
//
//  Created by Shameem Reza on 1/3/22.
//

import SwiftUI

struct GameView: View {
    @EnvironmentObject var dm: WordleDataModel
    @State private var showSettings = false
    @State private var showHelp = false
    var body: some View {
        ZStack {
            NavigationView {
                VStack(spacing: 0) {
                    if Global.screenHeight < 600 {
                        Text("")
                    }
                    Spacer()
                    VStack(spacing: 5) {
                        ForEach(0...5, id: \.self) { index in
                            GuessView(guess: $dm.guesses[index])
                                .modifier(Shake(animatableData: CGFloat(dm.incorrectAttempts[index])))
                        }
                    }
                    .frame(width: Global.boardWidth, height: 6 * Global.boardWidth / 5)
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(Color(.secondarySystemBackground).opacity(0.65))
                    )
                    Spacer()
                    Keyboard()
                        .scaleEffect(Global.keyboardScale)
                        .padding(.horizontal, 6)
                    Spacer()
                }
                .background(
                    LinearGradient(colors: [Color.systemBackground, Color.correct.opacity(0.06)], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                )
                .disabled(dm.showStats)
                .navigationBarTitleDisplayMode(.inline)
                .disabled(dm.showStats)
                .overlay(alignment: .top) {
                    if let toastText = dm.toastText {
                        ToastView(toastText: toastText)
                            .offset(y: 20)
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        HStack {
                            if !dm.inPlay {
                                Button {
                                    dm.newGame()
                                } label: {
                                    Image(systemName: "arrow.clockwise")
                                }
                                .accessibilityLabel("New game")
                            }
                            Button {
                                showHelp.toggle()
                            } label: {
                                Image(systemName: "questionmark.circle")
                            }
                            .accessibilityLabel("How to play")
                        }
                    }
                    ToolbarItem(placement: .principal) {
                        Text("LEXIGRID")
                            .font(.system(.title2, design: .rounded).weight(.black))
                            .tracking(1.5)
                            .foregroundColor(dm.hardMode ? Color(.systemRed) : .primary)
                            .minimumScaleFactor(0.5)
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        HStack {
                            Button {
                                dm.useHint()
                            } label: {
                                Image(systemName: dm.hintsUsed == 0 ? "lightbulb" : "lightbulb.fill")
                            }
                            .disabled(!dm.inPlay)
                            .accessibilityLabel("Use a hint. \(2 - dm.hintsUsed) remaining")
                            Button {
                                withAnimation {
                                    dm.currentStat = Statistic.loadStat()
                                    dm.showStats.toggle()
                                }
                            } label: {
                                Image(systemName: "chart.bar")
                            }
                            .accessibilityLabel("Statistics")
                            Button {
                                showSettings.toggle()
                            } label: {
                                Image(systemName: "gearshape.fill")
                            }
                            .accessibilityLabel("Settings")
                        }
                    }
                }
                .sheet(isPresented: $showSettings) {
                    SettingsView()
                }
            }
            if dm.showStats {
                StatsView()
            }
            if dm.showCelebration {
                ConfettiView()
                    .allowsHitTesting(false)
                    .transition(.opacity)
                    .zIndex(10)
            }
        }
        .navigationViewStyle(.stack)
        .sheet(isPresented: $showHelp) {
            HelpView()
        }
        .alert("Hint \(min(dm.hintsUsed, 2)) of 2", isPresented: $dm.showHint) {
            Button("Continue", role: .cancel) { }
        } message: {
            Text(dm.hintMessage)
        }
    }
}

private struct ConfettiPiece: Identifiable {
    let id = UUID()
    let x: CGFloat
    let delay: Double
    let duration: Double
    let size: CGFloat
    let rotation: Double
    let color: Color
}

private struct ConfettiView: View {
    @State private var isFalling = false
    private let pieces: [ConfettiPiece] = (0..<42).map { index in
        let colors: [Color] = [.correct, .misplaced, .blue, .pink, .purple, .orange]
        return ConfettiPiece(
            x: CGFloat((index * 37) % 100) / 100,
            delay: Double(index % 9) * 0.07,
            duration: 2.1 + Double(index % 7) * 0.12,
            size: CGFloat(6 + (index % 5) * 2),
            rotation: Double((index * 71) % 360),
            color: colors[index % colors.count]
        )
    }

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                ForEach(pieces) { piece in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(piece.color)
                        .frame(width: piece.size, height: piece.size * 1.55)
                        .rotationEffect(.degrees(isFalling ? piece.rotation + 540 : piece.rotation))
                        .position(
                            x: max(10, min(proxy.size.width - 10, proxy.size.width * piece.x)),
                            y: isFalling ? proxy.size.height + 30 : -30
                        )
                        .animation(
                            .easeIn(duration: piece.duration).delay(piece.delay),
                            value: isFalling
                        )
                }
            }
            .onAppear { isFalling = true }
        }
        .ignoresSafeArea()
        .accessibilityHidden(true)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        GameView()
            .environmentObject(WordleDataModel())
    }
}
