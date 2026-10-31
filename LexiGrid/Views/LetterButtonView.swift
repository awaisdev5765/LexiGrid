//
//  LetterButtonView.swift
//  wordleclone
//
//  Created by Shameem Reza on 1/3/22.
//

import SwiftUI

struct LetterButtonView: View {
    @EnvironmentObject var dm: WordleDataModel
    @AppStorage("colorBlindMode") private var colorBlindMode = false
    var letter: String

    private var keyColor: Color {
        Color.feedback(dm.keyColors[letter] ?? .unused, colorBlind: colorBlindMode)
    }

    var body: some View {
        Button {
            dm.addToCurrentWord(letter)
        } label: {
            ZStack(alignment: .bottomTrailing) {
                Text(letter)
                    .font(.system(size: 20))
                    .frame(width: 35, height: 50)
                    .background(keyColor)
                    .foregroundColor(.primary)
                if colorBlindMode, let color = dm.keyColors[letter], color != .unused {
                    Image(systemName: feedbackSymbol(for: color))
                        .font(.system(size: 7, weight: .black))
                        .foregroundColor(.white)
                        .padding(3)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
            .animation(.easeInOut(duration: 0.28), value: keyColor)
        }
        .buttonStyle(.plain)
    }
}

struct LetterButtonView_Previews: PreviewProvider {
    static var previews: some View {
        LetterButtonView(letter: "L")
            .environmentObject(WordleDataModel())
    }
}
