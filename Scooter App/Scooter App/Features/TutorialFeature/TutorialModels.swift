import SwiftUI

enum TutorialStep: Int, CaseIterable, Identifiable {
    case run, brake, steer
    var id: Int { rawValue }
}
