import SwiftUI

struct TiltWheelView: View {
    /// pass degrees already mapped/calibrated for landscape
    var steeringDegrees: Double

    var body: some View {
        GeometryReader { geo in
            let w = min(geo.size.width, 520)
            let h = min(geo.size.height, 240)

            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(.white.opacity(0.9), lineWidth: 3)
                    .background(RoundedRectangle(cornerRadius: 14).fill(.black.opacity(0.25)))
                    .frame(width: w, height: h)

                Image(systemName: "steeringwheel")
                    .font(.system(size: min(w, h) * 0.36))
                    .rotationEffect(.degrees(steeringDegrees))
                    .animation(.easeOut(duration: 0.08), value: steeringDegrees)
                    .foregroundStyle(.white)
            }
            .shadow(radius: 6)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
        .accessibilityLabel("Steering wheel")
    }
}
