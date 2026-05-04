import SwiftUI

struct NewPlantSavedScreen: View {
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
                .padding(.bottom, 20)
            }

            headerBar

            // Success overlay per CSS state.
            GeometryReader { geometry in
                ZStack {
                    Color.hex("1A0A2E")
                        .opacity(0.85)
                        .ignoresSafeArea()

                    VStack(spacing: 14) {
                        Text("🌱")
                            .font(.system(size: 76))
                        Text("Plant Saved!")
                            .font(.custom("Fredoka One", size: 28))
                            .foregroundStyle(Color.hex("76FF03"))
                    }
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                }
            }
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
            Text("🌳")
                .font(.system(size: 48))
                .frame(height: 72)
                .padding(.top, 18)
            Text("New Plant")
                .font(.custom("Fredoka One", size: 20))
                .foregroundStyle(.white)
            Text("Tree · No date set")
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
        formSection(label: requiredLabel("Plant Name")) {
            formInput(iconAsset: nil, placeholder: "e.g. Apple tree by the fence")
        }
    }

    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            requiredLabel("Category")

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    categoryChip("🌳", "Tree", active: true)
                    categoryChip("🌿", "Shrub")
                    categoryChip("🍇", "Vine")
                    categoryChip("🍓", "Berry")
                    categoryChip("🥕", "Vegetable")
                }
            }
        }
    }

    private func categoryChip(_ emoji: String, _ title: String, active: Bool = false) -> some View {
        VStack(spacing: 6) {
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
    }

    private var plantingDateField: some View {
        formSection(label: requiredLabel("Planting Date")) {
            formInput(iconAsset: "Icon-61", placeholder: "Select planting date…")
        }
    }

    private var photoUpload: some View {
        formSection(label: Text("Photo (optional)")
            .font(.system(size: 13, weight: .semibold))
            .foregroundColor(Color.white.opacity(0.7))) {
            VStack(spacing: 6) {
                Image(systemName: "photo")
                    .font(.system(size: 24))
                    .foregroundStyle(Color.white.opacity(0.3))
                Text("Tap to upload photo")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.white.opacity(0.35))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 100)
            .background(Color.white.opacity(0.04))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.white.opacity(0.2), style: StrokeStyle(lineWidth: 1.5, dash: [3, 3]))
            )
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }

    private var noteField: some View {
        formSection(label: Text("Note (optional)")
            .font(.system(size: 13, weight: .semibold))
            .foregroundColor(Color.white.opacity(0.7))) {
            Text("Add any notes about this plant...")
                .font(.system(size: 15))
                .foregroundStyle(Color.white.opacity(0.5))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .padding(14)
                .frame(height: 98.5)
                .background(Color.white.opacity(0.07))
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.15), lineWidth: 1.5))
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }

    private var saveButton: some View {
        Button(action: {}) {
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
        }
    }

    private func formSection<Label: View, Content: View>(label: Label, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            label
            content()
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

    private func formInput(iconAsset: String?, placeholder: String) -> some View {
        HStack(spacing: 10) {
            if let iconAsset {
                Image(iconAsset)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16, height: 16)
            }
            Text(placeholder)
                .font(.system(size: 15, weight: iconAsset == nil ? .regular : .medium))
                .foregroundStyle(Color.white.opacity(0.5))
            Spacer()
        }
        .padding(.horizontal, 16)
        .frame(height: 52)
        .background(Color.white.opacity(0.07))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.15), lineWidth: 1.5))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

#Preview {
    NewPlantSavedScreen()
}
