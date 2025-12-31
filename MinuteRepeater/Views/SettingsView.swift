import SwiftUI
import KeyboardShortcuts
import ServiceManagement

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
                .onChange(of: autoStart) { _, newValue in
                    if newValue {
                        try? SMAppService.mainApp.register()
                    } else {
                        try? SMAppService.mainApp.unregister()
                    }
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
