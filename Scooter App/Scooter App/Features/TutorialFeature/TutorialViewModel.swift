import SwiftUI
import Combine

@MainActor
final class TutorialViewModel: ObservableObject {
    @Published var current: TutorialStep = .run  // run = GAS
    @Published var showSkip: Bool = true

    private weak var gameState: GameState?

    init(gameState: GameState) { self.gameState = gameState }

    func skip()   { gameState?.startGame() }
    func finish() { gameState?.startGame() }

    func goNext() {
        if let next = TutorialStep(rawValue: current.rawValue + 1) {
            withAnimation(.spring()) { current = next }
        } else {
            finish()
        }
    }

    // Headers
    var headerTop: String {
        current == .steer ? "Tilt to" : "Hold To"
    }
    var headerMain: (text: String, color: Color) {
        switch current {
        case .run:   return ("Gas",   .green) // spotlight Gas first
        case .brake: return ("Brake", .red)
        case .steer: return ("Steer", .cyan)
        }
    }
}
