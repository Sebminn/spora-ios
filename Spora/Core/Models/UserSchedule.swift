import Foundation
import SwiftData

@Model
final class UserSchedule {
    @Attribute(.unique) var id: UUID
    var supplementId: String
    var timesData: Data
    var weekdays: [Int]
    var isEnabled: Bool
    var createdAt: Date

    init(
        id: UUID = UUID(),
        supplementId: String,
        times: [DateComponents],
        weekdays: [Int] = [1, 2, 3, 4, 5, 6, 7],
        isEnabled: Bool = true,
        createdAt: Date = .now
    ) {
        self.id = id
        self.supplementId = supplementId
        self.timesData = (try? JSONEncoder().encode(times.map { TimeOfDay(from: $0) })) ?? Data()
        self.weekdays = weekdays
        self.isEnabled = isEnabled
        self.createdAt = createdAt
    }

    var times: [DateComponents] {
        get {
            guard let stored = try? JSONDecoder().decode([TimeOfDay].self, from: timesData) else { return [] }
            return stored.map(\.dateComponents)
        }
        set {
            timesData = (try? JSONEncoder().encode(newValue.map { TimeOfDay(from: $0) })) ?? Data()
        }
    }
}

private struct TimeOfDay: Codable {
    var hour: Int
    var minute: Int

    init(from components: DateComponents) {
        self.hour = components.hour ?? 0
        self.minute = components.minute ?? 0
    }

    var dateComponents: DateComponents {
        DateComponents(hour: hour, minute: minute)
    }
}
