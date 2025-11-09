import SwiftUI

struct LandscapeGate<Content: View>: View {
    @ViewBuilder var content: () -> Content

    var body: some View {
        GeometryReader { geo in
            let isLandscape = geo.size.width > geo.size.height
            ZStack {
                if isLandscape {
                    content()
                } else {
                    Color.black.ignoresSafeArea()
                    VStack(spacing: 14) {
                        Image(systemName: "ipad.landscape")
                            .font(.system(size: 48))
                        Text("Rotate iPad to landscape")
                            .font(.headline)
                    }
                    .foregroundStyle(.white.opacity(0.95))
                }
            }
            .animation(.easeInOut(duration: 0.25), value: isLandscape)
        }
    }
}
