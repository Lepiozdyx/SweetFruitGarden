import SwiftUI

struct PlantPickDateScreen: View {
    let isActive: Bool
    private let weekDays = ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                PlantDetailScreen()
                    .ignoresSafeArea(edges: .bottom)

                Color.hex("0D0518")
                    .opacity(0.8)
                    .ignoresSafeArea()

                popup
                    .padding(.horizontal, 15)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .padding(.top, max((geometry.size.height - 509.45) / 2, 72))
            }
        }
    }

    private var popup: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Pick a Date")
                    .font(.custom("Fredoka One", size: 18))
                    .foregroundStyle(.white)
                Spacer()
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color.white.opacity(0.45))
                    .frame(width: 28, height: 28)
            }
            .padding(.horizontal, 20)
            .padding(.top, 22)

            HStack {
                monthNavButton("chevron.left")
                Spacer()
                Text("April 2026")
                    .font(.custom("Fredoka One", size: 17))
                    .foregroundStyle(Color.hex("FFD700"))
                Spacer()
                monthNavButton("chevron.right")
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)

            HStack {
                ForEach(weekDays, id: \.self) { day in
                    Text(day)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(Color.white.opacity(0.35))
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)

            calendarGrid
                .padding(.horizontal, 20)
                .padding(.top, 12)

            Text(isActive ? "Selected: 22.04.2026" : "No date selected")
                .font(.system(size: 13))
                .foregroundStyle(isActive ? Color.hex("FFE066") : Color.white.opacity(0.35))
                .padding(.top, 14)

            Button(action: {}) {
                Text("Confirm Date")
                    .font(.custom("Fredoka One", size: 17))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(
                        Group {
                            if isActive {
                                LinearGradient(
                                    colors: [Color.hex("FFBB7A"), Color.hex("FF8040"), Color.hex("FF6B35"), Color.hex("C84000")],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            } else {
                                Color.white.opacity(0.1)
                            }
                        }
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.hex("FFDCA6").opacity(0.5), lineWidth: 1.5)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .opacity(isActive ? 1.0 : 0.45)
                    .shadow(color: isActive ? Color.hex("FF6B35").opacity(0.5) : .clear, radius: 12, y: 6)
            }
            .padding(.horizontal, 20)
            .padding(.top, 14)
        }
        .frame(height: 509.45)
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(colors: [Color.hex("3D2468"), Color.hex("2D1B4E")], startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28)
                .stroke(Color.white.opacity(0.22), lineWidth: 2)
        )
        .clipShape(RoundedRectangle(cornerRadius: 28))
        .shadow(color: .black.opacity(0.7), radius: 28, y: 14)
    }

    private var calendarGrid: some View {
        let rows: [[Int?]] = [
            [nil, nil, nil, 1, 2, 3, 4],
            [5, 6, 7, 8, 9, 10, 11],
            [12, 13, 14, 15, 16, 17, 18],
            [19, 20, 21, 22, 23, 24, 25],
            [26, 27, 28, 29, 30, nil, nil]
        ]

        return VStack(spacing: 4) {
            ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                HStack(spacing: 4) {
                    ForEach(Array(row.enumerated()), id: \.offset) { _, day in
                        dayCell(day)
                    }
                }
            }
        }
    }

    private func dayCell(_ day: Int?) -> some View {
        ZStack {
            if let day {
                if day == 21 {
                    Circle()
                        .stroke(Color.hex("FF6B35"), lineWidth: 2)
                }
                if isActive && day == 22 {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.hex("FFE566"), Color.hex("FFD700"), Color.hex("FF8C00")],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .shadow(color: Color.hex("FFB400").opacity(0.5), radius: 7, y: 3)
                        .frame(width: 47.04, height: 47.04)
                }
                Text("\(day)")
                    .font(.system(size: isActive && day == 22 ? 16 : 14, weight: (day == 21 || (isActive && day == 22)) ? .bold : .regular))
                    .foregroundStyle(
                        isActive && day == 22
                            ? Color.hex("1A0A2E")
                            : (day == 21 ? Color.hex("FF6B35") : Color.white.opacity(0.8))
                    )
            }
        }
        .frame(width: 42, height: 42)
    }

    private func monthNavButton(_ systemName: String) -> some View {
        Image(systemName: systemName)
            .font(.system(size: 12, weight: .bold))
            .foregroundStyle(Color.hex("FFD700"))
            .frame(width: 36, height: 36)
            .background(Color.white.opacity(0.08))
            .overlay(Circle().stroke(Color.white.opacity(0.12), lineWidth: 1))
            .clipShape(Circle())
    }
}

#Preview {
    PlantPickDateScreen(isActive: true)
}
