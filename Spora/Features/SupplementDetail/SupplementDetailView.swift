import SwiftUI

struct SupplementDetailView: View {
    let supplement: Supplement

    @State private var showEditor = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.l) {
                header
                section(title: "Описание", body: supplement.description)
                intakeSection
                if let contraindications = supplement.contraindications {
                    section(title: "Противопоказания", body: contraindications)
                }
                if let courseDays = supplement.courseDays {
                    section(title: "Длительность курса", body: "\(courseDays) дней")
                }
            }
            .padding(Spacing.m)
        }
        .background(Color.Spora.background.ignoresSafeArea())
        .navigationTitle(supplement.nameRu)
        .navigationBarTitleDisplayMode(.large)
        .safeAreaInset(edge: .bottom) {
            Button {
                showEditor = true
            } label: {
                Text("Добавить в мой режим")
                    .font(.Spora.title3)
                    .foregroundStyle(Color.Spora.primaryOn)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color.Spora.primary, in: Capsule())
            }
            .padding(Spacing.m)
            .background(Color.Spora.background)
        }
        .sheet(isPresented: $showEditor) {
            ScheduleEditorView(supplement: supplement)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(supplement.nameLat)
                .font(.Spora.caption)
                .foregroundStyle(Color.Spora.textSecondary)
                .italic()
        }
    }

    private var intakeSection: some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            Text("Приём")
                .font(.Spora.title3)
                .foregroundStyle(Color.Spora.textPrimary)
            HStack(spacing: Spacing.s) {
                tag("Дозировка: \(supplement.intake.dosage)")
                tag(supplement.intake.withFood ? "С едой" : "Натощак")
            }
        }
    }

    private func section(title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            Text(title)
                .font(.Spora.title3)
                .foregroundStyle(Color.Spora.textPrimary)
            Text(body)
                .font(.Spora.body)
                .foregroundStyle(Color.Spora.textPrimary)
        }
    }

    private func tag(_ text: String) -> some View {
        Text(text)
            .font(.Spora.caption)
            .foregroundStyle(Color.Spora.textPrimary)
            .padding(.horizontal, Spacing.m)
            .padding(.vertical, Spacing.s)
            .background(Color.Spora.secondary.opacity(0.2), in: Capsule())
    }
}
