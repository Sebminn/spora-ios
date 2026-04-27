import SwiftUI

struct OnboardingView: View {
    let onFinish: () -> Void

    @State private var page = 0

    private let pages: [OnboardingPage] = [
        .init(icon: "leaf.fill", title: "Spora", body: "Простое напоминание о приёме грибных БАДов."),
        .init(icon: "bell.badge.fill", title: "Не пропустите\nприём", body: "Уведомления приходят в удобное вам время."),
        .init(icon: "books.vertical.fill", title: "Знание\nпод рукой", body: "Каталог БАДов с инструкциями и противопоказаниями.")
    ]

    var body: some View {
        VStack {
            TabView(selection: $page) {
                ForEach(pages.indices, id: \.self) { index in
                    OnboardingPageView(page: pages[index])
                        .tag(index)
                }
            }
            .tabViewStyle(.page)
            .indexViewStyle(.page(backgroundDisplayMode: .always))

            Button(action: advance) {
                Text(page == pages.count - 1 ? "Начать" : "Дальше")
                    .font(.Spora.title3)
                    .foregroundStyle(Color.Spora.primaryOn)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color.Spora.primary, in: Capsule())
            }
            .padding(Spacing.m)
        }
        .background(Color.Spora.background.ignoresSafeArea())
    }

    private func advance() {
        if page < pages.count - 1 {
            withAnimation { page += 1 }
        } else {
            Task {
                _ = try? await NotificationService.shared.requestAuthorization()
                onFinish()
            }
        }
    }
}

private struct OnboardingPage {
    let icon: String
    let title: String
    let body: String
}

private struct OnboardingPageView: View {
    let page: OnboardingPage

    var body: some View {
        VStack(spacing: Spacing.l) {
            Image(systemName: page.icon)
                .font(.system(size: 80))
                .foregroundStyle(Color.Spora.accent)
            Text(page.title)
                .font(.Spora.brand)
                .foregroundStyle(Color.Spora.textPrimary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            Text(page.body)
                .font(.Spora.body)
                .foregroundStyle(Color.Spora.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Spacing.l)
        }
        .padding()
    }
}
