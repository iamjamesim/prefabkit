import SwiftUI

struct LabeledPreview<Content: View>: View {
    let label: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(spacing: 0) {
            content()
            Text(label)
                .font(.caption2.weight(.medium))
        }
    }
}
