import SwiftUI
import KeyboardShortcuts
import ServiceManagement

struct SettingsView: View {
    @AppStorage("autoStart") var autoStart: Bool = false
    @Binding var chimingMode: ChimingMode

    var body: some View {
        Spacer()
        HStack {
            Spacer()
            Form {
                Spacer()

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

                Spacer()

                KeyboardShortcuts.Recorder("Chiming Shortcut:", name: .triggerChiming)

                Spacer()

                Picker("Chiming Mode:", selection: $chimingMode) {
                    Text("Off").tag(ChimingMode.off)
                    Text("Minutely").tag(ChimingMode.minutely)
                    Text("Quarterly").tag(ChimingMode.quarterly)
                    Text("Half-Hourly").tag(ChimingMode.halfHourly)
                    Text("Hourly").tag(ChimingMode.hourly)
                }

                Spacer()
            }
            .toggleStyle(.switch)
            Spacer()
        }
        Spacer()
    }
}

#Preview {
    @Previewable @State var chimingMode: ChimingMode = .off

    SettingsView(chimingMode: $chimingMode)
}
