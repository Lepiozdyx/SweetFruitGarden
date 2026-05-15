import SwiftUI

struct GardenCalendarDateScreen: View {
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
                    eventsTitle
                    eventOpenCard
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
        .overlay(alignment: .bottom) { Rectangle().fill(Color.white.opacity(0.08)).frame(height: 1) }
    }

    private var calendarCard: some View {
        VStack(spacing: 10) {
            HStack {
                Image(systemName: "chevron.left")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color.hex("FFD700"))
                    .frame(width: 30, height: 30)
                Spacer()
                Text("April 2026")
                    .font(.custom("Fredoka One", size: 18))
                    .foregroundStyle(.white)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color.hex("FFD700"))
                    .frame(width: 30, height: 30)
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
                        Color.clear.frame(height: 40.58)
                    }
                }
            }
        }
        .padding(.horizontal, 17)
        .padding(.top, 17.5)
        .padding(.bottom, 16)
        .frame(height: 331.88)
        .background(Color.white.opacity(0.05))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.1), lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.4), radius: 10, y: 6)
    }

    private func dayCell(_ day: Int) -> some View {
        let hasEvent = [12, 15, 20, 21, 29].contains(day)
        let isToday = day == 20
        let isSelected = day == 22

        return VStack(spacing: 2) {
            Text("\(day)")
                .font(.system(size: 13, weight: isToday ? .bold : .regular))
                .foregroundStyle(
                    isSelected ? Color.black.opacity(0.8) :
                        (isToday ? Color.hex("FF6B35") : Color.white.opacity(day < 20 ? 0.35 : 0.8))
                )
            Circle()
                .fill(hasEvent ? Color.hex("76FF03") : .clear)
                .frame(width: 5, height: 5)
                .shadow(color: hasEvent ? Color.hex("76FF03").opacity(0.6) : .clear, radius: 4)
        }
        .frame(height: 40.58)
        .frame(maxWidth: .infinity)
        .background(isSelected ? Color.hex("FFD700") : Color.clear)
        .overlay(RoundedRectangle(cornerRadius: 20.289).stroke(isToday ? Color.hex("FF6B35") : .clear, lineWidth: 1.5))
        .clipShape(RoundedRectangle(cornerRadius: 20.289))
    }

    private var markersRow: some View {
        HStack(spacing: 16) {
            HStack(spacing: 6) {
                Circle().fill(Color.hex("76FF03")).frame(width: 8, height: 8).shadow(color: Color.hex("76FF03").opacity(0.6), radius: 6)
                Text("Planting event").font(.system(size: 12)).foregroundStyle(Color.white.opacity(0.55))
            }
            HStack(spacing: 6) {
                Circle().stroke(Color.hex("FF6B35"), lineWidth: 1.5).frame(width: 14, height: 14)
                Text("Today").font(.system(size: 12)).foregroundStyle(Color.white.opacity(0.55))
            }
            Spacer()
        }
        .frame(height: 18)
    }

    private var eventsTitle: some View {
        HStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 2).fill(Color.hex("FFD700")).frame(width: 3, height: 16)
            Text("Events: 22.04.2026")
                .font(.custom("Fredoka One", size: 17))
                .foregroundStyle(.white)
            Spacer()
        }
    }

    private var eventOpenCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 10) {
                Text("🌳").font(.system(size: 24))
                VStack(alignment: .leading, spacing: 0) {
                    Text("🌱 Plant ысы")
                        .font(.custom("Fredoka One", size: 15))
                        .foregroundStyle(.white)
                    Text("21.04.2026")
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
            .frame(height: 68)

            Divider().overlay(Color.white.opacity(0.08)).padding(.horizontal, 16)

            VStack(alignment: .leading, spacing: 4) {
                Text("Recommendation:")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.white.opacity(0.7))
                Text("Choose a sunny, open location with deep soil. Wate")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.hex("FFE066"))
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
        }
        .frame(height: 159)
        .background(LinearGradient(colors: [Color.hex("3D2468"), Color.hex("2D1B4E")], startPoint: .topLeading, endPoint: .bottomTrailing))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.15), lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.3), radius: 8, y: 4)
    }

    private var calendarCells: [Int?] {
        let leadingEmpty = 3
        let days = Array(1...30).map(Optional.some)
        let base = Array(repeating: Optional<Int>.none, count: leadingEmpty) + days
        let remainder = base.count % 7
        return remainder == 0 ? base : base + Array(repeating: Optional<Int>.none, count: 7 - remainder)
    }
}

#Preview {
    GardenCalendarDateScreen()
}
