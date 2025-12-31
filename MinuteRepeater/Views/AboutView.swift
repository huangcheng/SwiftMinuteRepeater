import SwiftUI

struct AboutView: View {
    var body: some View {
        Spacer()

        VStack {
            Image(nsImage: NSImage(named: "AppIcon")!)
                .resizable()
                .antialiased(true)
                .frame(width: 64, height: 64)

            Spacer()

            Text("Minute Repeater")
                .font(.title2)
                .bold()

            Spacer()

            Text("Version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")")
                .font(.subheadline)

            Spacer()

            Text("Copyright © HUANG Cheng")
                .font(.footnote)

            Spacer()
        }

        Spacer()
    }
}

#Preview {
    AboutView()
}
