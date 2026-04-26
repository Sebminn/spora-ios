import SwiftUI
import SwiftData

@main
struct SporaApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(for: UserSchedule.self)
    }
}
