import SwiftUI

struct UnavailableFeaturesView: View {
    var body: some View {
        List(RecoverabilityNote.allCases) { note in
            Text("ASSUMPTION: \(note.rawValue)")
        }
        .navigationTitle("Recovered Scope")
    }
}
