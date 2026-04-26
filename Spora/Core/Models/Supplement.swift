import Foundation

struct Supplement: Codable, Identifiable, Hashable {
    let id: String
    let nameRu: String
    let nameLat: String
    let imageAsset: String
    let description: String
    let intake: IntakeRecommendation
    let contraindications: String?
    let courseDays: Int?
}

struct IntakeRecommendation: Codable, Hashable {
    let dosage: String
    let withFood: Bool
    let preferredTime: [PreferredTime]
}

enum PreferredTime: String, Codable, Hashable {
    case morning, day, evening, night
}
