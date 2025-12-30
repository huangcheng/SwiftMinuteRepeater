import SwiftUI
import AppKit
import AVFoundation
import KeyboardShortcuts

@main
struct MinuteRepeaterApp: App {
    @Environment(\.openWindow) var openWindow
    
    @State private var appState = AppState()
    
    init() {
        checkInstance()
    }
    
    var body: some Scene {
        MenuBarExtra("Minute Repeater", image: "TrayIcon") {
            Button("Settings") {
                openWindow(id: "settings")
            }
            
            Button("About") {
                appState.chiming()
            }
            
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
        }
        
        Window("Settings", id: "settings") {
            SettingsView()
                .frame(
                    minWidth: 320,
                    maxWidth: 320,
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
        
        return rider.getData()
    }
    
    func chiming() {
        if audioDelegate.isPlaying {
            return
        }
        
        let waveData = getWaveDataForTime()
        
        try? audioPlayer = AVAudioPlayer(data: waveData, fileTypeHint: AVFileType.wav.rawValue)
        
        audioPlayer?.delegate = audioDelegate
        
        audioDelegate.isPlaying = true
        
        audioPlayer?.play()
    }
}


final class AppAudioDelegate: NSObject, AVAudioPlayerDelegate {
    var isPlaying: Bool = false
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
    }
}
