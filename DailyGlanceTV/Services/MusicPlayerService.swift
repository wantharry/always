import Foundation
import AVFoundation

@MainActor
final class MusicPlayerService: ObservableObject {
    @Published private(set) var isPlaying = false

    let stationName = "Groove Salad"
    let stationSource = "SomaFM"

    private var player: AVPlayer?

    init() {
        guard let url = URL(string: "https://ice1.somafm.com/groovesalad-128-mp3") else { return }
        let item = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: item)
        player?.automaticallyWaitsToMinimizeStalling = true
    }

    func start() {
        player?.play()
        isPlaying = true
    }

    func toggle() {
        guard let player else { return }
        if isPlaying {
            player.pause()
        } else {
            player.play()
        }
        isPlaying.toggle()
    }
}
