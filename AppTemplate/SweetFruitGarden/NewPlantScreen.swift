import SwiftUI
import PhotosUI

struct NewPlantScreen: View {
    @EnvironmentObject private var store: GardenStore
    var preselectedPlant: PlantDefinition?
    var onBack: (() -> Void)? = nil
    var onSaved: (() -> Void)? = nil

    @State private var nickname = ""
    @State private var plantingDate: Date? = nil
    @State private var note = ""
    @State private var selectedCategory: PlantCategory = .tree
    @State private var showDatePickerPopup = false
    @State private var pendingDate: Date? = nil
    @State private var visibleMonth: Date = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Date())) ?? Date()
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedPhotoData: Data?

    var body: some View {
        ZStack(alignment: .top) {
            RadialGradient(
                colors: [Color.hex("2D1060"), Color.hex("1A0A2E"), Color.hex("0D0518")],
                center: .top,
                startRadius: 20,
                endRadius: 1400
            )
            .ignoresSafeArea(edges: .bottom)

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 16) {
                    Color.clear.frame(height: 64)

                    titleCard
                    plantNameField
                    categorySection
                    plantingDateField
                    photoUpload
                    noteField
                    saveButton
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 140)
            }

            headerBar

            if showDatePickerPopup {
                datePickerOverlay
            }
        }
        .onChange(of: selectedPhotoItem) { newItem in
            guard let newItem else { return }
            Task {
                if let data = try? await newItem.loadTransferable(type: Data.self) {
                    await MainActor.run {
                        selectedPhotoData = data
                    }
                }
            }
        }
    }

    private var headerBar: some View {
        HStack(spacing: 12) {
            Button(action: { onBack?() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Color.hex("FFD700"))
                    .frame(width: 28, height: 28)
            }
            Text("New Plant")
                .font(.custom("Fredoka One", size: 20))
                .foregroundStyle(.white)
            Spacer()
        }
        .padding(.horizontal, 20)
        .frame(height: 56)
        .background(
            LinearGradient(colors: [Color.hex("2D1B4E"), Color.hex("241540")], startPoint: .top, endPoint: .bottom)
        )
        .overlay(alignment: .bottom) {
            Rectangle().fill(Color.white.opacity(0.08)).frame(height: 1)
        }
    }

    private var titleCard: some View {
        VStack(spacing: 8) {
            Text(selectedPlant.emoji)
                .font(.system(size: 48))
                .frame(height: 72)
                .padding(.top, 18)
            Text("New Plant")
                .font(.custom("Fredoka One", size: 20))
                .foregroundStyle(.white)
            Text("\(selectedPlant.category.rawValue) · \(plantingDate == nil ? "No date set" : displayDate(plantingDate!))")
                .font(.system(size: 13))
                .foregroundStyle(Color.hex("FFE066"))
                .padding(.bottom, 16)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 177)
        .background(LinearGradient(colors: [Color.hex("3D2468"), Color.hex("2D1B4E")], startPoint: .topLeading, endPoint: .bottomTrailing))
        .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.white.opacity(0.18), lineWidth: 1.5))
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: .black.opacity(0.5), radius: 16, y: 10)
    }

    private var plantNameField: some View {
        VStack(alignment: .leading, spacing: 6) {
            requiredLabel("Plant Name")
            NativeTextField(
                text: $nickname,
                placeholder: "e.g. Apple tree by the fence",
                textColor: .white,
                placeholderColor: UIColor.white.withAlphaComponent(0.95),
                font: .systemFont(ofSize: 15)
            )
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .frame(height: 52)
            .background(Color.white.opacity(0.07))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.white.opacity(0.15), lineWidth: 1.5)
                    .allowsHitTesting(false)
            )
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }

    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            requiredLabel("Category")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    categoryChip("🌳", "Tree", .tree)
                    categoryChip("🌿", "Shrub", .shrub)
                    categoryChip("🍇", "Vine", .vine)
                    categoryChip("🍓", "Berry", .berry)
                    categoryChip("🥕", "Vegetable", .vegetable)
                }
            }
        }
    }

    private func categoryChip(_ emoji: String, _ title: String, _ category: PlantCategory) -> some View {
        let active = selectedCategory == category
        return VStack(spacing: 6) {
            Text(emoji).font(.system(size: 28))
            Text(title)
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(active ? .white : Color.white.opacity(0.45))
            if active {
                Circle()
                    .fill(Color.hex("76FF03"))
                    .frame(width: 6, height: 6)
                    .shadow(color: Color.hex("76FF03"), radius: 6)
            } else {
                Color.clear.frame(width: 6, height: 6)
            }
        }
        .frame(width: 82, height: 82)
        .background(
            Group {
                if active {
                    LinearGradient(colors: [Color.hex("1A4A1A"), Color.hex("0F2E0F")], startPoint: .topLeading, endPoint: .bottomTrailing)
                } else {
                    Color.white.opacity(0.05)
                }
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(active ? Color.hex("64DC50").opacity(0.45) : Color.white.opacity(0.1), lineWidth: active ? 2 : 1.5)
        )
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(color: active ? Color.hex("50C83C").opacity(0.35) : .clear, radius: 10, y: 4)
        .onTapGesture {
            ClickSound.play()
            selectedCategory = category
        }
    }

    private var plantingDateField: some View {
        VStack(alignment: .leading, spacing: 6) {
            requiredLabel("Planting Date")
            Button {
                pendingDate = plantingDate
                visibleMonth = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: pendingDate ?? Date())) ?? Date()
                showDatePickerPopup = true
            } label: {
                HStack(spacing: 10) {
                Image("Icon-61")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16, height: 16)
                    .opacity(0.75)
                    Text(plantingDate == nil ? "Select planting date…" : displayDate(plantingDate!))
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(plantingDate == nil ? Color.white.opacity(0.35) : Color.white.opacity(0.9))
                    Spacer()
                }
            }
            .padding(.horizontal, 16)
            .frame(height: 52)
            .background(Color.white.opacity(0.07))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.15), lineWidth: 1.5))
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }

    private var photoUpload: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Photo (optional)")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Color.white.opacity(0.7))
            PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                VStack(spacing: 8) {
                    if let selectedPhotoData, let uiImage = UIImage(data: selectedPhotoData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 72, height: 52)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    } else {
                        Image(systemName: "photo")
                            .font(.system(size: 24))
                            .foregroundStyle(Color.white.opacity(0.3))
                    }
                    Text(selectedPhotoData == nil ? "Tap to upload photo" : "Photo selected")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.white.opacity(0.35))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 100)
                .background(Color.white.opacity(0.04))
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.2), style: StrokeStyle(lineWidth: 1.5, dash: [4, 4])))
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
        }
    }

    private var noteField: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Note (optional)")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Color.white.opacity(0.7))
            ZStack(alignment: .topLeading) {
                NativeTextView(
                    text: $note,
                    placeholder: "Add any notes about this plant...",
                    textColor: .white,
                    placeholderColor: UIColor.white.withAlphaComponent(0.95),
                    font: .systemFont(ofSize: 15)
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(height: 98.5)
            .background(Color.white.opacity(0.07))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.white.opacity(0.15), lineWidth: 1.5)
                    .allowsHitTesting(false)
            )
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }

    private var saveButton: some View {
        Button(action: {
            store.addMyPlant(plantId: selectedPlant.id, nickname: nickname, plannedDate: plantingDate, note: note, photoData: selectedPhotoData)
            onSaved?()
        }) {
            Text("SAVE PLANT")
                .font(.custom("Fredoka One", size: 16))
                .tracking(0.8)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    LinearGradient(
                        colors: [Color.hex("A8FF60"), Color.hex("76E020"), Color.hex("52C000"), Color.hex("3A8C00"), Color.hex("2A6600")],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.hex("96FF50").opacity(0.3), lineWidth: 1.5)
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: Color.hex("52C000").opacity(0.55), radius: 14, y: 8)
                .shadow(color: .black.opacity(0.35), radius: 4, y: 3)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.25), lineWidth: 0.8)
                        .blur(radius: 0.2)
                )
        }
    }

    private func requiredLabel(_ title: String) -> some View {
        (
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Color.white.opacity(0.7))
            +
            Text("*")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.red)
        )
    }

    private var selectedPlant: PlantDefinition {
        if let preselectedPlant { return preselectedPlant }
        return PlantDefinition.fullLibrary.first { $0.category == selectedCategory } ?? PlantDefinition.fullLibrary.first!
    }

    private func displayDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "dd.MM.yyyy"
        return f.string(from: date)
    }

    private var datePickerOverlay: some View {
        ZStack {
            Color.hex("0D0518")
                .opacity(0.8)
                .ignoresSafeArea()
                .onTapGesture {
                    ClickSound.play()
                    showDatePickerPopup = false
                }

            VStack(spacing: 0) {
                HStack {
                    Text("Pick a Date")
                        .font(.custom("Fredoka One", size: 18))
                        .foregroundStyle(.white)
                    Spacer()
                    Button {
                        showDatePickerPopup = false
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(Color.white.opacity(0.45))
                            .frame(width: 28, height: 28)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 22)

                HStack {
                    Button {
                        visibleMonth = Calendar.current.date(byAdding: .month, value: -1, to: visibleMonth) ?? visibleMonth
                    } label: {
                        monthNavButton("chevron.left")
                    }
                    Spacer()
                    Text(monthTitle(visibleMonth))
                        .font(.custom("Fredoka One", size: 17))
                        .foregroundStyle(Color.hex("FFD700"))
                    Spacer()
                    Button {
                        visibleMonth = Calendar.current.date(byAdding: .month, value: 1, to: visibleMonth) ?? visibleMonth
                    } label: {
                        monthNavButton("chevron.right")
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)

                HStack(spacing: 0) {
                    ForEach(["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"], id: \.self) { day in
                        Text(day)
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(Color.white.opacity(0.35))
                            .frame(maxWidth: .infinity)
                    }
                }
                .frame(height: 24.5)
                .padding(.horizontal, 20)
                .padding(.top, 16)

                calendarGrid
                    .padding(.horizontal, 20)
                    .padding(.top, 12)

                Text(pendingDate == nil ? "No date selected" : "Selected: \(displayDate(pendingDate!))")
                    .font(.system(size: 13))
                    .foregroundStyle(pendingDate == nil ? Color.white.opacity(0.35) : Color.hex("FFE066"))
                    .padding(.top, 14)

                Button {
                    guard pendingDate != nil else { return }
                    plantingDate = pendingDate
                    showDatePickerPopup = false
                } label: {
                    Text("Confirm Date")
                        .font(.custom("Fredoka One", size: 17))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(
                            Group {
                                if pendingDate == nil {
                                    Color.white.opacity(0.1)
                                } else {
                                    LinearGradient(
                                        colors: [Color.hex("FFBB7A"), Color.hex("FF8040"), Color.hex("FF6B35"), Color.hex("C84000")],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                }
                            }
                        )
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.hex("FFDCA6").opacity(0.5), lineWidth: 1.5))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .opacity(pendingDate == nil ? 0.45 : 1)
                        .shadow(color: pendingDate == nil ? .clear : Color.hex("FF6B35").opacity(0.5), radius: 12, y: 6)
                }
                .padding(.horizontal, 20)
                .padding(.top, 14)
            }
            .frame(width: 360, height: 548)
            .background(LinearGradient(colors: [Color.hex("3D2468"), Color.hex("2D1B4E")], startPoint: .topLeading, endPoint: .bottomTrailing))
            .overlay(
                RoundedRectangle(cornerRadius: 28)
                    .stroke(Color.white.opacity(0.22), lineWidth: 2)
            )
            .clipShape(RoundedRectangle(cornerRadius: 28))
            .shadow(color: .black.opacity(0.7), radius: 28, y: 14)
        }
    }

    private var calendarGrid: some View {
        let rows = daysMatrix(for: visibleMonth)
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
        let selectedDay = pendingDate.map { Calendar.current.component(.day, from: $0) }
        let today = Date()
        let todayDay = Calendar.current.component(.day, from: today)
        let isCurrentMonth = Calendar.current.isDate(visibleMonth, equalTo: today, toGranularity: .month) &&
            Calendar.current.isDate(visibleMonth, equalTo: today, toGranularity: .year)
        let isDisabledPastDay = isCurrentMonth && ((day ?? 0) < todayDay)
        return ZStack {
            if let day {
                if isCurrentMonth && day == todayDay {
                    Circle()
                        .stroke(Color.hex("FF6B35"), lineWidth: 2)
                        .frame(width: 42, height: 42)
                }
                if selectedDay == day {
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
                    .font(.system(size: selectedDay == day ? 15.68 : 14, weight: ((isCurrentMonth && day == todayDay) || selectedDay == day) ? .bold : .regular))
                    .foregroundStyle(
                        selectedDay == day
                            ? Color.hex("1A0A2E")
                            : ((isCurrentMonth && day == todayDay) ? Color.hex("FF6B35") : (isDisabledPastDay ? Color.white.opacity(0.28) : Color.white.opacity(0.8)))
                    )
            }
        }
        .frame(width: 42, height: 42)
        .contentShape(Rectangle())
        .onTapGesture {
            guard let day else { return }
            if isCurrentMonth && day < todayDay { return }
            ClickSound.play()
            pendingDate = dateForDay(day)
        }
    }

    private func dateForDay(_ day: Int) -> Date? {
        var c = DateComponents()
        c.year = Calendar.current.component(.year, from: visibleMonth)
        c.month = Calendar.current.component(.month, from: visibleMonth)
        c.day = day
        return Calendar.current.date(from: c)
    }

    private func daysMatrix(for month: Date) -> [[Int?]] {
        let calendar = Calendar.current
        guard let range = calendar.range(of: .day, in: .month, for: month),
              let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: month)) else {
            return []
        }
        let weekday = calendar.component(.weekday, from: firstDay) // 1=Sun
        let leadingEmpty = weekday - 1
        let days = Array(range).map(Optional.some)
        let base = Array(repeating: Optional<Int>.none, count: leadingEmpty) + days
        let remainder = base.count % 7
        var padded = remainder == 0 ? base : base + Array(repeating: Optional<Int>.none, count: 7 - remainder)
        // Keep calendar grid at constant 6 rows (42 cells) to avoid visual jumping/clipping.
        if padded.count < 42 {
            padded += Array(repeating: Optional<Int>.none, count: 42 - padded.count)
        }
        return stride(from: 0, to: padded.count, by: 7).map { idx in
            Array(padded[idx..<min(idx + 7, padded.count)])
        }
    }

    private func monthTitle(_ month: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "LLLL yyyy"
        return f.string(from: month).capitalized
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
    NewPlantScreen()
        .environmentObject(GardenStore())
}
