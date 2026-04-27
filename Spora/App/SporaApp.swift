import SwiftUI
import SwiftData
import UserNotifications

@main
struct SporaApp: App {
    init() {
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(for: UserSchedule.self)
    }
}
