import SwiftUI

struct PlantDetailPlusScreen: View {
    var body: some View {
        ZStack(alignment: .top) {
            RadialGradient(
                colors: [Color.hex("2D1060"), Color.hex("1A0A2E"), Color.hex("0D0518")],
                center: .top,
                startRadius: 20,
                endRadius: 1200
            )
            .ignoresSafeArea(edges: .bottom)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    Color.clear.frame(height: 64)

                    heroBanner
                    growingInfoTitle

                    infoCard(
                        title: "Your Planting Date",
                        text: "21.04.2026",
                        iconAsset: "Icon-1",
                        minHeight: 71.59
                    )

                    infoCard(
                        title: "My Note",
                        text: "lorem ipsum lorem ipsum lorem ipsum lorem ipsum lo",
                        iconAsset: "Icon-5",
                        minHeight: 130.38
                    )
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
            }

            headerBar
        }
    }

    private var headerBar: some View {
        HStack(spacing: 12) {
            Button(action: {}) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Color.hex("FFD700"))
                    .frame(width: 28, height: 28)
            }
            Text("Apple 124")
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

    private var heroBanner: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [Color.hex("2A5C1A"), Color.hex("1A3C0A")], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 90, height: 90)
                    .shadow(color: .black.opacity(0.4), radius: 10, y: 4)
                Text("🌳")
                    .font(.system(size: 44))
            }
            .padding(.top, 18)

            Text("🌳 Apple 124")
                .font(.custom("Fredoka One", size: 26))
                .foregroundStyle(.white)

            Text("Tree")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.hex("76FF03"))
                .padding(.horizontal, 10)
                .frame(height: 26)
                .background(Color.hex("76FF03").opacity(0.12))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.hex("76FF03").opacity(0.3), lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 10))

            Text("📏")
                .font(.system(size: 13))
                .foregroundStyle(Color.hex("FFE066"))

            quickFacts
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 383.5)
        .background(
            LinearGradient(colors: [Color.hex("3D2468"), Color.hex("2D1B4E")], startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.white.opacity(0.18), lineWidth: 1.5)
        )
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: .black.opacity(0.5), radius: 20, y: 12)
    }

    private var quickFacts: some View {
        HStack(spacing: 0) {
            Spacer()
            quickFactColumn(value: "Tree", label: "Category")
            Spacer()
        }
        .frame(height: 77.5)
        .background(Color.white.opacity(0.06))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func quickFactColumn(value: String, label: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.custom("Fredoka One", size: 15))
                .foregroundStyle(Color.hex("FFD700"))
                .multilineTextAlignment(.center)
            Text(label)
                .font(.system(size: 11))
                .foregroundStyle(Color.white.opacity(0.55))
        }
        .padding(.vertical, 17)
    }

    private var growingInfoTitle: some View {
        HStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.hex("FFD700"))
                .frame(width: 3, height: 16)
            Text("Growing Info")
                .font(.custom("Fredoka One", size: 17))
                .foregroundStyle(.white)
            Spacer()
        }
        .frame(height: 26)
    }

    private func infoCard(title: String, text: String, iconAsset: String, minHeight: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Image(iconAsset)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16, height: 16)
                Text(title)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.white.opacity(0.5))
            }
            Text(text)
                .font(.system(size: 14))
                .foregroundStyle(.white)
                .lineSpacing(3)
        }
        .padding(.horizontal, 17)
        .padding(.vertical, 15)
        .frame(maxWidth: .infinity, minHeight: minHeight, alignment: .topLeading)
        .background(Color.white.opacity(0.04))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

#Preview {
    PlantDetailPlusScreen()
}
