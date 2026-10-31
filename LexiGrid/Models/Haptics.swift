import UIKit

enum Haptics {
    enum Event { case keyTap, invalid, win, loss }

    static func play(_ event: Event) {
        guard UserDefaults.standard.object(forKey: "hapticsEnabled") as? Bool ?? true else { return }
        switch event {
        case .keyTap:
            UIImpactFeedbackGenerator(style: .light).impactOccurred(intensity: 0.55)
        case .invalid:
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        case .win:
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        case .loss:
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
        }
    }
}
