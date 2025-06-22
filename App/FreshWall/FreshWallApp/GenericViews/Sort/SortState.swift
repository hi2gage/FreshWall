//
//  SortState.swift
//  FreshWall
//
//  Created by Gage Halverson on 6/21/25.
//

struct SortState<Field: Equatable>: Equatable {
    var field: Field
    var isAscending: Bool

    mutating func toggleOrSelect(_ newField: Field) {
        if field == newField {
            isAscending.toggle()
        } else {
            field = newField
            isAscending = true
        }
    }

    func icon(for field: Field) -> String? {
        guard self.field == field else { return nil }
        return isAscending ? "arrow.up" : "arrow.down"
    }

    func isSelected(_ field: Field) -> Bool {
        self.field == field
    }
}
