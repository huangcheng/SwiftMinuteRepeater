import SwiftUI
import KeyboardShortcuts

struct SettingsView: View {
    @AppStorage("autoStart") var autoStart: Bool = false
    
    var body: some View {
       Spacer()
        HStack {
            Spacer()
            Form {
                Toggle(isOn: $autoStart) {
                    Text("Launch at Login:")
                }
                
                KeyboardShortcuts.Recorder("Chiming Shortcut:", name: .triggerChiming)
            }
            .toggleStyle(.switch)
            Spacer()
        }
        Spacer()
    }
}

#Preview {
    SettingsView()
}
