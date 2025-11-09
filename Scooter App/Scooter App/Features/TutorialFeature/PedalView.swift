import SwiftUI

struct PedalView: View {
    enum Side { case left, right }
    var side: Side
    var isPressed: Bool

    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .strokeBorder(.white.opacity(0.85), lineWidth: 3)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isPressed ? .white.opacity(0.25) : .black.opacity(0.25))
            )
            .overlay(
                VStack(spacing: 4) { // ribs
                    ForEach(0..<12, id: \.self) { _ in
                        Capsule().fill(.white.opacity(0.35)).frame(height: 2)
                    }
                }
                .padding(10)
            )
            .shadow(radius: 6)
            .accessibilityLabel(side == .left ? "Brake pedal" : "Gas pedal")
    }
}
