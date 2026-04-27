import SwiftUI
import SwiftData

struct MySupplementsView: View {
    @Query(sort: \UserSchedule.createdAt, order: .reverse) private var schedules: [UserSchedule]
    @State private var showSettings = false

    private let catalog = CatalogService.shared

    var body: some View {
        NavigationStack {
            Group {
                if schedules.isEmpty {
                    emptyState
                } else {
                    list
                }
            }
            .background(Color.Spora.background.ignoresSafeArea())
            .navigationTitle("Мои БАДы")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showSettings = true } label: {
                        Image(systemName: "gearshape")
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: Spacing.m) {
            Image(systemName: "leaf")
                .font(.system(size: 56))
                .foregroundStyle(Color.Spora.secondary)
            Text("Пока ничего не добавлено")
                .font(.Spora.title3)
                .foregroundStyle(Color.Spora.textPrimary)
            Text("Откройте каталог и добавьте БАД в свой режим приёма.")
                .font(.Spora.body)
                .foregroundStyle(Color.Spora.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Spacing.l)
        }
    }

    private var list: some View {
        ScrollView {
            LazyVStack(spacing: Spacing.m) {
                ForEach(schedules) { schedule in
                    if let supplement = catalog.supplement(by: schedule.supplementId) {
                        ScheduleRow(supplement: supplement, schedule: schedule)
                    }
                }
            }
            .padding(.horizontal, Spacing.m)
            .padding(.top, Spacing.m)
        }
    }
}

private struct ScheduleRow: View {
    let supplement: Supplement
    let schedule: UserSchedule

    @Environment(\.modelContext) private var context
    @State private var showEditor = false

    var body: some View {
        HStack(spacing: Spacing.m) {
            Circle()
                .fill(Color.Spora.accent.opacity(0.2))
                .frame(width: 44, height: 44)
                .overlay(
                    Image(systemName: "leaf.fill")
                        .foregroundStyle(Color.Spora.accent)
                )
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(supplement.nameRu)
                    .font(.Spora.title3)
                    .foregroundStyle(Color.Spora.textPrimary)
                Text(timesString)
                    .font(.Spora.caption)
                    .foregroundStyle(Color.Spora.textSecondary)
            }
            Spacer()
            iconButton(systemName: "pencil", color: Color.Spora.primary) {
                showEditor = true
            }
            iconButton(systemName: "trash", color: Color.Spora.warning) {
                delete()
            }
        }
        .padding(Spacing.m)
        .background(Color.Spora.surface, in: RoundedRectangle(cornerRadius: Radius.card))
        .sheet(isPresented: $showEditor) {
            ScheduleEditorView(supplement: supplement, existing: schedule)
        }
    }

    private func iconButton(systemName: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(color)
                .frame(width: 32, height: 32)
                .background(color.opacity(0.12), in: Circle())
        }
        .buttonStyle(.plain)
    }

    private func delete() {
        let service = ScheduleService(context: context)
        Task { try? await service.delete(schedule) }
    }

    private var timesString: String {
        schedule.times
            .map { String(format: "%02d:%02d", $0.hour ?? 0, $0.minute ?? 0) }
            .joined(separator: " · ")
    }
}
