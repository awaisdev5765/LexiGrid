//
//  WordleDataModel.swift
//  wordleclone
//
//  Created by Shameem Reza on 1/3/22.
//

import SwiftUI

class WordleDataModel: ObservableObject {
    @Published var guesses: [Guess] = []
    @Published var incorrectAttempts = [Int](repeating: 0, count: 6)
    @Published var toastText: String?
    @Published var showStats = false
    @Published var showCelebration = false
    @Published var showHint = false
    @Published var hintMessage = ""
    @Published var keyColors = [String : Color]()
    @AppStorage("hardMode") var hardMode = false
    
    var matchedLetters = [String]()
    var misplacedLetters = [String]()
    var correctlyPlacedLetters = [String]()
    var selectedWord = ""
    var currentWord = ""
    var tryIndex = 0
    var inPlay = false
    var gameOver = false
    var hintsUsed = 0
    private var eliminatedHintLetters = Set<String>()
    var toastWords = ["Genius", "Impressive", "Splendid", "Magnificent", "Great", "Phew"]
    var currentStat: Statistic
    
    var gameStarted: Bool {
        !currentWord.isEmpty || tryIndex > 0
    }
    
    var disabledKeys: Bool {
        !inPlay || currentWord.count == 5
    }

    var roundScore: Int {
        guard gameOver, tryIndex < 6 else { return 0 }
        let guessPenalty = min(50, tryIndex * 10)
        return max(0, 100 - guessPenalty - hintsUsed * 15)
    }

    var averageWinningGuesses: Double { currentStat.averageWinningGuesses }
    
    init() {
        currentStat = Statistic.loadStat()
        newGame()
    }
    
    // MARK: - SETUP
    func newGame() {
        populateDefaults()
        selectedWord = WordDictionary.randomAnswer()
        correctlyPlacedLetters = [String](repeating: "-", count: 5)
        currentWord = ""
        inPlay = true
        tryIndex = 0
        gameOver = false
        hintsUsed = 0
        eliminatedHintLetters = []
        hintMessage = ""
    }
    
    func populateDefaults() {
        guesses = []
        for index in 0...5 {
            guesses.append(Guess(index: index))
        }
        //reset keyboard colors
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        for char in letters {
            keyColors[String(char)] = .unused
        }
        matchedLetters = []
        misplacedLetters = []
    }
    
    // MARK: - GMAE PLAY
    func addToCurrentWord(_ letter: String) {
        guard currentWord.count < 5, inPlay else { return }
        currentWord += letter
        updateRow()
        guesses[tryIndex].letterPulses[currentWord.count - 1] += 1
        Haptics.play(.keyTap)
        SoundManager.shared.play(.keyTap)
    }
    
