import SwiftUI
import AppKit
import AVFoundation
import Synchronization
import KeyboardShortcuts
import Combine

@main
struct MinuteRepeaterApp: App {
    @Environment(\.openWindow) var openWindow

    @State private var appState = AppState()
    @AppStorage("chimingMode") var chimingMode: ChimingMode = .off
    @State private var lastChimedMinute: Int?

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    init() {
        checkInstance()
    }

    var body: some Scene {
        MenuBarExtra(String(localized: "Minute Repeater", comment: "App Name"), image: "TrayIcon") {
            Button(String(localized: "Settings", comment: "Settings Menu Item"), systemImage: "gearshape") {
                openWindow(id: "settings")
            }
            .keyboardShortcut(",", modifiers: .command)

            Divider()

            Button(String(localized: "About", comment: "About Menu Item"), systemImage: "info.circle") {
                openWindow(id: "about")
            }
            .keyboardShortcut("a", modifiers: .command)

            Divider()

            Button(String(localized: "Quit", comment: "Quit Menu Item"), systemImage: "xmark.circle") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q", modifiers: .command)
            .onReceive(timer) { date in
                let minute = Calendar.current.component(.minute, from: date)
                let hour = Calendar.current.component(.hour, from: date)
                let shouldChime: Bool

                switch chimingMode {
                    case .minutely:
                        shouldChime = true
                    case .quarterly:
                        shouldChime = minute % 15 == 0
                    case .halfHourly:
                        shouldChime = minute == 0 || minute == 30
                    case .hourly:
                        shouldChime = minute == 0
                    default:
                        shouldChime = false
                }
                if shouldChime {
                    let currentKey = hour * 60 + minute
                    if lastChimedMinute != currentKey {
                        appState.chiming()
                        lastChimedMinute = currentKey
                    }
                } else {
                    lastChimedMinute = nil
                }
            }
        }

        Window(String(localized: "Settings", comment: "Settings Window"), id: "settings") {
            SettingsView(chimingMode: $chimingMode)
                .frame(
                    minWidth: 320,
                    maxWidth: 320,
                    minHeight: 160,
                    maxHeight: 160
                )
        }
        .windowResizability(.contentSize)

        Window(String(localized: "About", comment: "About Window"), id: "about") {
            AboutView()
                .frame(
                    minWidth: 260,
                    maxWidth: 260,
                    minHeight: 160,
                    maxHeight: 160
                )
        }
        .windowResizability(.contentSize)

    }

    private func checkInstance() {
        let runningInstances = NSRunningApplication.runningApplications(withBundleIdentifier: Bundle.main.bundleIdentifier!)

        if runningInstances.count > 1 {
            NSApp.terminate(nil)
        }
    }
}

@MainActor
@Observable
final class AppState {
    private var audioPlayer: AVAudioPlayer?
    private var audioDelegate = AppAudioDelegate()

    private var hour: Data = NSDataAsset(name: "Audio/hour")!.data
    private var quarter: Data = NSDataAsset(name: "Audio/quarter")!.data
    private var minute: Data = NSDataAsset(name: "Audio/minute")!.data

    private var cachedWaveData: [String: Data] = [:]

    init() {
        KeyboardShortcuts.onKeyUp(for: .triggerChiming) { [self] in
            chiming()
        }
    }

    private func convertCurrentTimeToHQM() -> (Int, Int, Int) {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: Date())

        let _hour = components.hour ?? 0

        var hour = _hour % 12

        if hour == 0 && _hour != 0 {
            hour = 12
        }

        let minute = components.minute ?? 0
        let quarter = minute / 15
        let minuteRemainder = minute % 15

        return (hour, quarter, minuteRemainder)
    }

    private func getWaveDataForTime() -> Data {
        let (hourCount, quarterCount, minuteCount) = convertCurrentTimeToHQM()

        let cacheKey = "\(hourCount)-\(quarterCount)-\(minuteCount)"

        if let cachedData = cachedWaveData[cacheKey] {
            return cachedData
        }

        let rider = WaveRider()

        for _ in 0..<hourCount {
            rider.append(waveData: hour)
        }

        for _ in 0..<quarterCount {
            rider.append(waveData: quarter)
        }

        for _ in 0..<minuteCount {
            rider.append(waveData: minute)
        }

        cachedWaveData[cacheKey] = rider.getData()

        return cachedWaveData[cacheKey]!
    }

    func chiming() {
        if audioDelegate.isPlaying.load(ordering: .relaxed) {
            return
        }

        let waveData = getWaveDataForTime()

        try? audioPlayer = AVAudioPlayer(data: waveData, fileTypeHint: AVFileType.wav.rawValue)

        audioPlayer?.delegate = audioDelegate

        audioDelegate.isPlaying.store(true, ordering: .relaxed)

        audioPlayer?.play()
    }
}

final class AppAudioDelegate: NSObject, AVAudioPlayerDelegate {
    let isPlaying = Atomic<Bool>(false)

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying.store(false, ordering: .relaxed)
    }
}
