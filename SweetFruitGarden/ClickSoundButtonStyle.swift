import SwiftUI

struct ClickSoundButtonStyle: PrimitiveButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button {
            ClickSound.play()
            configuration.trigger()
        } label: {
            configuration.label
        }
    }
}
