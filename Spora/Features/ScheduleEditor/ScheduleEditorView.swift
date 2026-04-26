import SwiftUI
import SwiftData

struct ScheduleEditorView: View {
    let supplement: Supplement

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var times: [Date] = [defaultMorning()]
    @State private var weekdays: Set<Int> = Set(1...7)

    var body: some View {
        NavigationStack {
            Form {
                Section("Время приёма") {
                    ForEach(times.indices, id: \.self) { index in
                        DatePicker("Приём \(index + 1)", selection: $times[index], displayedComponents: .hourAndMinute)
                    }
                    .onDelete { times.remove(atOffsets: $0) }
                    Button("Добавить время") {
                        times.append(Self.defaultMorning())
                    }
                }
                Section("Дни недели") {
                    WeekdayPicker(selection: $weekdays)
                }
            }
            .navigationTitle(supplement.nameRu)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Отмена") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Сохранить") { save() }
                        .disabled(times.isEmpty || weekdays.isEmpty)
                }
            }
        }
    }

    private func save() {
        let calendar = Calendar.current
        let components = times.map { calendar.dateComponents([.hour, .minute], from: $0) }
        let service = ScheduleService(context: context)
        Task {
            try? await service.add(
                supplementId: supplement.id,
                times: components,
                weekdays: Array(weekdays).sorted()
            )
            dismiss()
        }
    }

    private static func defaultMorning() -> Date {
        Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: .now) ?? .now
    }
}

private struct WeekdayPicker: View {
    @Binding var selection: Set<Int>

    private let labels = ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"]
    private let weekdays = [2, 3, 4, 5, 6, 7, 1]

    var body: some View {
        HStack(spacing: Spacing.s) {
            ForEach(Array(zip(weekdays, labels)), id: \.0) { weekday, label in
                let isSelected = selection.contains(weekday)
                Button {
                    if isSelected {
                        selection.remove(weekday)
                    } else {
                        selection.insert(weekday)
                    }
                } label: {
                    Text(label)
                        .font(.Spora.caption)
                        .frame(maxWidth: .infinity, minHeight: 36)
                        .background(
                            isSelected ? Color.Spora.primary : Color.Spora.surface,
                            in: Capsule()
                        )
                        .foregroundStyle(isSelected ? Color.Spora.primaryOn : Color.Spora.textPrimary)
                }
                .buttonStyle(.plain)
            }
        }
    }
}
