import SwiftUI

struct CatalogView: View {
    private let supplements = CatalogService.shared.supplements

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: Spacing.m) {
                    ForEach(supplements) { supplement in
                        NavigationLink(value: supplement) {
                            CatalogCard(supplement: supplement)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, Spacing.m)
                .padding(.top, Spacing.m)
            }
            .background(Color.Spora.background.ignoresSafeArea())
            .navigationTitle("Каталог")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.Spora.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .navigationDestination(for: Supplement.self) { supplement in
                SupplementDetailView(supplement: supplement)
            }
        }
    }
}

private struct CatalogCard: View {
    let supplement: Supplement

    var body: some View {
        HStack(spacing: Spacing.m) {
            RoundedRectangle(cornerRadius: Radius.input)
                .fill(Color.Spora.secondary.opacity(0.2))
                .frame(width: 64, height: 64)
                .overlay(
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(Color.Spora.secondary)
                )
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(supplement.nameRu)
                    .font(.Spora.title3)
                    .foregroundStyle(Color.Spora.textPrimary)
                Text(supplement.nameLat)
                    .font(.Spora.caption)
                    .foregroundStyle(Color.Spora.textSecondary)
                    .italic()
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundStyle(Color.Spora.textSecondary)
        }
        .padding(Spacing.m)
        .background(Color.Spora.surface, in: RoundedRectangle(cornerRadius: Radius.card))
    }
}
