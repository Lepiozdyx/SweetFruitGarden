import Foundation
import UserNotifications
import UIKit

@MainActor
final class GardenStore: ObservableObject {
    @Published private(set) var plantLibrary: [PlantDefinition] = PlantDefinition.fullLibrary
    @Published var myPlants: [MyPlant] = []
    @Published var events: [GardenEvent] = []
    @Published var reminders: [ReminderItem] = []
    @Published var settings = NotificationSettingsModel(reminderTime: .morning, remindBeforeDays: .three)
    @Published var notificationPermissionRequested = false

    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    private enum Key {
        static let myPlants = "garden_my_plants_v1"
        static let events = "garden_events_v1"
        static let reminders = "garden_reminders_v1"
        static let settings = "garden_notification_settings_v1"
        static let permissionAsked = "garden_notification_permission_asked_v1"
    }

    init() {
        load()
    }

    func requestNotificationPermissionIfNeeded() async {
        guard !notificationPermissionRequested else { return }
        notificationPermissionRequested = true
        UserDefaults.standard.set(true, forKey: Key.permissionAsked)
        let center = UNUserNotificationCenter.current()
        _ = try? await center.requestAuthorization(options: [.alert, .badge, .sound])
        rescheduleLocalNotifications()
    }

    func filteredPlants(query: String, category: PlantCategory?) -> [PlantDefinition] {
        plantLibrary.filter { plant in
            let queryOK = query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                plant.name.localizedCaseInsensitiveContains(query) ||
                plant.emoji.localizedCaseInsensitiveContains(query)
            let categoryOK = category == nil || plant.category == category
            return queryOK && categoryOK
        }
    }

    func definition(by id: String) -> PlantDefinition? {
        plantLibrary.first { $0.id == id }
    }

    func addMyPlant(plantId: String, nickname: String, plannedDate: Date?, note: String, photoData: Data?) {
        guard let definition = definition(by: plantId) else { return }
        let date = plannedDate ?? Date()
        let trimmedNickname = nickname.trimmingCharacters(in: .whitespacesAndNewlines)
        let compressedPhotoData = photoData.flatMap { compressPhotoData($0) }
        let instance = MyPlant(
            id: UUID(),
            plantId: plantId,
            nickname: trimmedNickname,
            plantingDate: date,
            note: note,
            photoData: compressedPhotoData,
            createdAt: Date()
        )
        myPlants.append(instance)
        if plannedDate != nil {
            buildEvents(for: instance, definition: definition)
            rebuildReminders()
        }
        persist()
    }

    func markReminderDone(_ reminderId: UUID) {
        guard let idx = reminders.firstIndex(where: { $0.id == reminderId }) else { return }
        reminders[idx].isDone = true
        if let eventIdx = events.firstIndex(where: { $0.id == reminders[idx].eventId }) {
            events[eventIdx].isCompleted = true
        }
        persist()
        rescheduleLocalNotifications()
    }

    func skipReminder(_ reminderId: UUID) {
        guard let reminder = reminders.first(where: { $0.id == reminderId }) else { return }
        reminders.removeAll { $0.id == reminderId }
        events.removeAll { $0.id == reminder.eventId }
        persist()
        rescheduleLocalNotifications()
    }

    func snoozeReminder(_ reminderId: UUID) {
        guard let idx = reminders.firstIndex(where: { $0.id == reminderId }) else { return }
        let days = settings.remindBeforeDays.rawValue
        reminders[idx].remindAt = Calendar.current.date(byAdding: .day, value: days, to: Date()) ?? Date()
        persist()
        rescheduleLocalNotifications()
    }

    func updateReminderTime(_ time: ReminderTime) {
        settings.reminderTime = time
        rebuildReminders()
        persist()
    }

    func updateLeadDays(_ lead: ReminderLeadDays) {
        settings.remindBeforeDays = lead
        rebuildReminders()
        persist()
    }

