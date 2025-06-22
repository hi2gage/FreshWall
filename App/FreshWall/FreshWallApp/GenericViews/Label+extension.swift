//
//  Label+extension.swift
//  FreshWall
//
//  Created by Gage Halverson on 6/21/25.
//

import SwiftUI

extension Label where Title == Text, Icon == Image {
    /// Creates a `Label` whose icon is the SF symbol named `systemImage`
    /// – **only if** that symbol actually exists on the running OS.
    ///
    /// If `systemImage` is `nil`, empty, or unavailable, the label is rendered
    /// without an icon.
    nonisolated public init(
        _ titleKey: LocalizedStringKey,
        systemImage name: String?
    ) {
        // Is the string non-empty *and* does the symbol exist in this OS build?
        if let name, !name.isEmpty, UIImage(systemName: name) != nil {
            self.init(titleKey, systemImage: name)
        } else {
            self.init {
                Text(titleKey)
            } icon: {
                Image(uiImage: UIImage())          // 0 × 0 transparent image
            }
        }
    }
}
