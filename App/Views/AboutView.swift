import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("appLanguage") private var appLanguageRaw = AppLanguage.russian.rawValue

    private var language: AppLanguage { AppLanguage.from(appLanguageRaw) }

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

                Picker(languageTitle, selection: $appLanguageRaw) {
                    ForEach(AppLanguage.allCases) { language in
                        Text(language.title).tag(language.rawValue)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.top, 8)

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
            .navigationTitle(aboutTitle)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(doneTitle) { dismiss() }
                }
            }
        }
    }

    private var aboutTitle: String {
        switch language {
        case .english: "About"
        case .russian: "\u{041E} \u{043F}\u{0440}\u{0438}\u{043B}\u{043E}\u{0436}\u{0435}\u{043D}\u{0438}\u{0438}"
        }
    }

    private var doneTitle: String {
        switch language {
        case .english: "Done"
        case .russian: "\u{0413}\u{043E}\u{0442}\u{043E}\u{0432}\u{043E}"
        }
    }

    private var languageTitle: String {
        switch language {
        case .english: "Language"
        case .russian: "\u{042F}\u{0437}\u{044B}\u{043A}"
        }
    }
}

private extension AppConstants {
    static var websiteURL: URL {
        URL(string: website)!
    }
}