    func enterWord() {
        SoundManager.shared.play(.submit)
        if currentWord == selectedWord {
            gameOver = true
            print("You Win")
            withAnimation(.easeInOut(duration: 0.28)) { setCurrentGuessColors() }
            currentStat.update(win: true, index: tryIndex, hintsUsed: hintsUsed, score: roundScore)
            showToast(with: toastWords[tryIndex])
            inPlay = false
            Haptics.play(.win)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                SoundManager.shared.play(.win)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                withAnimation(.easeOut(duration: 0.25)) { self.showCelebration = true }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.2) {
                withAnimation { self.showCelebration = false }
            }
        } else {
            if verifyWord() {
                if hardMode {
                    if let toastString = hardCorrectCheck() {
                        showToast(with: toastString)
                        Haptics.play(.invalid)
                        SoundManager.shared.play(.error)
                        return
                    }
                    if let toastString = hardMisplacedCheck() {
                        showToast(with: toastString)
                        Haptics.play(.invalid)
                        SoundManager.shared.play(.error)
                        return
                    }
                }

                withAnimation(.easeInOut(duration: 0.28)) { setCurrentGuessColors() }
                tryIndex += 1
                currentWord = ""
                if tryIndex == 6 {
                    currentStat.update(win: false, hintsUsed: hintsUsed, score: 0)
                    gameOver = true
                    inPlay = false
                    showToast(with: selectedWord)
                    Haptics.play(.loss)
                    SoundManager.shared.play(.error)
                }
            } else {
                withAnimation {
                    self.incorrectAttempts[tryIndex] += 1
                    self.guesses[tryIndex].invalidFlash = true
                }
                showToast(with: "Not in word list")
                Haptics.play(.invalid)
                SoundManager.shared.play(.error)
                incorrectAttempts[tryIndex] = 0
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
                    withAnimation(.easeOut(duration: 0.2)) {
                        self.guesses[self.tryIndex].invalidFlash = false
                    }
                }
            }
        }
    }
    
    func removeLetterFromCurrentWord() {
        guard !currentWord.isEmpty else { return }
        currentWord.removeLast()
        updateRow()
        Haptics.play(.keyTap)
        SoundManager.shared.play(.keyTap)
    }
    
    func updateRow() {
        let guessWord = currentWord.padding(toLength: 5, withPad: " ", startingAt: 0)
        guesses[tryIndex].word = guessWord
    }
    
    func verifyWord() -> Bool {
        WordDictionary.isAccepted(currentWord)
    }

    func useHint() {
        guard inPlay, !gameOver else { return }
        guard hintsUsed < 2 else {
            hintMessage = "You have used both hints for this round."
            showHint = true
            return
        }

        hintsUsed += 1
        if hintsUsed == 1 {
            hintMessage = WordDictionary.entry(for: selectedWord).clue
        } else {
            let answerLetters = Set(selectedWord.map { String($0) })
            let candidates = "ABCDEFGHIJKLMNOPQRSTUVWXYZ".map(String.init).filter {
                !answerLetters.contains($0) && !eliminatedHintLetters.contains($0) && keyColors[$0] == .unused
            }
            let eliminated = Array(candidates.prefix(3))
            eliminatedHintLetters.formUnion(eliminated)
            eliminated.forEach { keyColors[$0] = .wrong }
            hintMessage = eliminated.isEmpty
                ? "No more unused letters can be eliminated."
                : "These letters are not in the word: \(eliminated.joined(separator: ", "))"
        }
        Haptics.play(.keyTap)
        hintMessage += "\n−15 points"
        showHint = true
    }
    
    func hardCorrectCheck() -> String? {
        let guessLetters = guesses[tryIndex].guessLetters
        for i in 0...4 {
            if correctlyPlacedLetters[i] != "-" {
                if guessLetters[i] != correctlyPlacedLetters[i] {
                    let formatter = NumberFormatter()
                    formatter.numberStyle = .ordinal
                    return "\(formatter.string(for: i + 1)!) Letter must be `\(correctlyPlacedLetters[i])`."
                }
            }
        }
        return nil
    }
    
    func hardMisplacedCheck() -> String? {
        let guessLetters = guesses[tryIndex].guessLetters
        for letter in misplacedLetters {
            if !guessLetters.contains(letter) {
                return ("Must contain the letter `\(letter)`.")
            }
        }
        return nil
    }
    
    func setCurrentGuessColors() {
        let correctLetters = selectedWord.map { String($0) }
        var frequency = [String : Int]()
        for letter in correctLetters {
            frequency[letter, default: 0] += 1
        }
        for index in 0...4 {
            let correctLetter = correctLetters[index]
            let guessLetter = guesses[tryIndex].guessLetters[index]
            if guessLetter == correctLetter {
                guesses[tryIndex].bgColors[index] = .correct
                if !matchedLetters.contains(guessLetter) {
                    matchedLetters.append(guessLetter)
                    keyColors[guessLetter] = .correct
                }
                if misplacedLetters.contains(guessLetter) {
                    if let index = misplacedLetters.firstIndex(where: {$0 == guessLetter}) {
                        misplacedLetters.remove(at: index)
                    }
                }
                correctlyPlacedLetters[index] = correctLetter
                frequency[guessLetter]! -= 1
            }
        }
        
        for index in 0...4 {
            let guessLetter = guesses[tryIndex].guessLetters[index]
            if correctLetters.contains(guessLetter)
                && guesses[tryIndex].bgColors[index] != .correct
                && frequency[guessLetter]! > 0 {
                guesses[tryIndex].bgColors[index] = .misplaced
                if !misplacedLetters.contains(guessLetter) && !matchedLetters.contains(guessLetter) {
                    misplacedLetters.append(guessLetter)
                    keyColors[guessLetter] = .misplaced
                }
                frequency[guessLetter]! -= 1
            }
        }
        
        for index in 0...4 {
            let guessLetter = guesses[tryIndex].guessLetters[index]
            if keyColors[guessLetter] != .correct && keyColors[guessLetter] != .misplaced {
                keyColors[guessLetter] = .wrong
            }
        }
        
        flipCards(for: tryIndex)
    }
    
    func flipCards(for row: Int) {
        for col in 0...4 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(col) * 0.2) {
                self.guesses[row].cardFlipped[col].toggle()
            }
        }
    }
    
    func showToast(with text: String?) {
        withAnimation {
            toastText = text
        }
        withAnimation(Animation.linear(duration: 0.2).delay(3)) {
            toastText = nil
            if gameOver {
                withAnimation(Animation.linear(duration: 0.2).delay(3)) {
                    showStats.toggle()
                }
            }
        }
    }
    
    func shareResult() {
            let stat = Statistic.loadStat()
            let results = guesses.enumerated().compactMap { $0 }
            var guessString = ""
            for result in results {
                if result.0 <= tryIndex {
                    guessString += result.1.results + "\n"
                }
            }
            let resultString = """
    LexiGrid \(stat.games) \(tryIndex < 6 ? "\(tryIndex + 1)/6" : "X/6") • \(roundScore) pts\(hintsUsed > 0 ? " • \(hintsUsed) hint\(hintsUsed == 1 ? "" : "s")" : "")
    \(guessString)
    """
            print(resultString)
            let activityController = UIActivityViewController(activityItems: [resultString], applicationActivities: nil)
            switch UIDevice.current.userInterfaceIdiom {
            case .phone:
                UIWindow.key?.rootViewController!
                    .present(activityController, animated: true)
            case .pad:
                activityController.popoverPresentationController?.sourceView = UIWindow.key
                activityController.popoverPresentationController?.sourceRect = CGRect(x: Global.screenWidth / 2,
                                                                                      y: Global.screenHeight / 2,
                                                                                      width: 200,
                                                                                      height: 200)
                UIWindow.key?.rootViewController!.present(activityController, animated: true)
            default:
                break
            }
        }
}
