import SwiftUI

struct StartScreen: View {
    @EnvironmentObject private var gameState: GameState
    @State private var pulse = false

    var body: some View {
        ZStack {
            Image("MapBackground")
                .resizable()
                .scaledToFill()
                .overlay(Color.black.opacity(0.6))
                .ignoresSafeArea()

            VStack(spacing: 16) {
                Text("Scooter Vroom Vroom")
                    .font(.system(size: 40, weight: .black, design: .rounded))
                    .shadow(radius: 5)

                Text("Press anywhere to start")
                    .font(.headline)
                    .opacity(pulse ? 1 : 0.35)
                    .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: pulse)

                Button {
                    gameState.startTutorial()
                } label: {
                    Text("Start")
                        .font(.title3.weight(.bold))
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(.ultraThinMaterial, in: Capsule())
                }
                .padding(.top, 8)
            }
            .foregroundStyle(.white)
            .onAppear { pulse = true }
        }
        .contentShape(Rectangle())
        .onTapGesture { gameState.startTutorial() } // press anywhere
    }
}
