import SwiftUI

struct GardenMapScreen: View {
    @EnvironmentObject private var store: GardenStore
    var onPlantPickerVisibilityChanged: ((Bool) -> Void)? = nil
    var onRequestCreatePlant: (() -> Void)? = nil

    @State private var selectedBackground: MapBackground = .lawn
    @State private var selectedTool: DrawingTool = .circle
    @State private var selectedPlant: PlantOption = .appleTree
    @State private var zoomScale: CGFloat = 1
    @State private var pinchStartScale: CGFloat = 1
    @State private var canvasOffset: CGSize = .zero
    @State private var dragStartOffset: CGSize = .zero
    @State private var plantingRadius: CGFloat = 56
    @State private var objects: [GardenObject] = []
    @State private var freehandPaths: [FreehandStroke] = []
    @State private var activePath: [CGPoint] = []
    @State private var selectedObjectInfo: GardenObject?
    @State private var pendingPlacementPoint: CGPoint?
    @State private var showPlantPicker = false

    private let canvasSize = CGSize(width: 20000, height: 20000)
    private var isSmallScreen: Bool { UIScreen.main.bounds.height <= 700 }

    var body: some View {
        GeometryReader { geo in
            let topBarsHeight: CGFloat = 56 + 54
            let bottomSafeReserve: CGFloat = 72
            let mapHeight = isSmallScreen
                ? max(420, geo.size.height - topBarsHeight - bottomSafeReserve)
                : CGFloat(670)
            baseContent(mapHeight: mapHeight, useTopSafeAreaInset: true)
        }
        .onAppear {
            showPlantPicker = false
            onPlantPickerVisibilityChanged?(false)
            loadPersistedMap()
            if let first = plantPickerOptions.first {
                selectedPlant = first
            }
        }
        .onDisappear {
            onPlantPickerVisibilityChanged?(false)
        }
        .onChange(of: showPlantPicker) { isShown in
            onPlantPickerVisibilityChanged?(isShown)
        }
        .onChange(of: store.myPlants.count) { _ in
            if let first = plantPickerOptions.first, !plantPickerOptions.contains(selectedPlant) {
                selectedPlant = first
            }
        }
    }

    @ViewBuilder
    private func baseContent(mapHeight: CGFloat, useTopSafeAreaInset: Bool) -> some View {
        ZStack(alignment: .top) {
            RadialGradient(
                colors: [Color.hex("2D1060"), Color.hex("1A0A2E"), Color.hex("0D0518")],
                center: .top,
                startRadius: 20,
                endRadius: 900
            )
            .ignoresSafeArea(edges: showPlantPicker ? .bottom : [])

            VStack(spacing: 0) {
                mapCanvas(height: mapHeight)
                Spacer(minLength: 0)
            }

            toolsPanel
                .padding(.horizontal, 24)
                .padding(.bottom, 72)
                .frame(maxHeight: .infinity, alignment: .bottom)

            if let selected = selectedObjectInfo, selectedTool != .eraser {
                focusedPlantOverlay(for: selected)
                    .zIndex(9)
            }

            if showPlantPicker {
                plantPickerOverlay
                    .zIndex(20)
            }
        }
        .modifier(TopBarsModifier(enabled: useTopSafeAreaInset, headerBar: headerBar, topControls: topControls))
    }

    private var headerBar: some View {
        ZStack {
            HStack(spacing: 12) {
                Text("Garden Map")
                    .font(.custom("Fredoka One", size: 20))
                    .foregroundStyle(.white)
                Spacer()
            }
            .padding(.horizontal, 20)

            HStack(spacing: 12) {
                Spacer()
                circleButton(systemName: "plus.magnifyingglass") {
                    zoomScale = min(zoomScale + 0.15, 2.4)
                }
                circleButton(systemName: "minus.magnifyingglass") {
                    zoomScale = max(zoomScale - 0.15, 0.6)
                }
            }
            .padding(.trailing, 8)
        }
        .frame(height: 56)
        .background(LinearGradient(colors: [Color.hex("2D1B4E"), Color.hex("241540")], startPoint: .top, endPoint: .bottom))
        .overlay(alignment: .bottom) { Rectangle().fill(Color.white.opacity(0.08)).frame(height: 1) }
    }

