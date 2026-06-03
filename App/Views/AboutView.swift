import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 14) {
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 96, height: 96)
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                Text("MOTOR SURFIE ECU")
                    .font(.title3)
                Text(AppConstants.version)
                    .font(.title3)

                Spacer().frame(height: 24)

                Link("TEL:(+86)13861187887", destination: URL(string: "tel://\(AppConstants.phoneNumber)")!)
                Link(AppConstants.website, destination: AppConstants.websiteURL)

                NavigationLink {
                    ECUDiagnosticsView()
                } label: {
                    Label("ECU Diagnostics", systemImage: "waveform.path.ecg")
                }
                .padding(.top, 8)

                Spacer()

                Text(AppConstants.copyright)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(24)
            .navigationTitle("About")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

private extension AppConstants {
    static var websiteURL: URL {
        URL(string: website)!
    }
}
