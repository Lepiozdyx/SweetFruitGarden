import Foundation

enum PlantCategory: String, Codable, CaseIterable {
    case tree = "Tree"
    case shrub = "Shrub"
    case vine = "Vine"
    case berry = "Berry"
    case vegetable = "Vegetable"
}

struct PlantDefinition: Identifiable, Codable, Hashable {
    let id: String
    let emoji: String
    let name: String
    let category: PlantCategory
    let plantingSeason: String
    let spacingText: String
    let spacingMetersMin: Double
    let harvestText: String
    let requirements: String
    let careTemplate: [String]
}

struct MyPlant: Identifiable, Codable, Hashable {
    let id: UUID
    let plantId: String
    var nickname: String
    var plantingDate: Date
    var note: String
    var photoData: Data?
    var createdAt: Date
}

enum GardenEventType: String, Codable {
    case planting
    case care
}

struct GardenEvent: Identifiable, Codable, Hashable {
    let id: UUID
    let plantInstanceId: UUID
    let plantId: String
    let type: GardenEventType
    var title: String
    var details: String
    var date: Date
    var isCompleted: Bool
}

enum ReminderTime: String, Codable, CaseIterable {
    case morning
    case evening

    var hour: Int { self == .morning ? 8 : 19 }
}

enum ReminderLeadDays: Int, Codable, CaseIterable {
    case one = 1
    case three = 3
    case seven = 7
}

struct NotificationSettingsModel: Codable, Hashable {
    var reminderTime: ReminderTime
    var remindBeforeDays: ReminderLeadDays
}

struct ReminderItem: Identifiable, Codable, Hashable {
    let id: UUID
    let eventId: UUID
    let plantInstanceId: UUID
    var title: String
    var eventDate: Date
    var remindAt: Date
    var isDone: Bool
}

