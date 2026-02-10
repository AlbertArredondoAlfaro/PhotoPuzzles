import Foundation
import AVFoundation

final class SoundPlayer {
    static let shared = SoundPlayer()

    private var players: [String: AVAudioPlayer] = [:]

    private init() {}

    func playSound(named name: String, fileExtension: String) {
        let key = "\(name).\(fileExtension)"
        if let existing = players[key] {
            existing.currentTime = 0
            existing.play()
            return
        }

        guard let url = Bundle.main.url(forResource: name, withExtension: fileExtension) else { return }
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            players[key] = player
            player.play()
        } catch {
            return
        }
    }
}
