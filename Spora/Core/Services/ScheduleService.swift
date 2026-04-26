import Foundation
import SwiftData

@MainActor
final class ScheduleService {
    private let context: ModelContext
    private let notifications: NotificationService
    private let catalog: CatalogService

    init(context: ModelContext, notifications: NotificationService = .shared, catalog: CatalogService = .shared) {
        self.context = context
        self.notifications = notifications
        self.catalog = catalog
    }

    func add(supplementId: String, times: [DateComponents], weekdays: [Int]) async throws {
        let schedule = UserSchedule(supplementId: supplementId, times: times, weekdays: weekdays)
        context.insert(schedule)
        try context.save()
        await syncNotifications(for: schedule)
    }

    func update(_ schedule: UserSchedule) async throws {
        try context.save()
        await syncNotifications(for: schedule)
    }

    func delete(_ schedule: UserSchedule) async throws {
        await notifications.cancel(scheduleId: schedule.id)
        context.delete(schedule)
        try context.save()
    }

    private func syncNotifications(for schedule: UserSchedule) async {
        guard let supplement = catalog.supplement(by: schedule.supplementId) else { return }
        await notifications.schedule(schedule, supplement: supplement)
    }
}
