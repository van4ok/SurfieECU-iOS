import SwiftUI

struct DashboardPanelModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color(red: 0.035, green: 0.075, blue: 0.115).opacity(0.82))
                    .overlay {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        .white.opacity(0.18),
                                        .blue.opacity(0.14),
                                        .white.opacity(0.06)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    }
                    .shadow(color: .blue.opacity(0.12), radius: 16, x: 0, y: 8)
            }
    }
}

extension View {
    func dashboardPanel() -> some View {
        modifier(DashboardPanelModifier())
    }
}

struct NeonLine: View {
    var body: some View {
        Capsule()
            .fill(
                LinearGradient(
                    colors: [
                        Color.purple.opacity(0.0),
                        Color.purple,
                        Color.blue,
                        Color.purple.opacity(0.0)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(width: 92, height: 4)
            .shadow(color: .purple.opacity(0.75), radius: 6, x: 0, y: 0)
    }
}
