import SwiftUI

struct StatsView: View {
    @EnvironmentObject var dm: WordleDataModel
    @AppStorage("colorBlindMode") private var colorBlindMode = false
    @State private var animateBars = false

    private var accent: Color { Color.feedback(.correct, colorBlind: colorBlindMode) }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(dm.gameOver ? (dm.tryIndex < 6 ? "Round complete" : "Good try") : "Your progress")
                        .font(.title2.weight(.bold))
                    if dm.gameOver {
                        Text(dm.tryIndex < 6 ? "You found the word" : "The answer was \(dm.selectedWord)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                Spacer()
                Button { withAnimation { dm.showStats.toggle() } } label: {
                    Image(systemName: "xmark.circle.fill").font(.title2).foregroundColor(.secondary)
                }
                .accessibilityLabel("Close statistics")
            }
            .padding(.bottom, 14)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    if dm.gameOver { roundSummary }
                    lifetimeStats
                    distribution
                    if dm.gameOver { wordCard }
                }
                .padding(.bottom, 8)
            }

            if dm.gameOver {
                Button { dm.shareResult() } label: {
                    Label("Share result", systemImage: "square.and.arrow.up")
                        .font(.body.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .foregroundColor(.white)
                        .background(accent, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .padding(.top, 12)
            }
        }
        .padding(22)
        .frame(width: min(Global.screenWidth - 28, 400), height: min(Global.screenHeight - 70, 650))
        .background(RoundedRectangle(cornerRadius: 24, style: .continuous).fill(Color.systemBackground))
        .shadow(color: .black.opacity(0.2), radius: 24, y: 10)
        .onAppear { withAnimation(.easeOut(duration: 0.55)) { animateBars = true } }
    }

    private var roundSummary: some View {
        HStack(spacing: 10) {
            ResultMetric(value: "\(dm.roundScore)", label: "Score", icon: "star.fill", tint: accent)
            ResultMetric(value: dm.tryIndex < 6 ? "\(dm.tryIndex + 1)/6" : "X/6", label: "Guesses", icon: "square.grid.3x3.fill", tint: .blue)
            ResultMetric(value: "\(dm.hintsUsed)", label: "Hints", icon: "lightbulb.fill", tint: .orange)
        }
    }

    private var lifetimeStats: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("ALL-TIME STATS").font(.caption.weight(.bold)).foregroundColor(.secondary)
            HStack(alignment: .top) {
                SingleStat(value: "\(dm.currentStat.games)", text: "Played")
                SingleStat(value: dm.currentStat.games == 0 ? "0" : "\(Int(100 * dm.currentStat.wins / dm.currentStat.games))", text: "Win %")
                SingleStat(value: dm.currentStat.wins == 0 ? "—" : String(format: "%.1f", dm.averageWinningGuesses), text: "Avg guesses")
                SingleStat(value: "\(dm.currentStat.maxStreak)", text: "Best streak")
            }
            if dm.currentStat.bestScore > 0 {
                HStack {
                    Label("Personal best", systemImage: "trophy.fill").foregroundColor(.secondary)
                    Spacer()
                    Text("\(dm.currentStat.bestScore) points").fontWeight(.semibold)
                }
                .font(.caption)
            }
        }
    }

    private var distribution: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("GUESS DISTRIBUTION").font(.caption.weight(.bold)).foregroundColor(.secondary)
            ForEach(0..<6) { index in
                HStack(spacing: 8) {
                    Text("\(index + 1)").font(.caption.monospacedDigit()).frame(width: 12)
                    GeometryReader { proxy in
                        let maximum = max(1, dm.currentStat.frequencies.max() ?? 1)
                        let ratio = CGFloat(dm.currentStat.frequencies[index]) / CGFloat(maximum)
                        Capsule()
                            .fill(dm.gameOver && dm.tryIndex == index ? accent : Color.wrong)
                            .frame(width: animateBars ? max(24, proxy.size.width * ratio) : 24)
                            .overlay(alignment: .trailing) {
                                Text("\(dm.currentStat.frequencies[index])")
                                    .font(.caption2.bold()).foregroundColor(.white).padding(.trailing, 7)
                            }
                    }
                    .frame(height: 22)
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Guess distribution")
    }

    private var wordCard: some View {
        let entry = WordDictionary.entry(for: dm.selectedWord)
        return VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                Text(entry.word).font(.system(.title2, design: .rounded).weight(.black)).tracking(2)
                Text(entry.partOfSpeech).font(.caption.italic()).foregroundColor(.secondary)
            }
            Text(entry.definition).font(.subheadline)
            if !entry.example.isEmpty {
                Text("“\(entry.example)”").font(.caption).italic().foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .accessibilityElement(children: .combine)
    }
}

private struct ResultMetric: View {
    let value: String
    let label: String
    let icon: String
    let tint: Color
    var body: some View {
        VStack(spacing: 5) {
            Image(systemName: icon).foregroundColor(tint)
            Text(value).font(.title3.bold()).monospacedDigit()
            Text(label).font(.caption2).foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(tint.opacity(0.1), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

private struct SingleStat: View {
    let value: String
    let text: String
    var body: some View {
        VStack(spacing: 3) {
            Text(value).font(.title3).monospacedDigit()
            Text(text).font(.caption2).multilineTextAlignment(.center).foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct StatsView_Previews: PreviewProvider {
    static var previews: some View { StatsView().environmentObject(WordleDataModel()) }
}
