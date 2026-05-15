import SwiftUI

struct GardenCalendarScreen: View {
    @EnvironmentObject private var store: GardenStore
    @State private var selectedDate: Date? = nil
    @State private var visibleMonth: Date = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Date())) ?? Date()

    var body: some View {
        ZStack(alignment: .top) {
            RadialGradient(
                colors: [Color.hex("2D1060"), Color.hex("1A0A2E"), Color.hex("0D0518")],
                center: .top,
                startRadius: 20,
                endRadius: 900
            )

            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    Color.clear.frame(height: 68)
                    calendarCard
                    markersRow
                    upcomingTitle
                    eventsList
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 92)
            }

            headerBar
        }
    }

    private var headerBar: some View {
        HStack {
            Text("Garden Calendar")
                .font(.custom("Fredoka One", size: 20))
                .foregroundStyle(.white)
            Spacer()
        }
        .padding(.horizontal, 20)
        .frame(height: 56)
        .background(LinearGradient(colors: [Color.hex("2D1B4E"), Color.hex("241540")], startPoint: .top, endPoint: .bottom))
        .overlay(alignment: .bottom) {
            Rectangle().fill(Color.white.opacity(0.08)).frame(height: 1)
        }
    }

    private var calendarCard: some View {
        VStack(spacing: 10) {
            HStack {
                Button {
                    visibleMonth = Calendar.current.date(byAdding: .month, value: -1, to: visibleMonth) ?? visibleMonth
                } label: {
                    calendarArrow(left: true)
                }
                Spacer()
                Text(monthTitle(visibleMonth))
                    .font(.custom("Fredoka One", size: 18))
                    .foregroundStyle(.white)
                Spacer()
                Button {
                    visibleMonth = Calendar.current.date(byAdding: .month, value: 1, to: visibleMonth) ?? visibleMonth
                } label: {
                    calendarArrow(left: false)
                }
            }
            .frame(height: 30)

            HStack(spacing: 0) {
                ForEach(["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"], id: \.self) { d in
                    Text(d)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(Color.white.opacity(0.45))
                        .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 24.5)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 7), spacing: 4) {
                ForEach(0..<calendarCells.count, id: \.self) { idx in
                    if let day = calendarCells[idx] {
                        dayCell(day)
                    } else {
                        Color.clear
                            .frame(height: 40.58)
                    }
                }
            }
        }
        .padding(.horizontal, 17)
        .padding(.top, 17.5)
        .padding(.bottom, 16)
        .frame(height: 372)
        .background(Color.white.opacity(0.05))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.4), radius: 10, y: 6)
    }

    private func calendarArrow(left: Bool) -> some View {
        Image(systemName: left ? "chevron.left" : "chevron.right")
            .font(.system(size: 12, weight: .bold))
            .foregroundStyle(Color.hex("FFD700"))
            .frame(width: 30, height: 30)
    }

    private func dayCell(_ day: Int) -> some View {
        guard let date = dateForDay(day) else { return AnyView(Color.clear) }
        let hasEvent = !store.events(on: date).isEmpty
        let isToday = Calendar.current.isDateInToday(date)
        let isSelected = selectedDate.map { Calendar.current.isDate($0, inSameDayAs: date) } ?? false
        let todayStart = Calendar.current.startOfDay(for: Date())
        let dateStart = Calendar.current.startOfDay(for: date)
        let isPast = dateStart < todayStart
        return AnyView(
            ZStack {
                if isSelected {
                    Circle()
                        .fill(Color.hex("FFD700"))
                        .frame(width: 40.58, height: 40.58)
                }
                if isToday {
                    Circle()
                        .stroke(Color.hex("FF6B35"), lineWidth: 1.5)
                        .frame(width: 40.58, height: 40.58)
                }
                VStack(spacing: 2) {
                    Text("\(day)")
                        .font(.system(size: 13, weight: (isToday || isSelected) ? .bold : .regular))
                        .foregroundStyle(
                            isSelected
                                ? Color.black.opacity(0.8)
                                : (isToday ? Color.hex("FF6B35") : Color.white.opacity(isPast ? 0.35 : 0.8))
                        )
                    Circle()
                        .fill(hasEvent ? Color.hex("76FF03") : .clear)
                        .frame(width: 5, height: 5)
                        .shadow(color: hasEvent ? Color.hex("76FF03").opacity(0.6) : .clear, radius: 4)
                }
            }
            .frame(height: 40.58)
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
            .onTapGesture {
                ClickSound.play()
                selectedDate = date
            }
        )
    }

    private var calendarCells: [Int?] {
        let calendar = Calendar.current
        guard let range = calendar.range(of: .day, in: .month, for: visibleMonth),
              let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: visibleMonth)) else {
            return []
        }
        let leadingEmpty = calendar.component(.weekday, from: firstDay) - 1
        let days = Array(range).map { Optional($0) }
        let base = Array(repeating: Optional<Int>.none, count: leadingEmpty) + days
        let remainder = base.count % 7
        var padded = remainder == 0 ? base : base + Array(repeating: Optional<Int>.none, count: 7 - remainder)
        if padded.count < 42 {
            padded += Array(repeating: Optional<Int>.none, count: 42 - padded.count)
        }
        return padded
    }

    private var markersRow: some View {
        HStack(spacing: 16) {
            HStack(spacing: 6) {
                Circle()
                    .fill(Color.hex("76FF03"))
                    .frame(width: 8, height: 8)
                    .shadow(color: Color.hex("76FF03").opacity(0.6), radius: 6)
                Text("Garden events")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.white.opacity(0.55))
            }
            HStack(spacing: 6) {
                Circle()
                    .stroke(Color.hex("FF6B35"), lineWidth: 1.5)
                    .frame(width: 14, height: 14)
                Text("Today")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.white.opacity(0.55))
            }
            Spacer()
        }
        .frame(height: 18)
    }

    private var upcomingTitle: some View {
        HStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.hex("FFD700"))
                .frame(width: 3, height: 16)
            Text(selectedDate == nil ? "All Upcoming Events" : "Events: \(formattedDate(selectedDate!))")
                .font(.custom("Fredoka One", size: 17))
                .foregroundStyle(.white)
            Spacer()
        }
    }

    private var eventsList: some View {
        let list = selectedDate == nil ? store.upcomingEvents : store.events(on: selectedDate!)
        return VStack(spacing: 10) {
            if list.isEmpty {
                VStack(spacing: 8) {
                    Text("📅").font(.system(size: 30))
                    Text("No events for this day")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.white.opacity(0.82))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 120)
                .background(LinearGradient(colors: [Color.hex("3D2468"), Color.hex("2D1B4E")], startPoint: .topLeading, endPoint: .bottomTrailing))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.15), lineWidth: 1))
                .clipShape(RoundedRectangle(cornerRadius: 16))
            } else {
                ForEach(list) { event in
                HStack(spacing: 10) {
                    Text(store.definition(by: event.plantId)?.emoji ?? "🌱")
                        .font(.system(size: 24))
                        .frame(width: 24, height: 24)
                    VStack(alignment: .leading, spacing: 0) {
                        Text(event.title)
                            .font(.custom("Fredoka One", size: 15))
                            .foregroundStyle(.white)
                        Text(formattedDateTime(event.date))
                            .font(.system(size: 12))
                            .foregroundStyle(Color.hex("FFE066"))
                    }
                    Spacer()
                    Circle()
                        .fill(Color.hex("76FF03"))
                        .frame(width: 8, height: 8)
                        .shadow(color: Color.hex("76FF03").opacity(0.6), radius: 6)
                }
                .padding(.horizontal, 16)
                .frame(height: 71.5)
                .background(LinearGradient(colors: [Color.hex("3D2468"), Color.hex("2D1B4E")], startPoint: .topLeading, endPoint: .bottomTrailing))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.3), radius: 8, y: 4)
            }
            }
        }
    }

    private func dateForDay(_ day: Int) -> Date? {
        var c = DateComponents()
        c.year = Calendar.current.component(.year, from: visibleMonth)
        c.month = Calendar.current.component(.month, from: visibleMonth)
        c.day = day
        c.hour = 12
        return Calendar.current.date(from: c)
    }

    private func monthTitle(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "LLLL yyyy"
        return f.string(from: date).capitalized
    }

    private func formattedDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "dd.MM.yyyy"
        return f.string(from: date)
    }

    private func formattedDateTime(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "dd MMM yyyy · HH:mm"
        return f.string(from: date)
    }
}

#Preview {
    GardenCalendarScreen()
        .environmentObject(GardenStore())
}
