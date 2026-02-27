import Foundation
import UserNotifications
import UIKit

final class PushNotificationService: NSObject {
    static let shared = PushNotificationService()

    private let notificationCenter = UNUserNotificationCenter.current()
    private let deviceTokenKey = "Token"

    private override init() {
        super.init()
        notificationCenter.delegate = self
    }

    func requestAuthorization() async -> Bool {
        do {
            let options: UNAuthorizationOptions = [.alert, .sound, .badge]
            let granted = try await notificationCenter.requestAuthorization(options: options)
            return granted
        } catch {
            print("Push notification authorization error: \(error)")
            return false
        }
    }

    func registerForRemoteNotifications() {
        DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
        }
    }

    func handleDeviceToken(_ token: Data) {
        let tokenString = token.map { String(format: "%02.2hhx", $0) }.joined()
        
        print("Device token received: \(tokenString)")
        
        UserDefaults.standard.set(tokenString, forKey: deviceTokenKey)
        
        NotificationCenter.default.post(
            name: .didReceiveDeviceToken,
            object: nil,
            userInfo: ["token": tokenString]
        )
    }

    func handleNotification(_ notification: [AnyHashable: Any]) {
        print("Handling notification: \(notification)")
        
        guard let aps = notification["aps"] as? [String: Any] else {
            return
        }

        if let alert = aps["alert"] as? String {
            print("Notification alert: \(alert)")
        }

        if let badge = aps["badge"] as? Int {
            DispatchQueue.main.async {
                UIApplication.shared.applicationIconBadgeNumber = badge
            }
        }

        if let sound = aps["sound"] as? String {
            print("Notification sound: \(sound)")
        }

        NotificationCenter.default.post(
            name: .didReceivePushNotification,
            object: nil,
            userInfo: notification
        )
    }

    func clearBadge() {
        DispatchQueue.main.async {
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
    }
}

extension PushNotificationService: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        handleNotification(notification.request.content.userInfo)
        return [.banner, .sound, .badge]
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        handleNotification(response.notification.request.content.userInfo)
    }
}

extension Notification.Name {
    static let didReceiveDeviceToken = Notification.Name("didReceiveDeviceToken")
    static let didReceivePushNotification = Notification.Name("didReceivePushNotification")
}
