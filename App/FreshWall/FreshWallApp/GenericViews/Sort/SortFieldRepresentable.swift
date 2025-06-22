//
//  SortFieldRepresentable.swift
//  FreshWall
//
//  Created by Gage Halverson on 6/21/25.
//

protocol SortFieldRepresentable: Equatable {
    var label: String { get }
    func icon(isSelected: Bool, isAscending: Bool) -> String?
}
