import AudioToolbox

enum ClickSound {
    static func play() {
        AudioServicesPlaySystemSound(1104)
    }
}