    func triggerTestNotification() {
        Task {
            let center = UNUserNotificationCenter.current()
            let granted = try? await center.requestAuthorization(options: [.alert, .badge, .sound])
            guard granted == true else { return }
            let content = UNMutableNotificationContent()
            content.title = "Sweet Fruit Garden"
            content.body = "Test reminder: Time to plant your garden!"
            content.sound = .default
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
            let req = UNNotificationRequest(identifier: "garden-test-\(UUID().uuidString)", content: content, trigger: trigger)
            try? await center.add(req)
        }
    }

    func events(on date: Date) -> [GardenEvent] {
        events.filter { Calendar.current.isDate($0.date, inSameDayAs: date) }
            .sorted { $0.date < $1.date }
    }

    var upcomingEvents: [GardenEvent] {
        let start = Calendar.current.startOfDay(for: Date())
        return events
            .filter { !$0.isCompleted && $0.date >= start }
            .sorted { $0.date < $1.date }
    }

    var completedEvents: [GardenEvent] {
        events.filter { $0.isCompleted }.sorted { $0.date > $1.date }
    }

    var activeReminders: [ReminderItem] {
        reminders
            .filter { !$0.isDone && $0.remindAt >= Date() }
            .sorted { $0.remindAt < $1.remindAt }
    }

    var completedReminders: [ReminderItem] {
        reminders.filter { $0.isDone }.sorted { $0.remindAt > $1.remindAt }
    }

    private func buildEvents(for instance: MyPlant, definition: PlantDefinition) {
        let planting = GardenEvent(
            id: UUID(),
            plantInstanceId: instance.id,
            plantId: definition.id,
            type: .planting,
            title: "Plant \(definition.name)",
            details: "Planting season: \(definition.plantingSeason). Spacing: \(definition.spacingText)",
            date: applyReminderHour(to: instance.plantingDate),
            isCompleted: false
        )
        events.append(planting)

        for (index, tip) in definition.careTemplate.enumerated() {
            let careDate = Calendar.current.date(byAdding: .day, value: 14 * (index + 1), to: instance.plantingDate) ?? instance.plantingDate
            events.append(
                GardenEvent(
                    id: UUID(),
                    plantInstanceId: instance.id,
                    plantId: definition.id,
                    type: .care,
                    title: "Care: \(definition.name)",
                    details: tip,
                    date: applyReminderHour(to: careDate),
                    isCompleted: false
                )
            )
        }
    }

    private func rebuildReminders() {
        reminders = events.map { event in
            let remindAt = Calendar.current.date(byAdding: .day, value: -settings.remindBeforeDays.rawValue, to: applyReminderHour(to: event.date)) ?? event.date
            return ReminderItem(
                id: UUID(),
                eventId: event.id,
                plantInstanceId: event.plantInstanceId,
                title: event.type == .planting ? "Time to \(event.title.lowercased())!" : event.title,
                eventDate: event.date,
                remindAt: remindAt,
                isDone: event.isCompleted
            )
        }
        rescheduleLocalNotifications()
    }

    private func seasonalDate(for definition: PlantDefinition) -> Date {
        let cal = Calendar.current
        let now = Date()
        let year = cal.component(.year, from: now)
        func make(_ month: Int, _ day: Int) -> Date {
            var c = DateComponents()
            c.year = year
            c.month = month
            c.day = day
            c.hour = settings.reminderTime.hour
            c.minute = 0
            return cal.date(from: c) ?? now
        }
        let season = definition.plantingSeason.lowercased()
        if season.contains("sep") || season.contains("oct") || season.contains("autumn") { return make(9, 15) }
        if season.contains("aug") { return make(8, 20) }
        if season.contains("may") { return make(5, 10) }
        if season.contains("apr") || season.contains("spring") { return make(4, 15) }
        return applyReminderHour(to: now)
    }

    private func applyReminderHour(to date: Date) -> Date {
        var comps = Calendar.current.dateComponents([.year, .month, .day], from: date)
        comps.hour = settings.reminderTime.hour
        comps.minute = 0
        return Calendar.current.date(from: comps) ?? date
    }

