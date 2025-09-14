//
//  SortButton.swift
//  FreshWall
//
//  Created by Gage Halverson on 6/21/25.
//

import SwiftUI

struct SortButton<Field: SortFieldRepresentable & Codable & Sendable>: View {
    let field: Field
    @Binding var sort: SortState<Field>

    init(
        for field: Field,
        sort: Binding<SortState<Field>>
    ) {
        self.field = field
        _sort = sort
    }

    var body: some View {
        Button {
            sort.toggleOrSelect(field)
        } label: {
            Label(field.label, safeSystemImage: sort.icon(for: field))
        }
    }
}
