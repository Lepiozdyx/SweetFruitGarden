import SwiftUI

struct PlantLibraryRootView: View {
    @EnvironmentObject private var store: GardenStore
    @State private var selectedTab: GardenTab = .catalog
    @State private var catalogState: CatalogState = .library
    @State private var selectedPlant: PlantDefinition? = nil
    @State private var selectedMyPlant: MyPlant? = nil
    @State private var isGardenPlantPickerVisible = false
    @State private var isKeyboardVisible = false

    var body: some View {
        ZStack(alignment: .bottom) {
            tabContent

            if !(selectedTab == .catalog && (catalogState == .add || catalogState == .pick || catalogState == .pickActive || catalogState == .newPlant || catalogState == .newPlantError || catalogState == .detailPlus || catalogState == .newPlantSaved))
                && !(selectedTab == .gardenMap && isGardenPlantPickerVisible)
                && !isKeyboardVisible {
                BottomGardenNavBar(selectedTab: $selectedTab)
            }
        }
        .onChange(of: selectedTab) { tab in
            // Failsafe: never keep hidden-nav state when switching tabs.
            isGardenPlantPickerVisible = false
            if tab != .catalog {
                catalogState = .library
                selectedPlant = nil
                selectedMyPlant = nil
            }
        }
        .task {
            await store.requestNotificationPermissionIfNeeded()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
            isKeyboardVisible = true
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            isKeyboardVisible = false
        }
    }

    @ViewBuilder
    private var tabContent: some View {
        switch selectedTab {
        case .catalog:
            switch catalogState {
            case .library:
                PlantLibraryScreen(
                    onSelectPlant: { myPlant in
                        selectedMyPlant = myPlant
                        selectedPlant = store.definition(by: myPlant.plantId)
                        catalogState = .detail
                    },
                    onTapAdd: {
                        selectedPlant = nil
                        selectedMyPlant = nil
                        catalogState = .newPlant
                    },
                    onTapReadyBanner: {
                        selectedTab = .gardenMap
                    }
                )
            case .detail:
                if let selectedPlant {
                    PlantDetailScreen(
                        plant: selectedPlant,
                        myPlant: selectedMyPlant,
                        onBack: { catalogState = .library },
                        onAdd: {
                            selectedTab = .gardenMap
                        }
                    )
                }
            case .add:
                PlantAddScreen()
            case .pick:
                PlantPickDateScreen(isActive: false)
            case .pickActive:
                PlantPickDateScreen(isActive: true)
            case .remove:
                PlantDetailRemoveScreen()
            case .newPlant:
                NewPlantScreen(
                    preselectedPlant: selectedPlant,
                    onBack: { catalogState = selectedPlant == nil ? .library : .detail },
                    onSaved: {
                        catalogState = .library
                        selectedTab = .catalog
                    }
                )
            case .newPlantError:
                NewPlantErrorScreen()
            case .detailPlus:
                PlantDetailPlusScreen()
            case .newPlantSaved:
                NewPlantSavedScreen()
            }
        case .gardenMap:
            GardenMapScreen(
                onPlantPickerVisibilityChanged: { isVisible in
                    isGardenPlantPickerVisible = isVisible
                },
                onRequestCreatePlant: {
                    selectedTab = .catalog
                    catalogState = .newPlant
                }
            )
        case .calendar:
            GardenCalendarScreen()
        case .alerts:
            NotificationsScreen()
        }
    }
}

private enum CatalogState {
    case library
    case detail
    case add
    case pick
    case pickActive
    case remove
    case newPlant
    case newPlantError
    case detailPlus
    case newPlantSaved
}

enum GardenTab: CaseIterable {
    case catalog
    case gardenMap
    case calendar
    case alerts

    var title: String {
        switch self {
        case .catalog: return "Catalog"
        case .gardenMap: return "Garden Map"
        case .calendar: return "Calendar"
        case .alerts: return "Alerts"
        }
    }

    var iconAsset: String {
        switch self {
        case .catalog: return "Icon3DLeaf"
        case .gardenMap: return "Icon3DMap"
        case .calendar: return "Icon3DCalendar"
        case .alerts: return "Icon3DBell"
        }
    }
}

private struct BottomGardenNavBar: View {
    @Binding var selectedTab: GardenTab

    var body: some View {
        let tabs = GardenTab.allCases

        return HStack(spacing: 0) {
            ForEach(tabs, id: \.title) { tab in
                Button {
                    selectedTab = tab
                } label: {
                    let isActive = selectedTab == tab
                    VStack(spacing: 4) {
                        ZStack(alignment: .top) {
                            if isActive {
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(LinearGradient(colors: [Color.hex("FFB300"), Color.hex("FFD700"), Color.hex("FFB300")], startPoint: .leading, endPoint: .trailing))
                                    .frame(width: 42, height: 4)
                                    .offset(y: -10)
                                    .shadow(color: Color.hex("FFD700").opacity(0.95), radius: 12)
                            }
                            Image(tab.iconAsset)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 28, height: 28)
                                .saturation(isActive ? 2.2 : 0.35)
                                .brightness(isActive ? 0.22 : -0.05)
                                .contrast(isActive ? 1.3 : 1.0)
                                .colorMultiply(isActive ? Color.hex("FFD700") : .white)
                                .overlay {
                                    if isActive {
                                        Image(tab.iconAsset)
                                            .resizable()
                                            .scaledToFit()
                                            .foregroundStyle(Color.hex("FFD700"))
                                            .blendMode(.screen)
                                            .opacity(0.9)
                                    }
                                }
                                .opacity(isActive ? 1 : 0.45)
                                .frame(width: 44, height: 30)
                                .background(isActive ? Color.hex("FFD700").opacity(0.1) : .clear)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(isActive ? Color.hex("FFD700").opacity(0.28) : .clear, lineWidth: 1.2)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .shadow(color: isActive ? Color.hex("FFD700").opacity(0.95) : .clear, radius: 14)
                        }
                        Text(tab.title)
                            .font(isActive ? .custom("Fredoka One", size: 10) : .system(size: 10, weight: .medium))
                            .foregroundStyle(isActive ? Color.hex("FFD700") : Color.white.opacity(0.38))
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 62)
                }
            }
        }
        .padding(.bottom, 2)
        .frame(height: 64)
        .background(LinearGradient(colors: [Color.hex("2D1B4E"), Color.hex("1A0A2E")], startPoint: .top, endPoint: .bottom))
        .overlay(alignment: .top) {
            Rectangle().fill(Color.white.opacity(0.1)).frame(height: 1)
        }
        .shadow(color: .black.opacity(0.5), radius: 14, y: -4)
    }
}

private struct PlaceholderSection: View {
    let title: String
    let emoji: String

    var body: some View {
        ZStack {
            RadialGradient(colors: [Color.hex("2D1060"), Color.hex("1A0A2E"), Color.hex("0D0518")], center: .top, startRadius: 20, endRadius: 900)
            VStack(spacing: 12) {
                Text(emoji).font(.system(size: 56))
                Text(title)
                    .font(.custom("Fredoka One", size: 28))
                    .foregroundStyle(.white)
                Text("Demo screen")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.white.opacity(0.7))
            }
        }
    }
}

#Preview {
    PlantLibraryRootView()
        .environmentObject(GardenStore())
}
