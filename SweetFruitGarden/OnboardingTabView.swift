import SwiftUI

struct OnboardingTabView: View {
    @State private var currentPage = 0
    var onFinished: () -> Void = {}

    private let pages: [OnboardingPage] = [
        .init(
            title: "Welcome to Sweet Fruit Garden",
            subtitle: "Build your colorful garden and discover joyful planting moments every day.",
            emoji: "🌟",
            gradient: [Color(hex: "4A1080"), Color(hex: "2D0A5E"), Color(hex: "1A0A2E")]
        ),
        .init(
            title: "Plan Your Garden",
            subtitle: "Discover 20+ plants and design the perfect layout for every corner.",
            emoji: "🌱",
            gradient: [Color(hex: "5B0EA6"), Color(hex: "2D0A5E"), Color(hex: "1A0A2E")]
        ),
        .init(
            title: "Track Your Harvest",
            subtitle: "Know exactly when each fruit is ready to pick with smart reminders.",
            emoji: "🍓",
            gradient: [Color(hex: "FF1493"), Color(hex: "8B0050"), Color(hex: "3D0A2E"), Color(hex: "1A0A20")]
        ),
        .init(
            title: "Map Your Space",
            subtitle: "Draw your garden layout and place every plant with precision.",
            emoji: "🗺️",
            gradient: [Color(hex: "0A4A2E"), Color(hex: "062A18"), Color(hex: "020E08")]
        )
    ]

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottom) {
                TabView(selection: $currentPage) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                        if index == 0 {
                            FirstOnboardingSplashView()
                                .tag(index)
                        } else if index == 1 {
                            SecondOnboardingView()
                                .tag(index)
                        } else if index == 2 {
                            ThirdOnboardingView(page: page) {
                                currentPage = pages.count - 1
                            }
                                .tag(index)
                        } else if index == 3 {
                            FourthOnboardingView(page: page)
                                .tag(index)
                        } else {
                            OnboardingPageView(page: page, pageIndex: index)
                                .tag(index)
                        }
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .ignoresSafeArea()

                overlayControls
                    .padding(.horizontal, 24)
                    .padding(.bottom, geo.size.height <= 700 ? 18 : 32)

                topSkipBar
                    .padding(.top, geo.safeAreaInsets.top + 2)
                    .frame(maxHeight: .infinity, alignment: .top)
            }
        }
    }

    private var topSkipBar: some View {
        HStack {
            Spacer()
            if currentPage >= 0 && currentPage < pages.count - 1 {
                Button("Skip") {
                    onFinished()
                }
                .font(.system(size: 13, weight: .semibold))
                .frame(width: 55, height: 33)
                .background(Color.white.opacity(0.12))
                .clipShape(Capsule())
                .overlay { Capsule().stroke(Color.white.opacity(0.2), lineWidth: 1) }
                .foregroundStyle(Color.white.opacity(0.8))
            }
        }
        .padding(.horizontal, 20)
    }

    private var overlayControls: some View {
        VStack(alignment: .leading, spacing: 18) {
            pageIndicator

            Button(action: goNext) {
                Text(currentPage == pages.count - 1 ? "🌱 GET STARTED" : "NEXT →")
                    .font(.custom("Fredoka One", size: 16))
                    .textCase(.uppercase)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(currentPage == pages.count - 1 ? finishGradient : nextGradient)
                    .foregroundStyle(currentPage == pages.count - 1 ? .white : Color(hex: "3A2000"))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay {
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.28), lineWidth: 1)
                    }
                    .shadow(
                        color: currentPage == pages.count - 1
                            ? Color(hex: "FF6B35").opacity(0.65)
                            : Color(hex: "FFD700").opacity(0.6),
                        radius: 14,
                        x: 0,
                        y: 8
                    )
                    .shadow(color: .black.opacity(0.35), radius: 4, x: 0, y: 3)
            }
        }
    }

    private var pageIndicator: some View {
        let stepsCount = pages.count
        let activeStep = currentPage

        return HStack(spacing: 8) {
            ForEach(0..<stepsCount, id: \.self) { index in
                RoundedRectangle(cornerRadius: 4)
                    .fill(index == activeStep ? Color(hex: "FFD700") : Color.white.opacity(0.3))
                    .frame(width: index == activeStep ? 24 : 8, height: 8)
                    .animation(.easeInOut(duration: 0.2), value: activeStep)
            }
        }
    }

    private var nextGradient: LinearGradient {
        LinearGradient(
            colors: [Color(hex: "FFF0A0"), Color(hex: "FFE040"), Color(hex: "FFD700"), Color(hex: "D4A800"), Color(hex: "AA8000")],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    private var finishGradient: LinearGradient {
        LinearGradient(
            colors: [Color(hex: "FFBB7A"), Color(hex: "FF8040"), Color(hex: "FF6B35"), Color(hex: "E64A00"), Color(hex: "C03800")],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    private func goNext() {
        guard currentPage < pages.count - 1 else {
            onFinished()
            return
        }
        withAnimation {
            currentPage += 1
        }
    }
}

private struct SecondOnboardingView: View {
    var body: some View {
        GeometryReader { geo in
            let sx = geo.size.width / 390.0
            let sy = geo.size.height / 844.0
            ZStack(alignment: .topLeading) {
                Image("Onboarding_1-2")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea(.all, edges: .all)

                Text("🌱")
                    .font(.system(size: 56 * sx))
                    .position(x: 52 * sx, y: 530.87 * sy)

                Text("Plan Your Garden")
                    .font(.custom("Fredoka One", size: 30 * sx))
                    .foregroundStyle(.white)
                    .position(x: 150.5 * sx, y: 609.15 * sy)

                Text("Discover 20+ plants and design the perfect layout for your dream garden.")
                    .font(.system(size: 16 * sx))
                    .foregroundStyle(.white.opacity(0.85))
                    .lineSpacing(4 * sy)
                    .frame(width: 342 * sx, alignment: .leading)
                    .position(x: 195 * sx, y: 666.82 * sy)
            }
        }
        .ignoresSafeArea(.all, edges: .all)
    }
}

private struct FirstOnboardingSplashView: View {
    var body: some View {
        GeometryReader { geometry in
            let sx = geometry.size.width / 390.0
            let sy = geometry.size.height / 844.0

            ZStack {
                // Base background only from provided asset.
                Image("Background_Splash")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()

                // Shadow glow from CSS (206x206 at x:95 y:247).
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color(hex: "FF6B35").opacity(0.18), .clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: 103
                        )
                    )
                    .frame(width: 206 * sx, height: 206 * sy)
                    .blur(radius: 30 * sx)
                    .position(x: (95 + 103) * sx, y: (247 + 103) * sy)

                Text("🌱")
                    .font(.system(size: 80 * sx))
                    .position(x: (155 + 40) * sx, y: (301.85 + 40) * sy)

                Text("Sweet Fruit Garden")
                    .font(.custom("Fredoka One", size: 32 * sx))
                    .foregroundStyle(.white)
                    .tracking(0.5)
                    .position(x: (42.09 + 153) * sx, y: (425.25 + 24) * sy)

                Text("Plant today. Harvest tomorrow.")
                    .font(.system(size: 15 * sx, weight: .regular))
                    .foregroundStyle(Color(hex: "FFE066").opacity(0.85))
                    .position(x: (90.1 + 105) * sx, y: (483.75 + 11.5) * sy)

                HStack(spacing: 6.8 * sx) {
                    Circle()
                        .fill(Color(hex: "FFD700").opacity(0.33))
                        .frame(width: 6.59 * sx, height: 6.59 * sy)
                        .shadow(color: Color(hex: "FFD700").opacity(0.5), radius: 6 * sx)
                    Circle()
                        .fill(Color(hex: "FFD700").opacity(0.31))
                        .frame(width: 6.49 * sx, height: 6.49 * sy)
                        .shadow(color: Color(hex: "FFD700").opacity(0.5), radius: 6 * sx)
                    Circle()
                        .fill(Color(hex: "FFD700").opacity(0.46))
                        .frame(width: 7.47 * sx, height: 7.47 * sy)
                        .shadow(color: Color(hex: "FFD700").opacity(0.5), radius: 7 * sx)
                }
                .position(x: (177.7 + 17.5) * sx, y: (554.52 + 3.7) * sy)
            }
            .ignoresSafeArea(.all, edges: .all)
        }
        .ignoresSafeArea(.all, edges: .all)
        .statusBarHidden(true)
    }
}

private struct ThirdOnboardingView: View {
    let page: OnboardingPage
    let onSkip: () -> Void

    var body: some View {
        GeometryReader { geo in
            let sx = geo.size.width / 390.0
            let sy = geo.size.height / 844.0
            ZStack(alignment: .topLeading) {
                Image("Background_onboarding2")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea(.all, edges: .all)

                LinearGradient(
                    colors: [
                        Color(red: 26 / 255, green: 10 / 255, blue: 32 / 255).opacity(0.7),
                        Color(red: 26 / 255, green: 10 / 255, blue: 32 / 255).opacity(0.7),
                        .clear
                    ],
                    startPoint: .bottom,
                    endPoint: .top
                )
                .ignoresSafeArea(.all, edges: .all)

                Text(page.emoji)
                    .font(.system(size: 56 * sx))
                    .position(x: 52 * sx, y: 531 * sy)

                Text(page.title)
                    .font(.custom("Fredoka One", size: 30 * sx))
                    .foregroundStyle(.white)
                    .position(x: 165 * sx, y: 607 * sy)

                Text("Know exactly when each fruit is ready to pick with smart reminders.")
                    .font(.system(size: 16 * sx, weight: .regular))
                    .foregroundStyle(.white.opacity(0.85))
                    .lineSpacing(4 * sy)
                    .frame(width: 342 * sx, alignment: .leading)
                    .position(x: 195 * sx, y: 667 * sy)
            }
        }
        .ignoresSafeArea(.all, edges: .all)
    }
}

private struct FourthOnboardingView: View {
    let page: OnboardingPage

    var body: some View {
        GeometryReader { geo in
            let sx = geo.size.width / 390.0
            let sy = geo.size.height / 844.0
            ZStack(alignment: .topLeading) {
                Image("Background_onboarding3")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea(.all, edges: .all)

                LinearGradient(
                    colors: [Color(hex: "020E08").opacity(0.8), Color(hex: "020E08").opacity(0.82), .clear],
                    startPoint: .bottom,
                    endPoint: .top
                )
                .ignoresSafeArea(.all, edges: .all)

                Text(page.emoji)
                    .font(.system(size: 56 * sx))
                    .position(x: 52 * sx, y: 526.83 * sy)

                Text(page.title)
                    .font(.custom("Fredoka One", size: 30 * sx))
                    .foregroundStyle(.white)
                    .position(x: 138.5 * sx, y: 605.41 * sy)

                Text("Draw your garden layout and place every plant with the right spacing.")
                    .font(.system(size: 16 * sx, weight: .regular))
                    .foregroundStyle(.white.opacity(0.85))
                    .lineSpacing(4 * sy)
                    .frame(width: 342 * sx, alignment: .leading)
                    .position(x: 195 * sx, y: 662.91 * sy)
            }
        }
        .ignoresSafeArea(.all, edges: .all)
    }
}

private struct OnboardingPageView: View {
    let page: OnboardingPage
    let pageIndex: Int

    var body: some View {
        ZStack(alignment: .topLeading) {
            RadialGradient(
                gradient: Gradient(colors: page.gradient),
                center: .top,
                startRadius: 20,
                endRadius: 720
            )
            .ignoresSafeArea()

            Color.black.opacity(0.28)
                .ignoresSafeArea()

            if pageIndex == 1 {
                decorativeStars
            }

            if pageIndex == 2 {
                floatingFruits
            }

            if pageIndex == 3 {
                mapGrid
            }

            VStack(alignment: .leading, spacing: 16) {
                Spacer()

                Text(page.emoji)
                    .font(.system(size: 56))

                Text(page.title)
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(.white)

                Text(page.subtitle)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(.white.opacity(0.85))
                    .lineSpacing(4)
                    .padding(.trailing, 18)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 150)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
        }
    }

    private var decorativeStars: some View {
        ZStack {
            ForEach(0..<10, id: \.self) { idx in
                Circle()
                    .fill(Color.white.opacity(idx.isMultiple(of: 2) ? 0.8 : 0.5))
                    .frame(width: CGFloat(4 + idx % 4), height: CGFloat(4 + idx % 4))
                    .shadow(color: Color.yellow.opacity(0.6), radius: 8)
                    .offset(x: CGFloat((idx * 30) % 280), y: CGFloat((idx * 18) % 200))
            }
        }
        .padding(.top, 60)
    }

    private var floatingFruits: some View {
        ZStack {
            Text("🍎 🍓 🍇 🍊 🍒 🍋")
                .font(.system(size: 42))
                .opacity(0.35)
                .rotationEffect(.degrees(-12))
                .offset(x: -24, y: 80)
            Text("🍬 🍭 ⭐")
                .font(.system(size: 52))
                .opacity(0.28)
                .rotationEffect(.degrees(18))
                .offset(x: 30, y: 210)
        }
    }

    private var mapGrid: some View {
        RoundedRectangle(cornerRadius: 20)
            .stroke(Color(hex: "76FF03").opacity(0.35), lineWidth: 1)
            .background(RoundedRectangle(cornerRadius: 20).fill(Color(hex: "0A3C1E").opacity(0.55)))
            .overlay {
                VStack(spacing: 8) {
                    HStack(spacing: 8) { miniCard("🍅", "Tomatoes"); miniCard("🥕", "Carrots"); miniCard("🥒", "Cucumbers") }
                    HStack(spacing: 8) { miniCard("🌿", "Raspberry"); miniCard("🍓", "Strawberry"); miniCard("🧄", "Garlic") }
                }
                .padding(14)
            }
            .frame(width: 320, height: 240)
            .offset(x: 40, y: 60)
    }

    private func miniCard(_ emoji: String, _ title: String) -> some View {
        VStack(spacing: 2) {
            Text(emoji).font(.system(size: 20))
            Text(title)
                .font(.system(size: 8, weight: .semibold))
                .foregroundStyle(.white.opacity(0.82))
        }
        .frame(maxWidth: .infinity)
        .frame(height: 58)
        .background(Color.white.opacity(0.16))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

private struct OnboardingPage {
    let title: String
    let subtitle: String
    let emoji: String
    let gradient: [Color]
}

private extension Color {
    init(hex: String) {
        let cleaned = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&int)

        let a, r, g, b: UInt64
        switch cleaned.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
#Preview { OnboardingTabView() }