extension PlantDefinition {
    static let fullLibrary: [PlantDefinition] = [
        .init(id: "apple", emoji: "🍎", name: "Apple Tree", category: .tree, plantingSeason: "Autumn (Sep-Oct)", spacingText: "3-4 m between trees", spacingMetersMin: 3.0, harvestText: "In 3-5 years", requirements: "Sun, loam, frost resistance up to -30C", careTemplate: ["Deep watering weekly", "Spring pruning", "Compost feeding each season"]),
        .init(id: "pear", emoji: "🍐", name: "Pear Tree", category: .tree, plantingSeason: "Spring (Apr-May)", spacingText: "3-5 m between trees", spacingMetersMin: 3.0, harvestText: "In 4-6 years", requirements: "Sun, drained soil", careTemplate: ["Moderate watering", "Crown shaping", "Support first years"]),
        .init(id: "cherry", emoji: "🍒", name: "Cherry Tree", category: .tree, plantingSeason: "Autumn (Sep)", spacingText: "3 m between trees", spacingMetersMin: 3.0, harvestText: "In 3-4 years", requirements: "Sun, neutral soil", careTemplate: ["Keep trunk circle clean", "Protect blossoms from late frost", "Regular pruning"]),
        .init(id: "peach", emoji: "🍑", name: "Peach Tree", category: .tree, plantingSeason: "Spring (Apr)", spacingText: "4 m between trees", spacingMetersMin: 4.0, harvestText: "In 3-4 years", requirements: "Warmth, wind protection", careTemplate: ["Frequent watering in heat", "Shelter from wind", "Fungus prevention spray"]),
        .init(id: "walnut", emoji: "🌰", name: "Walnut", category: .tree, plantingSeason: "Autumn (Oct)", spacingText: "8-10 m between trees", spacingMetersMin: 8.0, harvestText: "In 5-7 years", requirements: "Space, deep soil", careTemplate: ["Rare but deep watering", "No crowding nearby", "Forming cut in early years"]),
        .init(id: "raspberry", emoji: "🌿", name: "Raspberry", category: .shrub, plantingSeason: "Autumn (Sep)", spacingText: "0.5 m bushes, 1.5 m rows", spacingMetersMin: 0.5, harvestText: "Next year", requirements: "Partial shade, moist soil", careTemplate: ["Mulch roots", "Tie canes", "Cut old shoots after fruiting"]),
        .init(id: "currant", emoji: "🫐", name: "Currant", category: .shrub, plantingSeason: "Autumn (Sep-Oct)", spacingText: "1-1.5 m between bushes", spacingMetersMin: 1.0, harvestText: "In 2-3 years", requirements: "Sun/partial shade, loam", careTemplate: ["Moderate watering", "Sanitary pruning", "Organic feeding"]),
        .init(id: "grape", emoji: "🍇", name: "Grape", category: .vine, plantingSeason: "Spring (Apr-May)", spacingText: "1.5-2 m between bushes", spacingMetersMin: 1.5, harvestText: "In 3-4 years", requirements: "Sun, support, drainage", careTemplate: ["Tie to trellis", "Normalize clusters", "Seasonal vine pruning"]),
        .init(id: "blueberry", emoji: "🫐", name: "Blueberry", category: .shrub, plantingSeason: "Spring (Apr)", spacingText: "1-1.2 m between bushes", spacingMetersMin: 1.0, harvestText: "In 3-4 years", requirements: "Acidic peat soil", careTemplate: ["Keep acidic pH", "Constant moisture", "Mulch with bark"]),
        .init(id: "blackberry", emoji: "🌹", name: "Blackberry", category: .shrub, plantingSeason: "Autumn (Sep)", spacingText: "1 m between bushes, 2 m rows", spacingMetersMin: 1.0, harvestText: "In 2 years", requirements: "Sun, support", careTemplate: ["Tie shoots", "Winter cover in cold areas", "Prune fruiting stems"]),
        .init(id: "strawberry", emoji: "🍓", name: "Strawberry", category: .berry, plantingSeason: "Spring (Apr) or Autumn (Aug)", spacingText: "30 cm between plants", spacingMetersMin: 0.3, harvestText: "Next year", requirements: "Sun, loose soil", careTemplate: ["Regular watering", "Remove excess runners", "Renew bed every few years"]),
        .init(id: "gooseberry", emoji: "🫐", name: "Gooseberry", category: .shrub, plantingSeason: "Autumn (Sep)", spacingText: "1-1.5 m between bushes", spacingMetersMin: 1.0, harvestText: "In 2-3 years", requirements: "Sun, loam", careTemplate: ["Thin branches", "Moisture control", "Pest monitoring"]),
        .init(id: "carrot", emoji: "🥕", name: "Carrot", category: .vegetable, plantingSeason: "Spring (Apr-May)", spacingText: "5 cm between plants", spacingMetersMin: 0.05, harvestText: "In 3-4 months", requirements: "Loose soil, sun", careTemplate: ["Thin seedlings", "Keep even moisture", "Loosen crust after rain"]),
        .init(id: "tomato", emoji: "🍅", name: "Tomato", category: .vegetable, plantingSeason: "Spring (May, seedlings)", spacingText: "40-50 cm between plants", spacingMetersMin: 0.4, harvestText: "In 3-4 months", requirements: "Warmth, sun, support", careTemplate: ["Tie stems", "Pinch side shoots", "Regular feeding"]),
        .init(id: "cucumber", emoji: "🥒", name: "Cucumber", category: .vegetable, plantingSeason: "Spring (May)", spacingText: "30 cm between plants", spacingMetersMin: 0.3, harvestText: "In 2-3 months", requirements: "Warmth, humidity, support", careTemplate: ["Warm watering", "Trellis guidance", "Frequent harvest"]),
        .init(id: "potato", emoji: "🥔", name: "Potato", category: .vegetable, plantingSeason: "Spring (Apr-May)", spacingText: "30 cm tubers, 70 cm rows", spacingMetersMin: 0.3, harvestText: "In 3-4 months", requirements: "Loose soil, sun", careTemplate: ["Hilling", "Moderate watering", "Colorado beetle check"]),
        .init(id: "onion", emoji: "🧅", name: "Onion", category: .vegetable, plantingSeason: "Spring (Apr)", spacingText: "10 cm between bulbs", spacingMetersMin: 0.1, harvestText: "In 3-4 months", requirements: "Sun, drained soil", careTemplate: ["Keep rows weed-free", "Do not overwater", "Dry before storage"]),
        .init(id: "garlic", emoji: "🧄", name: "Garlic", category: .vegetable, plantingSeason: "Autumn (Oct) or Spring (Apr)", spacingText: "10 cm between cloves", spacingMetersMin: 0.1, harvestText: "In 3-4 months", requirements: "Sun, loam", careTemplate: ["Plant cloves point up", "Mulch for winter", "Stop watering before harvest"]),
        .init(id: "cabbage", emoji: "🥬", name: "Cabbage", category: .vegetable, plantingSeason: "Spring (May, seedlings)", spacingText: "40-50 cm between plants", spacingMetersMin: 0.4, harvestText: "In 3-4 months", requirements: "Moisture, sun", careTemplate: ["Even watering", "Pest net", "Soil loosening"]),
        .init(id: "pepper", emoji: "🌶️", name: "Pepper", category: .vegetable, plantingSeason: "Spring (May, seedlings)", spacingText: "30-40 cm between plants", spacingMetersMin: 0.3, harvestText: "In 3-4 months", requirements: "Warmth, sun, wind protection", careTemplate: ["Warm watering", "Stake support", "Regular feeding"])
    ]
}
