//
//  HelpView.swift
//  wordleclone
//
//  Created by Shameem Reza on 1/3/22.
//

import SwiftUI

struct HelpView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                Text(
        """
        Guess the **LexiGrid word** in 6 tries.
        
        Each guess must be a valid 5-letter word. Tap Enter to submit.
        
        After each guess, the color of the tiles will change to show how close your guess was to the word.
        """
                )
                Divider()
                Text("Examples")
                    .font(.headline)
                VStack(alignment: .leading) {
                    Image("Weary")
                        .resizable()
                        .scaledToFit()
                    Text("The letter **W** is in the word and in the correct spot.")
                    Image("Pills")
                        .resizable()
                        .scaledToFit()
                    Text("The letter **I** is in the word but in the wrong spot.")
                    Image("Vague")
                        .resizable()
                        .scaledToFit()
                    Text("The letter **U** is not in the word in any spot.")
                }
                Divider()
                Label("Finish a round to start a new puzzle.", systemImage: "arrow.clockwise")
                    .font(.subheadline.weight(.semibold))
                Button {
                    hasSeenOnboarding = false
                    dismiss()
                } label: {
                    Label("Replay interactive tutorial", systemImage: "hand.tap")
                        .font(.body.weight(.semibold))
                }
                }
            }
            .frame(width: min(Global.screenWidth - 40, 350))
            .navigationTitle("How to play")
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

struct HelpView_Previews: PreviewProvider {
    static var previews: some View {
        HelpView()
    }
}
