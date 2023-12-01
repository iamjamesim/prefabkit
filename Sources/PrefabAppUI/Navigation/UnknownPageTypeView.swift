import SwiftUI

struct UnknownPageTypeView: View {
    var body: some View {
        VStack(spacing: 24) {
            Text("Unknown page type")
                .font(.title.weight(.semibold))
                .foregroundColor(AppColor.contentPrimary.color)
            Text("This page type is not supported in this version of the app. To access this page, please update to the latest version.")
                .font(.body)
                .foregroundColor(AppColor.contentPrimary.color)
        }
        .padding(24)
    }
}
