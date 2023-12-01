import SwiftUI

struct PreviewVariants<PreviewView: View>: View {
    @ViewBuilder let previewView: () -> PreviewView

    var body: some View {
        Group {
            previewView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemBackground))
                .environment(\.colorScheme, .light)
                .previewDisplayName("Light Mode")
            previewView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemBackground))
                .environment(\.colorScheme, .dark)
                .previewDisplayName("Dark Mode")
        }
    }
}
