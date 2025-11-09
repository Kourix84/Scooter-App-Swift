import Foundation
import Combine

@MainActor
final class GameState: ObservableObject {
    enum Flow { case start, tutorial, gameplay }
    @Published var flow: Flow = .start

    func startTutorial() { flow = .tutorial }
    func startGame()     { flow = .gameplay }
}
