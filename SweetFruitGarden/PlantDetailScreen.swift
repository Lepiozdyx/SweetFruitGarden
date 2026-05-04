import SwiftUI

struct PlantDetailScreen: View {
    var plant: PlantDefinition = PlantDefinition.fullLibrary.first!
    var myPlant: MyPlant? = nil
    var onBack: (() -> Void)? = nil
    var onAdd: (() -> Void)? = nil

    var body: some View {
        ZStack(alignment: .top) {
            RadialGradient(
                colors: [Color.hex("2D1060"), Color.hex("1A0A2E"), Color.hex("0D0518")],
                center: .top,
                startRadius: 20,
                endRadius: 1200
            )

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    Color.clear.frame(height: 64)

                    heroBanner

                    growingInfoTitle

                    infoCard(
                        title: "Planting Time",
                        text: plant.plantingSeason,
                        iconAsset: "Icon-1",
                        minHeight: 71.6
                    )

                    infoCard(
                        title: "Spacing",
                        text: plant.spacingText,
                        iconAsset: "Icon-2",
                        minHeight: 71.6
                    )

                    infoCard(
                        title: "Harvest",
                        text: plant.harvestText,
                        iconAsset: "Icon-3",
                        minHeight: 91.2
                    )

                    infoCard(
                        title: "Requirements",
                        text: plant.requirements,
                        iconAsset: "Icon-4",
                        minHeight: 71.6
                    )

                    infoCard(
                        title: "Care Tips",
                        text: plant.careTemplate.joined(separator: ". "),
                        iconAsset: "Icon-5",
                        minHeight: 110.8
                    )
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 140)
            }

            headerBar
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
            Text(displayName)
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
                if let photoData = myPlant?.photoData, let image = UIImage(data: photoData) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 82, height: 82)
                        .clipShape(Circle())
                } else {
                    Text(plant.emoji)
                        .font(.system(size: 44))
                }
            }
            .padding(.top, 18)

            Text(displayName)
                .font(.custom("Fredoka One", size: 26))
                .foregroundStyle(.white)

            Text(plant.category.rawValue)
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

            Text("📏 \(plant.spacingText)")
                .font(.system(size: 13))
                .foregroundStyle(Color.hex("FFE066"))

            quickFacts

            Button(action: { onAdd?() }) {
                Text("🌿 ADD TO MY GARDEN")
                    .font(.custom("Fredoka One", size: 16))
                    .tracking(0.8)
                    .foregroundStyle(Color.hex("3A2000"))
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        LinearGradient(
                            colors: [Color.hex("FFF0A0"), Color.hex("FFE040"), Color.hex("FFD700"), Color.hex("D4A800"), Color.hex("AA8000")],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.hex("FFF096").opacity(0.4), lineWidth: 1.5)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: Color.hex("FFD700").opacity(0.6), radius: 14, y: 8)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity)
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
            quickFactColumn(value: plant.category.rawValue, label: "Category")
            divider
            quickFactColumn(value: plant.plantingSeason, label: "Season")
            divider
            quickFactColumn(value: plant.harvestText, label: "Harvest")
        }
        .frame(height: 132)
        .background(Color.white.opacity(0.06))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal, 24)
    }

    private var divider: some View {
        Rectangle()
            .fill(Color.white.opacity(0.1))
            .frame(width: 1, height: 96)
    }

    private func quickFactColumn(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.custom("Fredoka One", size: 15))
                .foregroundStyle(Color.hex("FFD700"))
                .multilineTextAlignment(.center)
            Spacer().frame(height: label == "Harvest" ? 4 : 8)
            Text(label)
                .font(.system(size: 11))
                .foregroundStyle(Color.white.opacity(0.55))
        }
        .frame(maxWidth: .infinity)
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

    private var displayName: String {
        let nick = myPlant?.nickname.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return nick.isEmpty ? "Unnamed Plant" : nick
    }
}

#Preview {
    PlantDetailScreen(plant: PlantDefinition.fullLibrary[0])
}
