import SwiftUI

struct SplashView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var revealTiles = false
    @State private var revealBrand = false

    private let letters = Array("LEXIG")
    private let tileColors: [Color] = [.correct, .correct, .misplaced, .correct, .correct]

    var body: some View {
        ZStack {
            Color(red: 0.025, green: 0.055, blue: 0.13)
                .ignoresSafeArea()

            VStack(spacing: 22) {
                HStack(spacing: 8) {
                    ForEach(letters.indices, id: \.self) { index in
                        Text(String(letters[index]))
                            .font(.system(size: 30, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                            .frame(width: 54, height: 54)
                            .background(tileColors[index])
                            .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
                            .scaleEffect(revealTiles ? 1 : 0.92)
                            .opacity(revealTiles ? 1 : 0)
                            .animation(
                                reduceMotion
                                    ? .easeOut(duration: 0.2)
                                    : .easeOut(duration: 0.3).delay(Double(index) * 0.06),
                                value: revealTiles
                            )
                    }
                }

                VStack(spacing: 6) {
                    Text("LEXIGRID")
                        .font(.system(size: 38, weight: .black, design: .rounded))
                        .tracking(4)
                        .foregroundColor(.white)
                }
                .opacity(revealBrand ? 1 : 0)
                .offset(y: revealBrand ? 0 : 10)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("LexiGrid")
        .preferredColorScheme(.dark)
        .onAppear {
            revealTiles = true
            withAnimation(.easeOut(duration: reduceMotion ? 0.2 : 0.35).delay(0.28)) {
                revealBrand = true
            }
        }
    }
}

struct AppRootView: View {
    @EnvironmentObject private var csManager: ColorSchemeManager
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @State private var showsSplash = true

    var body: some View {
        ZStack {
            GameView()
                .opacity(showsSplash ? 0 : 1)

            if showsSplash {
                SplashView()
                    .transition(.opacity)
                    .zIndex(1)
            }

            if !showsSplash && !hasSeenOnboarding {
                OnboardingView {
                    withAnimation(.easeInOut(duration: 0.35)) {
                        hasSeenOnboarding = true
                    }
                }
                .transition(.opacity)
                .zIndex(2)
            }
        }
        .onAppear {
            csManager.applyColorScheme()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation(.easeInOut(duration: 0.4)) {
                    showsSplash = false
                }
            }
        }
    }
}

struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView()
    }
}
