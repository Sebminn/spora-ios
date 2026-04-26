import Foundation

final class CatalogService {
    static let shared = CatalogService()

    private(set) lazy var supplements: [Supplement] = load()

    func supplement(by id: String) -> Supplement? {
        supplements.first { $0.id == id }
    }

    private func load() -> [Supplement] {
        guard let url = Bundle.main.url(forResource: "catalog", withExtension: "json") else {
            assertionFailure("catalog.json not found in bundle")
            return []
        }
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode([Supplement].self, from: data)
        } catch {
            assertionFailure("Failed to decode catalog: \(error)")
            return []
        }
    }
}
