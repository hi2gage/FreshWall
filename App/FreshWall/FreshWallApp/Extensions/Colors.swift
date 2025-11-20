//
//  Colors.swift
//  FreshWall
//
//  Created by Claude on 1/9/25.
//

import SwiftUI

extension Color {
    /// FreshWall Blue - RGB: 27,46,64 - HEX: #1B2E40
    static let freshWallBlue = Color(red: 27 / 255, green: 46 / 255, blue: 64 / 255)

    /// FreshWall Orange - RGB: 243,122,40 - HEX: #F37A28
    static let freshWallOrange = Color(red: 243 / 255, green: 122 / 255, blue: 40 / 255)

    /// FreshWall Teal - RGB: 94,169,154 - HEX: #5EA99A
    static let freshWallTeal = Color(red: 94 / 255, green: 169 / 255, blue: 154 / 255)

    /// Bright Highlight - RGB: 246,247,248 - HEX: #F6F7F8
    static let brightHighlight = Color(red: 246 / 255, green: 247 / 255, blue: 248 / 255)

    /// Neutral Dark - RGB: 165,169,175 - HEX: #A5A9AF
    static let neutralDark = Color(red: 165 / 255, green: 169 / 255, blue: 175 / 255)

    /// FreshWall Black - RGB: 0,0,0 - HEX: #000000
    static let freshWallBlack = Color(red: 0, green: 0, blue: 0)

    /// Brand colors for different contexts
    static let brandPrimary = freshWallOrange
    static let brandSecondary = freshWallBlue
    static let brandAccent = freshWallTeal
}

extension UIColor {
    /// UIKit version of FreshWall Blue
    static let freshWallBlue = UIColor(red: 27 / 255, green: 46 / 255, blue: 64 / 255, alpha: 1.0)

    /// UIKit version of FreshWall Orange
    static let freshWallOrange = UIColor(red: 243 / 255, green: 122 / 255, blue: 40 / 255, alpha: 1.0)

    /// UIKit version of FreshWall Teal
    static let freshWallTeal = UIColor(red: 94 / 255, green: 169 / 255, blue: 154 / 255, alpha: 1.0)

    /// UIKit version of Bright Highlight
    static let brightHighlight = UIColor(red: 246 / 255, green: 247 / 255, blue: 248 / 255, alpha: 1.0)

    /// UIKit version of Neutral Dark
    static let neutralDark = UIColor(red: 165 / 255, green: 169 / 255, blue: 175 / 255, alpha: 1.0)

    /// UIKit version of FreshWall Black
    static let freshWallBlack = UIColor(red: 0, green: 0, blue: 0, alpha: 1.0)

    /// Brand colors for UIKit
    static let brandPrimary = freshWallOrange
    static let brandSecondary = freshWallBlue
    static let brandAccent = freshWallTeal
}