    private func circleButton(systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.hex("FFD700"))
                .frame(width: 32, height: 32)
                .background(Color.white.opacity(0.1))
                .clipShape(Circle())
        }
    }

    private var topControls: some View {
        HStack(spacing: 8) {
            modeChip("Lawn", background: .lawn, width: 61.08)
            modeChip("Soil", background: .lawnTwo, width: 51.84)
            modeChip("Grid", background: .grid, width: 54.25)
            Spacer()
            Text("1cm = 1m")
                .font(.system(size: 11))
                .foregroundStyle(Color.white.opacity(0.4))
        }
        .padding(.horizontal, 24)
        .padding(.top, 10)
        .padding(.bottom, 10)
        .frame(height: 54)
        .background(
            LinearGradient(
                colors: [Color.hex("241540").opacity(0.96), Color.hex("1A0A2E").opacity(0.92)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }

    private func modeChip(_ title: String, background: MapBackground, width: CGFloat) -> some View {
        let active = selectedBackground == background
        return Text(title)
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(active ? .white : Color.white.opacity(0.6))
            .frame(width: width, height: 34)
            .background(
                Group {
                    if active {
                        LinearGradient(colors: [Color.hex("FF9A4D"), Color.hex("FF6B35")], startPoint: .top, endPoint: .bottom)
                    } else {
                        Color.white.opacity(0.07)
                    }
                }
            )
            .overlay(
                Capsule()
                    .stroke(active ? Color.hex("FFC896").opacity(0.5) : Color.white.opacity(0.15), lineWidth: 1.5)
            )
            .clipShape(Capsule())
            .shadow(color: active ? Color.hex("FF6B35").opacity(0.4) : .clear, radius: 8, y: 3)
            .onTapGesture {
                ClickSound.play()
                selectedBackground = background
                persistMap()
            }
    }

    private func mapCanvas(height: CGFloat) -> some View {
        GeometryReader { geometry in
            ZStack {
                ZStack {
                    canvasBackground
                    drawingLayer
                    interactionLayer(viewportSize: geometry.size)
                    hintView
                }
                .frame(width: canvasSize.width, height: canvasSize.height)
                .scaleEffect(zoomScale, anchor: .center)
                .offset(canvasOffset)
                .simultaneousGesture(magnifyGesture)
                .simultaneousGesture(
                    DragGesture(minimumDistance: 1)
                        .onChanged { value in
                            guard selectedTool != .pencil else { return }
                            if value.startLocation == value.location {
                                dragStartOffset = canvasOffset
                            }
                            canvasOffset = CGSize(
                                width: dragStartOffset.width + value.translation.width,
                                height: dragStartOffset.height + value.translation.height
                            )
                        }
                        .onEnded { _ in
                            dragStartOffset = canvasOffset
                        }
                )
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .frame(height: height)
    }

    private var canvasBackground: some View {
        Group {
            if selectedBackground == .grid {
                ZStack {
                    RadialGradient(
                        colors: [Color.hex("2D1060"), Color.hex("1A0A2E"), Color.hex("0D0518")],
                        center: .top,
                        startRadius: 20,
                        endRadius: 1500
                    )
                    GridPattern()
                        .stroke(Color.hex("5E11A2").opacity(0.85), lineWidth: 1)
                        .opacity(0.3)
                }
            } else {
                TiledAssetBackground(assetName: selectedBackground.assetName, canvasSize: canvasSize, tileSize: 1024)
            }
        }
    }

    private func interactionLayer(viewportSize: CGSize) -> some View {
        Rectangle()
            .fill(Color.clear)
            .contentShape(Rectangle())
            .gesture(canvasTapGesture(viewportSize: viewportSize))
            .simultaneousGesture(canvasLongPressGesture(viewportSize: viewportSize))
            .simultaneousGesture(freehandDragGesture(viewportSize: viewportSize))
    }

    private var drawingLayer: some View {
        ZStack {
            ForEach(objects.filter { object in
                guard let selected = selectedObjectInfo, selectedTool != .eraser else { return true }
                return object.id != selected.id
            }) { object in
                objectView(object)
                    .position(object.position)
                    .onTapGesture {
                        ClickSound.play()
                        handleObjectTap(object)
                    }
            }

            ForEach(freehandPaths) { stroke in
                Path { path in
                    guard let first = stroke.points.first else { return }
                    path.move(to: first)
                    for point in stroke.points.dropFirst() {
                        path.addLine(to: point)
                    }
                }
                .stroke(
                    Color.white.opacity(stroke.dashed ? 0.6 : 0.95),
                    style: StrokeStyle(
                        lineWidth: stroke.dashed ? 2 : 4,
                        lineCap: .round,
                        lineJoin: .round,
                        dash: stroke.dashed ? [7, 6] : []
                    )
                )
            }

            if !activePath.isEmpty {
                Path { path in
                    path.addLines(activePath)
                }
                .stroke(Color.hex("E6C9A8").opacity(0.95), style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
            }
        }
    }

    private func focusedPlantOverlay(for object: GardenObject) -> some View {
        let focusSize: CGFloat = 186
        return VStack(spacing: 14) {
            Circle()
                .fill(Color.clear)
                .overlay(focusBackgroundView.clipShape(Circle()))
                .overlay(Circle().fill(Color(red: 76 / 255, green: 175 / 255, blue: 80 / 255, opacity: 0.22)))
                .overlay(Circle().stroke(Color.hex("FF6B35"), lineWidth: 2.5))
                .frame(width: focusSize, height: focusSize)
                .shadow(color: Color.hex("FF6B35").opacity(0.6), radius: 16)
                .overlay(alignment: .top) {
                    plantVisual(for: object.plant, size: 40)
                        .offset(y: 44)
                }
                .overlay(alignment: .bottom) {
                    Text(object.customLabel ?? displayName(for: object.plant))
                        .font(.system(size: 10))
                        .foregroundStyle(.white)
                        .offset(y: -44)
                }
                .onTapGesture {
                    ClickSound.play()
                    selectedObjectInfo = nil
                }

            infoPanel(for: object)
                .frame(maxWidth: 342)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, isSmallScreen ? 38 : 70)
        .padding(.bottom, isSmallScreen ? 168 : 96)
    }

    private var focusBackgroundView: some View {
        if selectedBackground == .grid {
            return AnyView(
                ZStack {
                    RadialGradient(
                        colors: [Color.hex("2D1060"), Color.hex("1A0A2E"), Color.hex("0D0518")],
                        center: .top,
                        startRadius: 20,
                        endRadius: 300
                    )
                    GridPattern()
                        .stroke(Color.hex("5E11A2").opacity(0.85), lineWidth: 1)
                        .opacity(0.3)
                }
            )
        }
        return AnyView(
            Rectangle()
                .fill(
                    ImagePaint(
                        image: Image(selectedBackground.assetName),
                        scale: selectedBackground == .lawn ? 0.48 : 0.5
                    )
                )
        )
    }

    private func infoPanel(for object: GardenObject) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    plantVisual(for: object.plant, size: 20)
                    Text(object.customLabel ?? displayName(for: object.plant))
                        .font(.custom("Fredoka One", size: 16))
                        .foregroundStyle(.white)
                }
                Text("📅 Planting: \(object.plantedDate)")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.hex("FFE066"))
            }
            Spacer()
            Button {
                objects.removeAll { $0.id == object.id }
                selectedObjectInfo = nil
                persistMap()
            } label: {
                Image(systemName: "trash")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Color(red: 1, green: 0.31, blue: 0.31))
                    .frame(width: 20, height: 20)
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 69.5)
        .background(LinearGradient(colors: [Color.hex("3D2468"), Color.hex("2D1B4E")], startPoint: .topLeading, endPoint: .bottomTrailing))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.18), lineWidth: 1.2)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.5), radius: 14, y: 8)
    }

    private var hintView: some View {
        VStack(spacing: 10) {
            Text("🗺️")
                .font(.system(size: 40))
                .opacity(0.85)
            Text("Start drawing your garden layout")
                .font(.custom("Fredoka One", size: 16))
                .foregroundStyle(.white)
            Text("Drag to draw · Long-press to place a plant")
                .font(.system(size: 13))
                .foregroundStyle(Color.white.opacity(0.55))
        }
        .opacity(objects.isEmpty && freehandPaths.isEmpty ? 0.5 : 0)
    }

    private func canvasTapGesture(viewportSize: CGSize) -> some Gesture {
        SpatialTapGesture()
            .onEnded { event in
                let point = clampPoint(event.location)

                if let tapped = nearestObject(to: point), tapped.position.distance(to: point) < hitRadius(for: tapped) {
                    if selectedTool == .eraser {
                        objects.removeAll { $0.id == tapped.id }
                        if selectedObjectInfo?.id == tapped.id {
                            selectedObjectInfo = nil
                        }
                        persistMap()
                    } else {
                        selectedObjectInfo = tapped
                    }
                    return
                }

                switch selectedTool {
                case .circle:
                    placeObject(at: point, shape: .circle)
                case .square:
                    placeObject(at: point, shape: .square)
                case .eraser:
                    removeNearestObject(to: point)
                    removeNearestStroke(to: point)
                case .pencil:
                    break
                }
            }
    }

    private func freehandDragGesture(viewportSize: CGSize) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                guard selectedTool == .pencil else { return }
                activePath.append(clampPoint(value.location))
            }
            .onEnded { _ in
                guard selectedTool == .pencil, !activePath.isEmpty else { return }
                freehandPaths.append(FreehandStroke(points: activePath))
                activePath.removeAll()
                persistMap()
            }
    }

    private func canvasLongPressGesture(viewportSize: CGSize) -> some Gesture {
        LongPressGesture(minimumDuration: 1.0, maximumDistance: 8)
            .sequenced(before: DragGesture(minimumDistance: 0))
            .onEnded { value in
                // Disabled auto-open on long-press to prevent accidental fullscreen overlay on small screens.
                // Plant picker is opened explicitly from the "Select" chip in tools panel.
            }
    }

    private func objectView(_ object: GardenObject) -> some View {
        Group {
            if object.shape == .circle {
                ZStack {
                    Circle()
                        .fill(Color.hex("4CAF50").opacity(0.3))
                        .overlay(Circle().stroke(Color.hex("76FF03"), lineWidth: 2.5))
                        .frame(width: object.size, height: object.size)
                        .shadow(color: Color.hex("76FF03").opacity(0.4), radius: 12)
                    VStack(spacing: 2) {
                        plantVisual(for: object.plant, size: object.emojiSize)
                        Text(object.customLabel ?? displayName(for: object.plant))
                            .font(.system(size: object.labelFont, weight: .semibold))
                            .foregroundStyle(.white)
                            .lineLimit(2)
                            .multilineTextAlignment(.center)
                            .minimumScaleFactor(0.6)
                            .padding(.horizontal, 6)
                    }
                    .frame(width: object.size * 0.9)
                }
            } else {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.hex("FFD700").opacity(0.15))
                    .overlay(RoundedRectangle(cornerRadius: 2).stroke(Color.hex("FFD700"), lineWidth: 2))
                    .frame(width: object.rectWidth, height: object.rectHeight)
                    .shadow(color: Color.hex("FFD700").opacity(0.3), radius: 10)
                    .overlay {
                        VStack(spacing: 2) {
                            plantVisual(for: object.plant, size: object.emojiSize)
                            Text(object.customLabel ?? displayName(for: object.plant))
                                .font(.system(size: object.labelFont))
                                .foregroundStyle(Color.hex("FFE066"))
                                .lineLimit(2)
                                .minimumScaleFactor(0.6)
                        }
                    }
            }
        }
    }

    private var plantPickerOverlay: some View {
        GeometryReader { geo in
            let bottomInset = geo.safeAreaInsets.bottom
            ZStack(alignment: .bottom) {
                Color.hex("1A0A2E")
                    .opacity(0.85)
                    .ignoresSafeArea()
                    .onTapGesture {
                        ClickSound.play()
                        showPlantPicker = false
                        pendingPlacementPoint = nil
                    }

                VStack(alignment: .leading, spacing: 10) {
                    Text("Select Active Plant")
                        .font(.custom("Fredoka One", size: 18))
                        .foregroundStyle(.white)
                        .padding(.top, 22)
                        .padding(.bottom, 6)

                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 10) {
                            if plantPickerOptions.isEmpty {
                                VStack(spacing: 12) {
                                    Text("No plants in your garden yet.\nAdd plants in Catalog first.")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundStyle(Color.white.opacity(0.75))
                                        .multilineTextAlignment(.center)
                                        .frame(maxWidth: .infinity)
                                    Button {
                                        showPlantPicker = false
                                        pendingPlacementPoint = nil
                                        onRequestCreatePlant?()
                                    } label: {
                                        Text("+")
                                            .font(.system(size: 24, weight: .bold))
                                            .foregroundStyle(Color.hex("FFD700"))
                                            .frame(width: 52, height: 52)
                                            .background(Color.white.opacity(0.08))
                                            .overlay(Circle().stroke(Color.white.opacity(0.2), lineWidth: 1))
                                            .clipShape(Circle())
                                    }
                                }
                                .padding(.top, 20)
                            } else {
                                ForEach(plantPickerOptions, id: \.self) { plant in
                                    Button {
                                        selectedPlant = plant
                                        if let point = pendingPlacementPoint {
                                            objects.append(
                                                GardenObject(
                                                    plant: plant,
                                                    shape: .circle,
                                                    position: point,
                                                    size: 52,
                                                    plantedDate: "21.04.2026",
                                                    rectWidth: 0,
                                                    rectHeight: 0,
                                                    customLabel: displayName(for: plant)
                                                )
                                            )
                                            persistMap()
                                        }
                                        pendingPlacementPoint = nil
                                        showPlantPicker = false
                                    } label: {
                                        HStack(spacing: 12) {
                                            plantVisual(for: plant, size: 24)
                                                .frame(width: 24, height: 36)
                                            Text(displayName(for: plant))
                                                .font(.system(size: 15, weight: .semibold))
                                                .foregroundStyle(.white)
                                            Spacer()
                                        }
                                        .padding(.horizontal, 17)
                                        .frame(height: 62)
                                        .background(plant == selectedPlant ? Color.hex("FFD700").opacity(0.10) : Color.white.opacity(0.05))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 14)
                                                .stroke(plant == selectedPlant ? Color.hex("FFD700").opacity(0.3) : Color.white.opacity(0.1), lineWidth: 1)
                                        )
                                        .clipShape(RoundedRectangle(cornerRadius: 14))
                                    }
                                }
                            }
                        }
                    }
                    Spacer(minLength: 8)
                }
                .padding(.horizontal, 24)
                .frame(height: 519 + bottomInset)
                .frame(maxWidth: .infinity)
                .background(LinearGradient(colors: [Color.hex("3D2468"), Color.hex("2D1B4E")], startPoint: .topLeading, endPoint: .bottomTrailing))
                .overlay(alignment: .top) {
                    Rectangle().fill(Color.white.opacity(0.18)).frame(height: 2)
                }
                .clipShape(TopRoundedShape(radius: 24))
                .padding(.bottom, -bottomInset)
            }
        }
        .ignoresSafeArea(edges: .bottom)
    }

    private var plantPickerOptions: [PlantOption] {
        let ids = Set(store.myPlants.map(\.plantId))
        let mapped = ids.compactMap { id -> PlantOption? in
            switch id {
            case "apple": return .appleTree
            case "pear": return .pearTree
            case "cherry": return .cherryTree
            case "peach": return .peach
            case "walnut": return .walnut
            case "raspberry": return .raspberry
            case "currant": return .currant
            case "strawberry": return .strawberry
            case "grape": return .grape
            case "blueberry": return .blueberry
            case "blackberry": return .blackberry
            case "gooseberry": return .gooseberry
            case "tomato": return .tomato
            case "carrot": return .carrot
            case "cucumber": return .cucumber
            case "potato": return .potato
            case "onion": return .onion
            case "garlic": return .garlic
            case "cabbage": return .cabbage
            case "pepper": return .pepper
            default: return nil
            }
        }
        return mapped.sorted { $0.name < $1.name }
    }

    private func placeObject(at point: CGPoint, shape: GardenShapeType) {
        guard plantPickerOptions.contains(selectedPlant) else {
            pendingPlacementPoint = point
            showPlantPicker = true
            return
        }
        objects.append(
            GardenObject(
                plant: selectedPlant,
                shape: shape,
                position: point,
                size: shape == .circle ? plantingRadius : max(52, plantingRadius * 1.1),
                plantedDate: "21.04.2026",
                rectWidth: max(52, plantingRadius * 1.1),
                rectHeight: max(42, plantingRadius * 0.72),
                customLabel: displayName(for: selectedPlant)
            )
        )
        persistMap()
    }

    private func displayName(for option: PlantOption) -> String {
        let id = plantId(for: option)
        if let nickname = store.myPlants.first(where: { $0.plantId == id })?.nickname.trimmingCharacters(in: .whitespacesAndNewlines),
           !nickname.isEmpty {
            return nickname
        }
        return option.name
    }

    private func plantId(for option: PlantOption) -> String {
        switch option {
        case .appleTree: return "apple"
        case .pearTree: return "pear"
        case .cherryTree: return "cherry"
        case .peach: return "peach"
        case .walnut: return "walnut"
        case .raspberry: return "raspberry"
        case .currant: return "currant"
        case .strawberry: return "strawberry"
        case .grape: return "grape"
        case .blueberry: return "blueberry"
        case .blackberry: return "blackberry"
        case .gooseberry: return "gooseberry"
        case .tomato: return "tomato"
        case .carrot: return "carrot"
        case .cucumber: return "cucumber"
        case .potato: return "potato"
        case .onion: return "onion"
        case .garlic: return "garlic"
        case .cabbage: return "cabbage"
        case .pepper: return "pepper"
        }
    }

    @ViewBuilder
    private func plantVisual(for option: PlantOption, size: CGFloat) -> some View {
        if let data = store.myPlants.first(where: { $0.plantId == plantId(for: option) })?.photoData,
           let image = UIImage(data: data) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: size, height: size)
                .clipShape(RoundedRectangle(cornerRadius: max(4, size * 0.2)))
        } else {
            Text(option.emoji)
                .font(.system(size: size))
                .lineLimit(1)
                .minimumScaleFactor(0.5)
        }
    }

    private func handleObjectTap(_ object: GardenObject) {
        if selectedTool == .eraser {
            objects.removeAll { $0.id == object.id }
            return
        }
        selectedObjectInfo = object
    }

    private func removeNearestObject(to point: CGPoint) {
        guard let nearest = nearestObject(to: point) else { return }
        if nearest.position.distance(to: point) < 72 {
            objects.removeAll { $0.id == nearest.id }
            if selectedObjectInfo?.id == nearest.id {
                selectedObjectInfo = nil
            }
            persistMap()
        }
    }

    private func nearestObject(to point: CGPoint) -> GardenObject? {
        objects.min(by: { $0.position.distance(to: point) < $1.position.distance(to: point) })
    }

    private func hitRadius(for object: GardenObject) -> CGFloat {
        if object.shape == .circle {
            return max(26, object.size * 0.55)
        }
        return max(28, max(object.rectWidth, object.rectHeight) * 0.45)
    }

    private func removeNearestStroke(to point: CGPoint) {
        guard !freehandPaths.isEmpty else { return }
        let indexed = freehandPaths.enumerated().map { (idx, stroke) in
            (idx, stroke.minDistance(to: point))
        }
        guard let nearest = indexed.min(by: { $0.1 < $1.1 }), nearest.1 < 28 else { return }
        freehandPaths.remove(at: nearest.0)
        persistMap()
    }

    private var toolsPanel: some View {
        HStack(spacing: 6) {
            toolButton("⭕", tool: .circle)
            toolButton("⬜", tool: .square)
            toolButton("✏️", tool: .pencil)
            toolButton("🗑️", tool: .eraser)

            Spacer(minLength: 0)

            if plantPickerOptions.isEmpty {
                Button {
                    onRequestCreatePlant?()
                } label: {
                    Text("+")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(Color.hex("FFD700"))
                        .frame(width: 44, height: 40)
                        .background(Color.white.opacity(0.08))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.2), lineWidth: 1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            } else {
                HStack(spacing: 4) {
                    plantVisual(for: selectedPlant, size: 14)
                    Text(displayName(for: selectedPlant))
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.hex("FF6B35"))
                }
                .frame(width: 101, height: 40)
                .background(Color.hex("FF6B35").opacity(0.15))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.hex("FF6B35").opacity(0.3), lineWidth: 1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .onTapGesture {
                    ClickSound.play()
                    showPlantPicker = true
                }
            }
        }
        .padding(.horizontal, 10)
        .frame(height: 62.5)
        .background(LinearGradient(colors: [Color.hex("3D2468"), Color.hex("2D1B4E")], startPoint: .top, endPoint: .bottom))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.12), lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.3), radius: 10, y: -2)
        .overlay(alignment: .topTrailing) {
            if selectedTool == .circle || selectedTool == .square {
                HStack(spacing: 6) {
                    Button {
                        plantingRadius = max(36, plantingRadius - 4)
                    } label: {
                        Text("−")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 24, height: 24)
                            .background(Color.white.opacity(0.12))
                            .clipShape(Circle())
                    }
                    Text("R \(Int(plantingRadius))")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(Color.white.opacity(0.8))
                    Button {
                        plantingRadius = min(120, plantingRadius + 4)
                    } label: {
                        Text("+")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 24, height: 24)
                            .background(Color.white.opacity(0.12))
                            .clipShape(Circle())
                    }
                }
                .padding(.top, -30)
                .padding(.trailing, 10)
            }
        }
    }

    private func toolButton(_ title: String, tool: DrawingTool) -> some View {
        let active = selectedTool == tool
        return Text(title)
            .font(.system(size: 22))
            .frame(width: 44, height: 44)
            .background(active ? Color.hex("FFD700").opacity(0.15) : .clear)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: active ? Color.hex("FFD700").opacity(0.3) : .clear, radius: 8)
            .onTapGesture {
                ClickSound.play()
                selectedTool = tool
            }
    }

    private func clampPoint(_ point: CGPoint) -> CGPoint {
        CGPoint(
            x: min(max(point.x, 24), canvasSize.width - 24),
            y: min(max(point.y, 24), canvasSize.height - 24)
        )
    }

    private var magnifyGesture: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                zoomScale = min(max(pinchStartScale * value, 0.45), 3.2)
            }
            .onEnded { _ in
                pinchStartScale = zoomScale
            }
    }

    private func persistMap() {
        let payload = PersistedGardenMap(
            selectedBackground: selectedBackground,
            objects: objects,
            freehandPaths: freehandPaths
        )
        if let data = try? JSONEncoder().encode(payload) {
            UserDefaults.standard.set(data, forKey: "garden_map_state_v1")
        }
    }

    private func loadPersistedMap() {
        guard let data = UserDefaults.standard.data(forKey: "garden_map_state_v1"),
              let payload = try? JSONDecoder().decode(PersistedGardenMap.self, from: data) else {
            objects = []
            freehandPaths = []
            selectedObjectInfo = nil
            return
        }
        selectedBackground = payload.selectedBackground
        objects = payload.objects
        freehandPaths = payload.freehandPaths
        selectedObjectInfo = nil
    }
}

