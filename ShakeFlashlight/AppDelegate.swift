
import UIKit
import AVFoundation
import CoreMotion

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    private var motionManager: CMMotionManager?
    private var shakeCount = 0
    private var flashlightOn = false

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        let mainVC = ViewController()
        window?.rootViewController = mainVC
        window?.makeKeyAndVisible()
        setupMotionManager()
        return true
    }

    private func setupMotionManager() {
        motionManager = CMMotionManager()
        motionManager?.accelerometerUpdateInterval = 0.2

        if let motionManager = motionManager, motionManager.isAccelerometerAvailable {
            motionManager.startAccelerometerUpdates(to: .main) { [weak self] (data, error) in
                guard let self = self, let data = data, error == nil else { return }
                let acceleration = data.acceleration
                if abs(acceleration.x) > 1.5 || abs(acceleration.y) > 1.5 || abs(acceleration.z) > 1.5 {
                    self.shakeCount += 1
                    if self.shakeCount >= 2 {
                        self.toggleFlashlight()
                        self.shakeCount = 0
                    }
                }
            }
        }
    }

    private func toggleFlashlight() {
        guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else { return }
        do {
            try device.lockForConfiguration()
            flashlightOn.toggle()
            device.torchMode = flashlightOn ? .on : .off
            device.unlockForConfiguration()
        } catch {
            print("Error toggling flashlight: \(error)")
        }
    }
}
