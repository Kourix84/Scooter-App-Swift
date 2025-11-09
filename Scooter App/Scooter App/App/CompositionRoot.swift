import SwiftUI

struct CompositionRoot: View {
    @EnvironmentObject private var gameState: GameState

    var body: some View {
        LandscapeGate {
            switch gameState.flow {
            case .start:
                StartScreen()
            case .tutorial:
                TutorialView(viewModel: TutorialViewModel(gameState: gameState))
            case .gameplay:
                Text("Gameplay goes here")
                    .font(.largeTitle.bold())
            }
        }
    }
}
