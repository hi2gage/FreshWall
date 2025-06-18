import SwiftUI

extension View {
    /// Presents a sheet and performs asynchronous work when the sheet is dismissed.
    /// - Parameters:
    ///   - isPresented: Binding controlling the sheet's presentation.
    ///   - onDismiss: Async closure executed when the sheet is dismissed.
    ///   - content: View builder producing the sheet's content.
    /// - Returns: A view that presents a sheet.
    func asyncSheet<Content: View>(
        isPresented: Binding<Bool>,
        onDismiss: @escaping () async -> Void,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        sheet(isPresented: isPresented, onDismiss: {
            Task { await onDismiss() }
        }, content: content)
    }
}
