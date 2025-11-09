import SwiftUI

@main
struct GameStarterApp: App {
    @StateObject private var gameState = GameState()

    var body: some Scene {
        WindowGroup {
            CompositionRoot()
                .environmentObject(gameState)
                .preferredColorScheme(.dark)
        }
    }
}
