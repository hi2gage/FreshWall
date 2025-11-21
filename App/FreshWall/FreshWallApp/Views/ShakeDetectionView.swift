import SwiftUI
import UIKit

// MARK: - ShakeDetectionViewRepresentable

/// A UIViewRepresentable that detects device shake gestures
struct ShakeDetectionViewRepresentable: UIViewRepresentable {
    let onShake: () -> Void

    func makeUIView(context _: Context) -> ShakeDetectionUIView {
        let view = ShakeDetectionUIView()
        view.onShake = onShake
        return view
    }

    func updateUIView(_ uiView: ShakeDetectionUIView, context _: Context) {
        uiView.onShake = onShake
    }
}

// MARK: - ShakeDetectionUIView

/// UIView subclass that can become first responder to detect shake gestures
class ShakeDetectionUIView: UIView {
    var onShake: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isUserInteractionEnabled = false
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        becomeFirstResponder()
    }

    override var canBecomeFirstResponder: Bool {
        true
    }

    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            onShake?()
        }
        super.motionEnded(motion, with: event)
    }
}

// MARK: - ShakeDetectionModifier

/// SwiftUI ViewModifier that adds shake detection to any view
struct ShakeDetectionModifier: ViewModifier {
    let onShake: () -> Void

    func body(content: Content) -> some View {
        content
            .background(
                #if DEBUG
                    ShakeDetectionViewRepresentable(onShake: onShake)
                        .allowsHitTesting(false)
                #endif
            )
    }
}

// MARK: - View Extension

extension View {
    /// Adds shake gesture detection to the view
    func onShake(perform action: @escaping () -> Void) -> some View {
        modifier(ShakeDetectionModifier(onShake: action))
    }
}
