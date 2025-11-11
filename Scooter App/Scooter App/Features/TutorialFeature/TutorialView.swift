import SwiftUI

private extension Double { var deg: Double { self * 180 / .pi } }

// Fixed-size, corner-anchored press area so hit zones never overlap
private struct PressArea<Content: View>: View {
    let size: CGSize
    let alignment: Alignment
    let onChange: (Bool) -> Void
    @ViewBuilder var content: () -> Content

    @GestureState private var isPressing = false

    var body: some View {
        content()
            .frame(width: size.width, height: size.height, alignment: .center)
            .contentShape(Rectangle())
            .background(Color.clear.contentShape(Rectangle()))
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: alignment)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .updating($isPressing) { _, state, _ in state = true }
                    .onEnded { _ in onChange(false) }
            )
            .simultaneousGesture(
                TapGesture()
                    .onEnded {
                        onChange(true)
                        DispatchQueue.main.async { onChange(false) }
                    }
            )
            .onChange(of: isPressing) { down in onChange(down) }
    }
}

struct TutorialView: View {
    @ObservedObject var viewModel: TutorialViewModel
    @StateObject private var motion = MotionManager()

    // pedal states
    @State private var brakePressed = false
    @State private var gasPressed = false

    // steer calibration/orientation
    @State private var steerZeroDeg: Double = 0
    @State private var steerSign: Double = 1

    // landscape tracking
    @State private var isLandscape: Bool = true

    private var isGasStep:   Bool { viewModel.current == .run   }
    private var isBrakeStep: Bool { viewModel.current == .brake }
    private var isSteerStep: Bool { viewModel.current == .steer }

    // Core: Use pitch in landscape, roll in portrait
    private func rawSteerDeg() -> Double {
        isLandscape ? motion.pitch * 180 / .pi : motion.roll * 180 / .pi
    }
    private func steeringDegrees(isLandscape: Bool) -> Double {
        guard isLandscape else { return 0 }
        let value = (rawSteerDeg() - steerZeroDeg) * steerSign
        return max(-35, min(35, value))
    }

    private struct DisabledLook: ViewModifier {
        let disabled: Bool
        func body(content: Content) -> some View {
            content
                .blur(radius: disabled ? 6 : 0)
                .opacity(disabled ? 0.35 : 1)
                .grayscale(disabled ? 1 : 0)
        }
    }
    private func disabledStyle(_ disabled: Bool) -> some ViewModifier { DisabledLook(disabled: disabled) }

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let isNowLandscape = w > h

