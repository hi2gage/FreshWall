import SwiftUI

/// A style modifier for list cells, providing padding, background, and corner radius.
struct ListCellStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(8)
    }
}

extension View {
    /// Applies a standard style for list cells.
    func listCellStyle() -> some View {
        modifier(ListCellStyle())
    }
}