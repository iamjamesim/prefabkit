import SwiftUI

/// A standard loading error view with a retry button.
public struct LoadingErrorView: View {
    /// A closure that triggers a reload.
    let reload: () -> Void

    /// Creates a new `LoadingErrorView` instance.
    /// - Parameter reload: A closure that triggers a reload.
    public init(reload: @escaping () -> Void) {
        self.reload = reload
    }

    public var body: some View {
        VStack(spacing: 16) {
            Text("Loading error", comment: "Loading error message")
            Button {
                reload()
            } label: {
                Text("Retry", comment: "Load retry button title")
                    .foregroundColor(AppColor.buttonPrimaryForeground.color)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(AppColor.buttonPrimaryBackground.color)
                    )
            }
        }
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity)
    }
}
