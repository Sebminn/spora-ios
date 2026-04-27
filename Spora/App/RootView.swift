import SwiftUI

struct RootView: View {
    @AppStorage("onboardingCompleted") private var onboardingCompleted = false

    var body: some View {
        Group {
            if onboardingCompleted {
                MainTabView()
            } else {
                OnboardingView(onFinish: { onboardingCompleted = true })
            }
        }
        .tint(Color.Spora.primary)
    }
}

struct MainTabView: View {
    var body: some View {
        TabView {
            MySupplementsView()
                .tabItem { Label("Мои БАДы", image: "Mushroom") }

            CatalogView()
                .tabItem { Label("Каталог", systemImage: "books.vertical.fill") }
        }
        .toolbarBackground(Color.Spora.background, for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
    }
}
