import SwiftUI

struct PlantAddScreen: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                // Base PlantDetail-like background.
                PlantDetailScreen()
                    .ignoresSafeArea(edges: .bottom)

                // Global dark overlay from CSS (PlantDetail mask).
                Color.hex("0D0518")
                    .opacity(0.8)
                    .ignoresSafeArea()

                // Center popup adaptively across device heights (SE/Pro Max).
                addPopup
                    .padding(.horizontal, 24)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .padding(.top, max((geometry.size.height - 307.5) / 2, 90))
            }
        }
    }

    private var addPopup: some View {
        VStack(spacing: 0) {
            VStack(spacing: 8) {
                Text("🍎")
                    .font(.system(size: 40))
                    .frame(height: 60)
                Text("Add to My Garden")
                    .font(.custom("Fredoka One", size: 20))
                    .foregroundStyle(.white)
                Text("Give your plant a nickname")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.white.opacity(0.55))
            }
            .padding(.top, 26)

            TextField("", text: .constant("Apple Tree"))
                .font(.system(size: 15))
                .foregroundStyle(Color.white.opacity(0.5))
                .padding(.horizontal, 16)
                .frame(height: 52)
                .background(Color.white.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.hex("FFD700").opacity(0.4), lineWidth: 1.5)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.hex("FFD700").opacity(0.1), lineWidth: 6)
                )
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .padding(.horizontal, 24)
                .padding(.top, 16)

            HStack(spacing: 12) {
                Button(action: {}) {
                    Text("Cancel")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.white.opacity(0.7))
                        .frame(width: 95, height: 48)
                        .background(Color.white.opacity(0.07))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.white.opacity(0.15), lineWidth: 1.5)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }

                Button(action: {}) {
                    Text("🌿 Add to Garden")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 187, height: 48)
                        .background(
                            LinearGradient(
                                colors: [Color.hex("FFBB7A"), Color.hex("FF8040"), Color.hex("FF6B35"), Color.hex("C84000")],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.hex("FFDCA6").opacity(0.5), lineWidth: 1.5)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .shadow(color: Color.hex("FF6B35").opacity(0.5), radius: 10, y: 4)
                }
            }
            .padding(.top, 16)
            .padding(.horizontal, 24)
        }
        .frame(height: 307.5)
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(colors: [Color.hex("3D2468"), Color.hex("2D1B4E")], startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.white.opacity(0.2), lineWidth: 1.5)
        )
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: .black.opacity(0.6), radius: 24, y: 12)
    }
}

#Preview {
    PlantAddScreen()
}
