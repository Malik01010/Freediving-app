import SwiftUI

// Reusable primary/secondary action button style
struct ActionButton: View {
    let title: String
    enum Style { case primary, secondary }
    let style: Style

    var body: some View {
        Text(title)
            .font(.appSubheadline)
            .fontWeight(.semibold)
            .foregroundStyle(style == .primary ? Color.appBackground : Color.appTeal)
            .frame(maxWidth: .infinity)
            .padding(Spacing.md)
            .background(style == .primary ? Color.appTeal : Color.appCard)
            .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: Radius.lg)
                    .stroke(style == .secondary ? Color.appTeal.opacity(0.4) : Color.clear, lineWidth: 1)
            )
    }
}
