//
//  Colors.swift
//  FreshWall
//
//  Created by Claude on 1/9/25.
//

import SwiftUI

extension Color {
    /// FreshWall brand green color (#22c55e)
    static let brandGreen = Color(red: 0.133, green: 0.773, blue: 0.369)

    /// FreshWall brand dark green color (#16a34a)
    static let brandGreenDark = Color(red: 0.086, green: 0.639, blue: 0.290)

    /// Brand colors for different contexts
    static let brandPrimary = brandGreen
    static let brandPrimaryDark = brandGreenDark
}

extension UIColor {
    /// UIKit version of brand green for navigation and system components
    static let brandGreen = UIColor(red: 0.133, green: 0.773, blue: 0.369, alpha: 1.0)

    /// UIKit version of brand dark green
    static let brandGreenDark = UIColor(red: 0.086, green: 0.639, blue: 0.290, alpha: 1.0)
}
