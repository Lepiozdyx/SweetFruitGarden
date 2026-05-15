import SwiftUI

struct PlantLibraryScreen: View {
    @EnvironmentObject private var store: GardenStore
    @State private var query = ""
    @State private var selectedCategory: PlantCategory? = nil
    var onSelectPlant: ((MyPlant) -> Void)? = nil
    var onTapAdd: (() -> Void)? = nil
    var onTapReadyBanner: (() -> Void)? = nil

    var body: some View {
        ZStack(alignment: .top) {
            RadialGradient(
                colors: [Color.hex("2D1060"), Color.hex("1A0A2E"), Color.hex("0D0518")],
                center: .top,
                startRadius: 20,
                endRadius: 900
            )

            VStack(spacing: 0) {
                headerBar
                content
            }
        }
    }

    private var headerBar: some View {
        HStack {
            Text("Plant Library")
                .font(.custom("Fredoka One", size: 20))
                .foregroundStyle(.white)
            Spacer()
            Button(action: { onTapAdd?() }) {
                Image(systemName: "plus")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(Color.hex("FFD700"))
                    .frame(width: 36, height: 36)
                    .background(Color.white.opacity(0.1))
                    .overlay(Circle().stroke(Color.white.opacity(0.15), lineWidth: 1))
                    .clipShape(Circle())
            }
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

    private var content: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 14) {
                searchBar
                    .padding(.top, 24)

                banner

                filters
                    .padding(.bottom, 8)

                if filteredMyPlants.isEmpty {
                    emptyState
                } else {
                    ForEach(filteredMyPlants) { myPlant in
                        Button {
                            onSelectPlant?(myPlant)
                        } label: {
                            PlantCardView(
                                plant: store.definition(by: myPlant.plantId) ?? PlantDefinition.fullLibrary.first!,
                                nickname: myPlant.nickname,
                                photoData: myPlant.photoData
                            )
                        }
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 90)
        }
    }

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color.white.opacity(0.4))
            NativeTextField(
                text: $query,
                placeholder: "Search plants...",
                textColor: .white,
                placeholderColor: UIColor.white.withAlphaComponent(0.5),
                font: .systemFont(ofSize: 15)
            )
            .frame(maxWidth: .infinity, alignment: .leading)
            Spacer()
        }
        .padding(.horizontal, 14)
        .frame(height: 44)
        .background(Color.white.opacity(0.07))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.white.opacity(0.15), lineWidth: 1.5)
                .allowsHitTesting(false)
        )
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private var banner: some View {
        Button(action: { onTapReadyBanner?() }) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(store.myPlants.count) Plants Ready 🌿")
                        .font(.custom("Fredoka One", size: 18))
                        .foregroundStyle(.white)
                    Text(store.myPlants.isEmpty ? "Create your first plant card" : "Tap to open Garden Map")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.white.opacity(0.8))
                }
                Spacer()
                Text("\(store.myPlants.count)")
                    .font(.custom("Fredoka One", size: 32))
                    .foregroundStyle(Color.hex("FFD700"))
            }
            .padding(.horizontal, 18)
            .frame(height: 86)
            .background(
                LinearGradient(colors: [Color.hex("FF6B35"), Color.hex("FF1493"), Color.hex("7B00FF")], startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.35), lineWidth: 1.5))
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: Color.hex("FF6B35").opacity(0.35), radius: 16, y: 8)
        }
        .buttonStyle(.plain)
    }

    private var filters: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                filterChip("All", active: true)
                filterChip("Tree")
                filterChip("Shrub")
                filterChip("Vine")
                filterChip("Berry")
                filterChip("Vegetable")
            }
        }
    }

    private func filterChip(_ title: String, active: Bool = false) -> some View {
        let isActive: Bool = {
            if title == "All" { return selectedCategory == nil }
            return selectedCategory?.rawValue == title
        }()
        return Text(title)
            .font(.system(size: 13, weight: isActive ? .bold : .semibold))
            .foregroundStyle(isActive ? .white : Color.white.opacity(0.6))
            .padding(.horizontal, 18)
            .frame(height: 38)
            .background(
                Group {
                    if isActive {
                        LinearGradient(colors: [Color.hex("FFBB7A"), Color.hex("FF8040"), Color.hex("FF6B35"), Color.hex("C84000")], startPoint: .top, endPoint: .bottom)
                    } else {
                        Color.white.opacity(0.07)
                    }
                }
            )
            .overlay(Capsule().stroke(isActive ? Color.white.opacity(0.5) : Color.white.opacity(0.1), lineWidth: 1))
            .clipShape(Capsule())
            .shadow(color: isActive ? Color.hex("FF6B35").opacity(0.45) : .clear, radius: 7, y: 3)
            .onTapGesture {
                ClickSound.play()
                if title == "All" {
                    selectedCategory = nil
                } else {
                    selectedCategory = PlantCategory(rawValue: title)
                }
            }
    }

    private var filteredPlants: [PlantDefinition] {
        store.filteredPlants(query: query, category: selectedCategory)
    }

    private var filteredMyPlants: [MyPlant] {
        store.myPlants.filter { myPlant in
            guard let def = store.definition(by: myPlant.plantId) else { return false }
            let queryText = query.trimmingCharacters(in: .whitespacesAndNewlines)
            let queryOK = queryText.isEmpty
                || myPlant.nickname.localizedCaseInsensitiveContains(queryText)
                || def.name.localizedCaseInsensitiveContains(queryText)
                || def.emoji.localizedCaseInsensitiveContains(queryText)
            let categoryOK = selectedCategory == nil || def.category == selectedCategory
            return queryOK && categoryOK
        }
    }

    private var emptyState: some View {
        VStack(spacing: 10) {
            Text("🌱")
                .font(.system(size: 34))
            Text("Your plant list is empty")
                .font(.custom("Fredoka One", size: 18))
                .foregroundStyle(.white)
            Text("Tap + to create your first plant card.")
                .font(.system(size: 14))
                .foregroundStyle(Color.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .frame(height: 180)
        .background(Color.white.opacity(0.04))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.1), lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

private struct PlantCardView: View {
    let plant: PlantDefinition
    var nickname: String
    var photoData: Data?

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(LinearGradient(colors: [Color.hex("2A5C1A"), Color.hex("1A3C0A")], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 64, height: 64)
                if let photoData, let image = UIImage(data: photoData) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 56, height: 56)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    Text(plant.emoji)
                        .font(.system(size: 34))
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(plant.category.rawValue)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color.hex("76FF03"))
                    .padding(.horizontal, 11)
                    .frame(height: 26)
                    .background(Color.hex("76FF03").opacity(0.12))
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.hex("76FF03").opacity(0.3), lineWidth: 1))
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                Text(nickname.isEmpty ? "Unnamed Plant" : nickname)
                    .font(.custom("Fredoka One", size: 17))
                    .foregroundStyle(.white)

                Text("Plant in \(plant.plantingSeason), harvest \(plant.harvestText.lowercased())")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.hex("FFE066"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
                    .allowsTightening(true)
            }

            Spacer()

            Text("›")
                .font(.system(size: 22))
                .foregroundStyle(Color.hex("FFD700").opacity(0.5))
                .padding(.trailing, 2)
        }
        .padding(.horizontal, 13)
        .frame(height: 105)
        .background(LinearGradient(colors: [Color.hex("3D2468"), Color.hex("2D1B4E")], startPoint: .topLeading, endPoint: .bottomTrailing))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.1), lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.5), radius: 14, y: 8)
    }
}

#Preview {
    PlantLibraryScreen()
        .environmentObject(GardenStore())
}
