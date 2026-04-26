import SwiftUI

struct SettingsView: View {
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Уведомления") {
                    Toggle("Включить уведомления", isOn: $notificationsEnabled)
                }
                Section("Конфиденциальность") {
                    Link("Политика конфиденциальности", destination: URL(string: "https://example.com/spora-privacy")!)
                }
                Section("О приложении") {
                    LabeledContent("Версия", value: Bundle.main.appVersion)
                    Text("Дизайн на основе MediMinder UI Kit by Sana Nassani (CC BY 4.0).")
                        .font(.Spora.caption)
                        .foregroundStyle(Color.Spora.textSecondary)
                }
            }
            .navigationTitle("Настройки")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Готово") { dismiss() }
                }
            }
        }
    }
}

private extension Bundle {
    var appVersion: String {
        let version = infoDictionary?["CFBundleShortVersionString"] as? String ?? "—"
        let build = infoDictionary?["CFBundleVersion"] as? String ?? ""
        return build.isEmpty ? version : "\(version) (\(build))"
    }
}
