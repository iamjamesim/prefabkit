import SwiftUI

struct ScrollContentFrameObserver: View {
    let coordinateSpace: CoordinateSpace
    let onContentFrameChange: (CGRect) -> Void

    var body: some View {
        GeometryReader { geometry in
            Color.clear.preference(
                key: ScrollContentFramePreferenceKey.self,
                value: geometry.frame(in: coordinateSpace)
            )
        }
        .onPreferenceChange(ScrollContentFramePreferenceKey.self) { frame in
            onContentFrameChange(frame)
        }
    }
}

private struct ScrollContentFramePreferenceKey: PreferenceKey {
    static var defaultValue: CGRect { .zero }
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
    }
}