            ZStack {
                // BACKGROUND
                Image("MapBackground")
                    .resizable()
                    .scaledToFill()
                    .overlay(Color.black.opacity(0.55))
                    .ignoresSafeArea()
                    .allowsHitTesting(false)

                // TITLES
                VStack(spacing: 8) {
                    Text(viewModel.headerTop)
                        .font(.title3.weight(.bold))
                        .foregroundStyle(.white.opacity(0.95))
                    let header = viewModel.headerMain
                    Text(header.text)
                        .font(.system(size: 44, weight: .heavy, design: .rounded))
                        .foregroundStyle(header.color)
                        .shadow(radius: 4)
                }
                .frame(maxHeight: .infinity, alignment: .top)
                .padding(.top, 24)
                .zIndex(3)
                .allowsHitTesting(false)

                // ---- Sizing (responsive, clamped) ----
                let base = min(w, h)
                let pedalW  = max(120, min(200, base * 0.18))
                let pedalH  = pedalW * 1.65
                let sidePad = max(28, w * 0.05)
                let ctaH: CGFloat = 56
                let bottomPad = max(12, geo.safeAreaInsets.bottom) + ctaH + 18

                // Hit zones slightly larger than visuals
                let hitW = pedalW + 40
                let hitH = pedalH + 40

                // STEERING (only on Steer + landscape)
                if isSteerStep, isLandscape {
                    let wheelW = max(260, min(380, base * 0.35))
                    let wheelH = max(150, min(230, base * 0.22))

                    TiltWheelView(steeringDegrees: steeringDegrees(isLandscape: isLandscape))
                        .frame(width: wheelW, height: wheelH)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                        .padding(.bottom, h * 0.16)
                        .allowsHitTesting(false)
                        .transition(.opacity.combined(with: .scale))
                        .zIndex(1)
                } else {
                    // placeholder in non-steer or portrait
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(.white.opacity(0.12), lineWidth: 2)
                        .frame(width: max(220, min(320, base * 0.28)),
                               height: max(120, min(180, base * 0.20)))
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                        .padding(.bottom, h * 0.16)
                        .allowsHitTesting(false)
                        .zIndex(1)
                }

                // BRAKE (LEFT)
                let brakeDisabled = !(isBrakeStep && isLandscape)
                PressArea(
                    size: CGSize(width: hitW, height: hitH),
                    alignment: .bottomLeading,
                    onChange: { down in if !brakeDisabled { brakePressed = down } }
                ) {
                    PedalView(side: .left, isPressed: brakeDisabled ? false : brakePressed)
                        .frame(width: pedalW, height: pedalH)
                        .modifier(disabledStyle(brakeDisabled))
                }
                .padding(.leading, sidePad)
                .padding(.bottom, bottomPad)
                .zIndex(4)

                // GAS (RIGHT)
                let gasDisabled = !(isGasStep && isLandscape)
                PressArea(
                    size: CGSize(width: hitW, height: hitH),
                    alignment: .bottomTrailing,
                    onChange: { down in if !gasDisabled { gasPressed = down } }
                ) {
                    PedalView(side: .right, isPressed: gasDisabled ? false : gasPressed)
                        .frame(width: pedalW, height: pedalH)
                        .modifier(disabledStyle(gasDisabled))
                }
                .padding(.trailing, sidePad)
                .padding(.bottom, bottomPad)
                .zIndex(4)

                // NEXT / START — centered bottom
                VStack {
                    Spacer()
                    Button {
                        viewModel.goNext()
                        applyGyroPolicy(isLandscape: isLandscape)
                    } label: {
                        Text(isSteerStep ? "Start" : "Next")
                            .font(.headline.weight(.bold))
                            .padding(.vertical, 12)
                            .frame(maxWidth: 420, minHeight: 56)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))
                            .overlay(RoundedRectangle(cornerRadius: 14)
                                .stroke(.white.opacity(0.4), lineWidth: 1))
                    }
                    .padding(.bottom, 8)
                }
                .zIndex(2)

                // SKIP — always on top
                VStack {
                    HStack {
                        if viewModel.showSkip {
                            Button(action: {
                                viewModel.skip()
                                applyGyroPolicy(isLandscape: isLandscape)
                            }) {
                                Text("Skip")
                                    .font(.footnote.weight(.semibold))
                                    .padding(.horizontal, 10).padding(.vertical, 6)
                                    .background(.ultraThinMaterial, in: Capsule())
                            }
                            .padding(.leading, 22).padding(.top, 10)
                        }
                        Spacer()
                    }
                    Spacer()
                }
                .zIndex(5)
            }
            // --- KEY PART: onAppear and onChange for orientation
            .onAppear {
                isLandscape = isNowLandscape
                applyGyroPolicy(isLandscape: isLandscape)
            }
            .onChange(of: isNowLandscape) { newLandscape in
                if newLandscape != isLandscape {
                    isLandscape = newLandscape
                    applyGyroPolicy(isLandscape: isLandscape)
                }
            }
        }
        .onDisappear { motion.stop(); motion.isEnabled = false }
    }

    private func applyGyroPolicy(isLandscape: Bool) {
        if isSteerStep && isLandscape {
            motion.isEnabled = true
            motion.start()
            // If your wheel turns the wrong way, set to -1 instead of +1
            steerSign = +1
            steerZeroDeg = rawSteerDeg()
        } else {
            motion.isEnabled = false
            motion.stop()
            steerZeroDeg = rawSteerDeg()
        }
    }
}
