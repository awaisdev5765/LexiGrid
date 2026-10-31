import SwiftUI

struct OnboardingView: View {
    let onComplete: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var typedCount = 0
    @State private var isSubmitting = false
    @State private var submitted = false
    @State private var handBounces = false
    @State private var demoRun = 0

    private let word = Array("APPLE")

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.systemBackground, Color.correct.opacity(0.07)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 26) {
                HStack {
                    Label("Quick tutorial", systemImage: "sparkles")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.correct)
                    Spacer()
                    Button("Skip") { finish() }
                        .foregroundColor(.secondary)
                        .accessibilityHint("Skips the tutorial")
                }

                HStack(spacing: 8) {
                    ForEach(1...3, id: \.self) { step in
                        Capsule()
                            .fill(step <= currentStep ? Color.correct : Color(.systemGray5))
                            .frame(height: 5)
                    }
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Tutorial step \(currentStep) of 3")

                VStack(spacing: 8) {
                    Text("Try your first word")
                        .font(.system(.largeTitle, design: .rounded).weight(.bold))
                    Text(instruction)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .animation(.easeInOut, value: instruction)
                }

                HStack(spacing: 7) {
                    ForEach(word.indices, id: \.self) { index in
                        Text(index < typedCount ? String(word[index]) : "")
                            .font(.system(size: 30, weight: .black, design: .rounded))
                            .foregroundColor(submitted ? .white : .primary)
                            .frame(maxWidth: .infinity)
                            .aspectRatio(1, contentMode: .fit)
                            .background(submitted ? Color.correct : Color.systemBackground)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .stroke(index < typedCount ? Color.correct : Color(.separator), lineWidth: 2)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            .rotation3DEffect(
                                .degrees(submitted ? 360 : 0),
                                axis: (x: 1, y: 0, z: 0)
                            )
                            .animation(
                                .easeInOut(duration: reduceMotion ? 0.1 : 0.55).delay(Double(index) * 0.08),
                                value: submitted
                            )
                            .scaleEffect(index == typedCount - 1 && !submitted ? 1.08 : 1)
                            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: typedCount)
                    }
                }
                .frame(maxWidth: 350)
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color(.secondarySystemBackground).opacity(0.8))
                )

                VStack(spacing: 12) {
                    HStack(spacing: 8) {
                        ForEach(word.indices, id: \.self) { index in
                            VStack(spacing: 3) {
                                Image(systemName: "hand.point.up.left.fill")
                                    .font(.title2)
                                    .foregroundColor(.correct)
                                    .opacity(typedCount == index && !isSubmitting ? 1 : 0)
                                    .offset(y: handBounces ? -3 : 3)

                                Text(String(word[index]))
                                    .font(.title3.weight(.bold))
                                    .frame(width: 48, height: 50)
                                    .background(typedCount == index && !isSubmitting ? Color.correct.opacity(0.2) : Color.unused)
                                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                            }
                        }
                    }

                    VStack(spacing: 4) {
                        Image(systemName: "arrow.down")
                            .font(.title2.weight(.bold))
                            .foregroundColor(.misplaced)
                            .opacity(isSubmitting && !submitted ? 1 : 0)
                            .offset(y: handBounces ? 2 : -2)

                        Label("Enter", systemImage: "return")
                            .font(.headline)
                            .foregroundColor(isSubmitting ? .white : .primary)
                            .padding(.horizontal, 30)
                            .frame(height: 50)
                            .background(isSubmitting ? Color.correct : Color.unused)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            .scaleEffect(isSubmitting && !submitted ? 1.06 : 1)
                    }
                }
                .accessibilityHidden(true)

                if submitted {
                    HStack(spacing: 14) {
                        Label("Correct letter", systemImage: "checkmark.square.fill")
                            .foregroundColor(.correct)
                        Label("Correct position", systemImage: "scope")
                            .foregroundColor(.secondary)
                    }
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(Color(.secondarySystemBackground), in: Capsule())
                    .transition(.scale.combined(with: .opacity))
                }

                Spacer()

                VStack(spacing: 10) {
                    Button {
                        finish()
                    } label: {
                        HStack {
                            Text(submitted ? "Start Playing" : "Learning…")
                            if submitted { Image(systemName: "arrow.right") }
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(submitted ? Color.correct : Color.secondary.opacity(0.35))
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                    .disabled(!submitted)

                    if submitted {
                        Button {
                            replayDemo()
                        } label: {
                            Label("Watch again", systemImage: "arrow.counterclockwise")
                                .font(.subheadline.weight(.semibold))
                        }
                        .transition(.opacity)
                    }
                }
            }
            .padding(24)
        }
        .onAppear { runDemo() }
    }

    private var instruction: String {
        if submitted { return "Green tiles are correct. You’re ready to play!" }
        if isSubmitting { return "When all five letters are ready, tap Enter." }
        return "Tap letters to build a valid five-letter word."
    }

    private var currentStep: Int {
        if submitted { return 3 }
        if isSubmitting { return 2 }
        return 1
    }

    private func runDemo() {
        demoRun += 1
        let activeRun = demoRun
        withAnimation(.easeInOut(duration: 0.45).repeatForever(autoreverses: true)) {
            handBounces = true
        }
        for index in word.indices {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7 + Double(index) * 0.48) {
                guard activeRun == demoRun else { return }
                withAnimation { typedCount = index + 1 }
                Haptics.play(.keyTap)
                SoundManager.shared.play(.keyTap)
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.25) {
            guard activeRun == demoRun else { return }
            withAnimation(.spring(response: 0.35, dampingFraction: 0.65)) {
                isSubmitting = true
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.15) {
            guard activeRun == demoRun else { return }
            withAnimation { submitted = true }
            Haptics.play(.win)
            SoundManager.shared.play(.win)
        }
    }

    private func replayDemo() {
        demoRun += 1
        withAnimation {
            typedCount = 0
            isSubmitting = false
            submitted = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            runDemo()
        }
    }

    private func finish() {
        Haptics.play(.keyTap)
        onComplete()
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(onComplete: {})
    }
}
