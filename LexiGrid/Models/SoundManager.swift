import AVFoundation

final class SoundManager: NSObject, AVAudioPlayerDelegate {
    static let shared = SoundManager()

    enum Event { case keyTap, submit, win, error }

    private var activePlayers: [AVAudioPlayer] = []

    private override init() {
        super.init()
        try? AVAudioSession.sharedInstance().setCategory(.ambient, options: [.mixWithOthers])
    }

    func play(_ event: Event) {
        guard UserDefaults.standard.object(forKey: "soundEnabled") as? Bool ?? true else { return }
        let fileName: String
        switch event {
        case .keyTap: fileName = "tile"
        case .submit: fileName = "submit"
        case .win: fileName = "win"
        case .error: fileName = "error"
        }

        DispatchQueue.main.async { [weak self] in
            guard let self = self,
                  let url = Bundle.main.url(forResource: fileName, withExtension: "wav"),
                  let player = try? AVAudioPlayer(contentsOf: url) else { return }
            player.delegate = self
            player.volume = 0.72
            player.prepareToPlay()
            self.activePlayers.append(player)
            player.play()
        }
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        activePlayers.removeAll { $0 === player }
    }
}