private enum DrawingTool {
    case circle
    case square
    case pencil
    case eraser
}

private enum MapBackground: String, Codable, Equatable {
    case lawn
    case lawnTwo
    case grid

    var assetName: String {
        switch self {
        case .lawn: return "Lawn"
        case .lawnTwo: return "Lawn-2"
        case .grid: return "Lawn"
        }
    }
}

private enum GardenShapeType: String, Codable {
    case circle
    case square
}

private enum PlantOption: String, Codable, CaseIterable, Equatable {
    case appleTree
    case pearTree
    case cherryTree
    case peach
    case walnut
    case raspberry
    case currant
    case strawberry
    case grape
    case blueberry
    case blackberry
    case gooseberry
    case tomato
    case carrot
    case cucumber
    case potato
    case onion
    case garlic
    case cabbage
    case pepper

    var name: String {
        switch self {
        case .appleTree: return "Apple Tree"
        case .pearTree: return "Pear Tree"
        case .cherryTree: return "Cherry Tree"
        case .peach: return "Peach Tree"
        case .walnut: return "Walnut"
        case .raspberry: return "Raspberry"
        case .currant: return "Currant"
        case .strawberry: return "Strawberry"
        case .grape: return "Grape"
        case .blueberry: return "Blueberry"
        case .blackberry: return "Blackberry"
        case .gooseberry: return "Gooseberry"
        case .tomato: return "Tomato"
        case .carrot: return "Carrot"
        case .cucumber: return "Cucumber"
        case .potato: return "Potato"
        case .onion: return "Onion"
        case .garlic: return "Garlic"
        case .cabbage: return "Cabbage"
        case .pepper: return "Pepper"
        }
    }

