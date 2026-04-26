import Foundation
import UserNotifications

actor NotificationService {
    static let shared = NotificationService()

    private let center = UNUserNotificationCenter.current()

    func requestAuthorization() async throws -> Bool {
        try await center.requestAuthorization(options: [.alert, .sound, .badge])
    }

    func authorizationStatus() async -> UNAuthorizationStatus {
        await center.notificationSettings().authorizationStatus
    }

    func schedule(_ schedule: UserSchedule, supplement: Supplement) async {
        await cancel(scheduleId: schedule.id)
        guard schedule.isEnabled else { return }

        for weekday in schedule.weekdays {
            for time in schedule.times {
                let request = makeRequest(
                    scheduleId: schedule.id,
                    supplement: supplement,
                    weekday: weekday,
                    hour: time.hour ?? 0,
                    minute: time.minute ?? 0
                )
                try? await center.add(request)
            }
        }
    }

    func cancel(scheduleId: UUID) async {
        let pending = await center.pendingNotificationRequests()
        let prefix = "schedule-\(scheduleId.uuidString)"
        let ids = pending.map(\.identifier).filter { $0.hasPrefix(prefix) }
        center.removePendingNotificationRequests(withIdentifiers: ids)
    }

    private func makeRequest(
        scheduleId: UUID,
        supplement: Supplement,
        weekday: Int,
        hour: Int,
        minute: Int
    ) -> UNNotificationRequest {
        let content = UNMutableNotificationContent()
        content.title = "Время \(supplement.nameRu)"
        content.body = supplement.intake.withFood ? "С едой" : "Натощак"
        content.sound = .default
        content.userInfo = ["supplementId": supplement.id]

        var components = DateComponents()
        components.weekday = weekday
        components.hour = hour
        components.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let identifier = "schedule-\(scheduleId.uuidString)-\(weekday)-\(String(format: "%02d%02d", hour, minute))"

        return UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
    }
}
