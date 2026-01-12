import UIKit
import UserNotifications
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    private func registerForPushNotifications() {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            } else {
                print("Push permission denied: \(String(describing: error))")
            }
        }
    }

    // MARK: - Handle APNs token
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        let token = deviceToken.map { String(format: "%02x", $0) }.joined()
        print("APNs Device Token: \(token)")
        
        NotificationCenter.default.post(name: .apnsTokenUpdated, object: token)
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("Failed to register for APNs: \(error.localizedDescription)")
    }

    func application(
            _ application: UIApplication,
            didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
        ) -> Bool {
            registerForPushNotifications()
            //FirebaseApp.configure()
            UNUserNotificationCenter.current().delegate = self

            return true
        }

        // FCM received (foreground)
        func userNotificationCenter(
            _ center: UNUserNotificationCenter,
            willPresent notification: UNNotification,
            withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
        ) {
            handleFCMData(notification.request.content.userInfo)
            completionHandler([.banner, .sound])
        }

        // FCM received (background / tapped)
        func userNotificationCenter(
            _ center: UNUserNotificationCenter,
            didReceive response: UNNotificationResponse,
            withCompletionHandler completionHandler: @escaping () -> Void
        ) {
            handleFCMData(response.notification.request.content.userInfo)
            completionHandler()
        }
    
}

extension AppDelegate {

    private func handleFCMData(_ userInfo: [AnyHashable: Any]) {
        guard let type = userInfo["type"] as? String else { return }

        switch type {
        case "chat_message":
            NotificationCenter.default.post(
                name: .chatMessageReceived,
                object: nil,
                userInfo: userInfo
            )

        case "post_update":
            NotificationCenter.default.post(
                name: .postUpdated,
                object: nil,
                userInfo: userInfo
            )

        default:
            break
        }
    }
}

extension Notification.Name {
    static let chatMessageReceived = Notification.Name("chatMessageReceived")
    static let postUpdated = Notification.Name("postUpdated")
}