    private func rescheduleLocalNotifications() {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: reminders.map { "garden-\($0.id.uuidString)" })
        for item in activeReminders {
            if item.remindAt <= Date() { continue }
            let content = UNMutableNotificationContent()
            content.title = "Sweet Fruit Garden"
            content.body = item.title
            content.sound = .default
            let comps = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: item.remindAt)
            let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
            let req = UNNotificationRequest(identifier: "garden-\(item.id.uuidString)", content: content, trigger: trigger)
            center.add(req)
        }
    }

    private func load() {
        let defaults = UserDefaults.standard
        if let data = defaults.data(forKey: Key.myPlants),
           let value = try? decoder.decode([MyPlant].self, from: data) {
            let validPlantIds = Set(PlantDefinition.fullLibrary.map(\.id))
            myPlants = value
                .filter { validPlantIds.contains($0.plantId) }
                .map { plant in
                    var updated = plant
                    if let data = updated.photoData {
                        updated.photoData = compressPhotoData(data)
                    }
                    return updated
                }
        }
        if let data = defaults.data(forKey: Key.events),
           let value = try? decoder.decode([GardenEvent].self, from: data) {
            events = value
        }
        if let data = defaults.data(forKey: Key.reminders),
           let value = try? decoder.decode([ReminderItem].self, from: data) {
            reminders = value
        }
        if let data = defaults.data(forKey: Key.settings),
           let value = try? decoder.decode(NotificationSettingsModel.self, from: data) {
            settings = value
        }
        let activePlantInstanceIds = Set(myPlants.map(\.id))
        let activePlantIds = Set(myPlants.map(\.plantId))
        events = events.filter { activePlantInstanceIds.contains($0.plantInstanceId) && activePlantIds.contains($0.plantId) }
        let autoDatePlantInstanceIds = Set(
            myPlants.compactMap { plant -> UUID? in
                guard let def = definition(by: plant.plantId) else { return nil }
                let seasonal = seasonalDate(for: def)
                return Calendar.current.isDate(plant.plantingDate, inSameDayAs: seasonal) ? plant.id : nil
            }
        )
        if !autoDatePlantInstanceIds.isEmpty {
            events.removeAll { autoDatePlantInstanceIds.contains($0.plantInstanceId) }
        }
        let activeEventIds = Set(events.map(\.id))
        reminders = reminders.filter { activePlantInstanceIds.contains($0.plantInstanceId) && activeEventIds.contains($0.eventId) }
        notificationPermissionRequested = defaults.bool(forKey: Key.permissionAsked)
        persist()
    }

    private func persist() {
        let defaults = UserDefaults.standard
        if let data = try? encoder.encode(myPlants) { defaults.set(data, forKey: Key.myPlants) }
        if let data = try? encoder.encode(events) { defaults.set(data, forKey: Key.events) }
        if let data = try? encoder.encode(reminders) { defaults.set(data, forKey: Key.reminders) }
        if let data = try? encoder.encode(settings) { defaults.set(data, forKey: Key.settings) }
    }

    private func compressPhotoData(_ data: Data) -> Data? {
        guard let image = UIImage(data: data) else { return data }

        let maxSide: CGFloat = 1280
        let sourceSize = image.size
        let scale = min(1, maxSide / max(sourceSize.width, sourceSize.height))
        let targetSize = CGSize(width: max(1, sourceSize.width * scale), height: max(1, sourceSize.height * scale))

        let processedImage: UIImage = {
            guard scale < 1 else { return image }
            let format = UIGraphicsImageRendererFormat.default()
            format.scale = 1
            return UIGraphicsImageRenderer(size: targetSize, format: format).image { _ in
                image.draw(in: CGRect(origin: .zero, size: targetSize))
            }
        }()

        if let jpeg = processedImage.jpegData(compressionQuality: 0.6) {
            return jpeg
        }
        return processedImage.pngData() ?? data
    }
}