    var emoji: String {
        switch self {
        case .appleTree: return "🍎"
        case .pearTree: return "🍐"
        case .cherryTree: return "🍒"
        case .peach: return "🍑"
        case .walnut: return "🌰"
        case .raspberry: return "🌿"
        case .currant: return "🫐"
        case .strawberry: return "🍓"
        case .grape: return "🍇"
        case .blueberry: return "🫐"
        case .blackberry: return "🫐"
        case .gooseberry: return "🫐"
        case .tomato: return "🍅"
        case .carrot: return "🥕"
        case .cucumber: return "🥒"
        case .potato: return "🥔"
        case .onion: return "🧅"
        case .garlic: return "🧄"
        case .cabbage: return "🥬"
        case .pepper: return "🌶️"
        }
    }
}

private struct GardenObject: Identifiable, Codable {
    let id = UUID()
    let plant: PlantOption
    let shape: GardenShapeType
    let position: CGPoint
    let size: CGFloat
    let plantedDate: String
    let rectWidth: CGFloat
    let rectHeight: CGFloat
    let customLabel: String?

    var emojiSize: CGFloat {
        if shape == .circle { return max(12, size * 0.24) }
        return max(18, min(rectWidth, rectHeight) * 0.29)
    }

    var labelFont: CGFloat {
        if shape == .circle { return max(6, min(10, size * 0.1)) }
        return 11
    }

