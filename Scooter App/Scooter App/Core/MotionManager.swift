import Foundation
import CoreMotion
import Combine

final class MotionManager: ObservableObject {
    private let manager = CMMotionManager()
    private let queue = OperationQueue()

    @Published var isEnabled: Bool = true

    @Published var roll: Double = 0   // radians
    @Published var pitch: Double = 0  // radians

    func start() {
        guard manager.isDeviceMotionAvailable else { return }
        manager.deviceMotionUpdateInterval = 1.0 / 60.0
        manager.startDeviceMotionUpdates(to: queue) { [weak self] data, _ in
            guard let self, let data else { return }
            guard self.isEnabled else { return }
            let attitude = data.attitude
            DispatchQueue.main.async {
                self.roll = attitude.roll
                self.pitch = attitude.pitch
            }
        }
    }

    func stop() {
        manager.stopDeviceMotionUpdates()
    }
}
