//
//  GuessView.swift
//  wordleclone
//
//  Created by Shameem Reza on 1/3/22.
//

import SwiftUI

struct GuessView: View {
    @Binding var guess: Guess
    @AppStorage("colorBlindMode") private var colorBlindMode = false
    var body: some View {
        HStack(spacing: 5) {
            ForEach(0...4, id: \.self) { index in
                FlipView(isFlipped: $guess.cardFlipped[index]) {
                    Text(guess.guessLetters[index])
                        .foregroundColor(guess.invalidFlash ? .white : .primary)
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
                        .background(guess.invalidFlash ? Color.red : Color.systemBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .stroke(guess.invalidFlash ? Color.red : Color(.separator), lineWidth: 1.5)
                        )
                        .animation(.easeInOut(duration: 0.16), value: guess.invalidFlash)
                } back: {
                    ZStack(alignment: .bottomTrailing) {
                        Text(guess.guessLetters[index])
                            .foregroundColor(.white)
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
                            .background(Color.feedback(guess.bgColors[index], colorBlind: colorBlindMode))
                        if colorBlindMode {
                            Image(systemName: feedbackSymbol(for: guess.bgColors[index]))
                                .font(.system(size: 11, weight: .black))
                                .foregroundColor(.white.opacity(0.95))
                                .padding(6)
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
                    .font(.system(size: 35, weight: .heavy))
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    .modifier(TilePopEffect(trigger: guess.letterPulses[index]))
                    .accessibilityLabel(guess.guessLetters[index].isEmpty ? "Empty tile" : guess.guessLetters[index])
            }
        }
    }
}

func feedbackSymbol(for color: Color) -> String {
    if color == .correct { return "checkmark" }
    if color == .misplaced { return "circle.fill" }
    return "xmark"
}

private struct TilePopEffect: AnimatableModifier {
    let trigger: Int
    @State private var scale: CGFloat = 1

    var animatableData: CGFloat {
        get { scale }
        set { scale = newValue }
    }

    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .onChange(of: trigger) { _ in
                withAnimation(.spring(response: 0.16, dampingFraction: 0.55)) {
                    scale = 1.12
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                    withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                        scale = 1
                    }
                }
            }
    }
}

struct GuessView_Previews: PreviewProvider {
    static var previews: some View {
        GuessView(guess: .constant(Guess(index: 0)))
    }
}
