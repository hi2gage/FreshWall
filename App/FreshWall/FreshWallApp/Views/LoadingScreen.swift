//
//  LoadingScreen.swift
//  FreshWall
//
//  Created by Claude Code on 11/19/25.
//

import SwiftUI

/// Modern loading screen with animated logo
struct LoadingScreen: View {
    @State private var isAnimating = false
    @State private var opacity: Double = 0

    var body: some View {
        ZStack {
            // Neutral dark background
            Color.neutralDark
                .ignoresSafeArea()

            VStack(spacing: 40) {
                Spacer()

                // FreshWall logo with pulse animation
                Image("BootLogo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: 280)
                    .shadow(
                        color: .freshWallOrange.opacity(isAnimating ? 0.6 : 0.2),
                        radius: isAnimating ? 30 : 15
                    )
                    .scaleEffect(isAnimating ? 1.03 : 1.0)
                    .opacity(opacity)
                    .animation(
                        .easeInOut(duration: 1.8)
                            .repeatForever(autoreverses: true),
                        value: isAnimating
                    )

                Spacer()
            }
        }
        .onAppear {
            withAnimation(.easeIn(duration: 0.6)) {
                opacity = 1
            }
            isAnimating = true
        }
    }
}

#Preview {
    FreshWallPreview {
        LoadingScreen()
    }
}