    var emojiTopOffset: CGFloat {
        if shape == .circle { return size * 0.08 }
        return rectHeight * 0.05
    }

    var labelBottomOffset: CGFloat {
        if shape == .circle { return -size * 0.1 }
        return -rectHeight * 0.12
    }
}

private struct FreehandStroke: Identifiable, Codable {
    let id = UUID()
    let points: [CGPoint]
    var dashed: Bool = false

    func minDistance(to point: CGPoint) -> CGFloat {
        guard !points.isEmpty else { return .greatestFiniteMagnitude }
        return points.map { $0.distance(to: point) }.min() ?? .greatestFiniteMagnitude
    }
}

private struct PersistedGardenMap: Codable {
    let selectedBackground: MapBackground
    let objects: [GardenObject]
    let freehandPaths: [FreehandStroke]
}

private struct TopRoundedShape: Shape {
    let radius: CGFloat

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: [.topLeft, .topRight],
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

private struct TiledAssetBackground: View {
    let assetName: String
    let canvasSize: CGSize
    let tileSize: CGFloat

    var body: some View {
        let cols = Int(ceil(canvasSize.width / tileSize))
        let rows = Int(ceil(canvasSize.height / tileSize))

        ZStack {
            ForEach(0..<rows, id: \.self) { row in
                ForEach(0..<cols, id: \.self) { col in
                    Image(assetName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: tileSize, height: tileSize)
                        .clipped()
                        .position(
                            x: CGFloat(col) * tileSize + tileSize / 2,
                            y: CGFloat(row) * tileSize + tileSize / 2
                        )
                }
            }
        }
    }
}

private struct TopBarsModifier<Header: View, Controls: View>: ViewModifier {
    let enabled: Bool
    let headerBar: Header
    let topControls: Controls

    func body(content: Content) -> some View {
        if enabled {
            content.safeAreaInset(edge: .top, spacing: 0) {
                VStack(spacing: 0) {
                    headerBar
                    topControls
                }
                .zIndex(10)
            }
        } else {
            content
        }
    }
}

private struct GridPattern: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let spacing: CGFloat = 33
        var x: CGFloat = 0
        while x <= rect.width {
            path.move(to: CGPoint(x: x, y: 0))
            path.addLine(to: CGPoint(x: x, y: rect.height))
            x += spacing
        }
        var y: CGFloat = 0
        while y <= rect.height {
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: rect.width, y: y))
            y += spacing
        }
        return path
    }
}

private extension CGPoint {
    func distance(to other: CGPoint) -> CGFloat {
        let dx = x - other.x
        let dy = y - other.y
        return sqrt(dx * dx + dy * dy)
    }
}

#Preview {
    GardenMapScreen()
}
