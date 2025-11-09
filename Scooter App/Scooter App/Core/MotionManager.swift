import Foundation
import CoreMotion
import Combine

final class MotionManager: ObservableObject {
    private let manager = CMMotionManager()
    private let queue = OperationQueue()

    // Gate so we can ignore updates when we don't want gyro (e.g., portrait)
    @Published var isEnabled: Bool = true

    @Published var roll: Double = 0   // radians

    func start() {
        guard manager.isDeviceMotionAvailable else { return }
        manager.deviceMotionUpdateInterval = 1.0 / 60.0
        manager.startDeviceMotionUpdates(to: queue) { [weak self] data, _ in
            guard let self, let data else { return }
            // If disabled, don't publish new values
            guard self.isEnabled else { return }
            let r = data.attitude.roll
            DispatchQueue.main.async {
                self.roll = r
            }
        }
    }

    func stop() {
        manager.stopDeviceMotionUpdates()
    }
}
