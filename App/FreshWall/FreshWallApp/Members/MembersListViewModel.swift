import Observation

/// ViewModel responsible for member list presentation and data operations.
@MainActor
@Observable
final class MembersListViewModel {
    /// Team members fetched from the service.
    var members: [Member] = []
    /// Selected grouping option for the list.
    var groupOption: MemberGroupOption?
    /// Sort state for members.
    var sort: SortState<MemberSortField> = .init(field: .alphabetical, isAscending: true) {
        didSet {
            if oldValue != sort {
                userSelectedSort = true
            }
        }
    }

    /// Indicates whether the user manually changed the sort order.
    var userSelectedSort = false

    private let service: MemberServiceProtocol
    private let currentUserId: String

    /// Initializes the view model with a service conforming to `MemberServiceProtocol` and the current user id.
    init(service: MemberServiceProtocol, currentUserId: String) {
        self.service = service
        self.currentUserId = currentUserId
    }

    /// Loads members from the service.
    func loadMembers() async {
        members = await (try? service.fetchMembers()) ?? []
    }

    /// Returns members grouped and sorted based on the selected options.
    func groupedMembers() -> [(title: String?, items: [Member])] {
        switch groupOption {
        case .role:
            let groups = Dictionary(grouping: members) { $0.role.displayName }
            return groups
                .map { key, value in
                    (title: key, items: sortMembers(value))
                }
                .sorted { lhs, rhs in
                    let lhsTitle = lhs.title ?? ""
                    let rhsTitle = rhs.title ?? ""
                    // Sort by role hierarchy level instead of alphabetically
                    let lhsLevel = value(for: lhsTitle)?.role.hierarchyLevel ?? 0
                    let rhsLevel = value(for: rhsTitle)?.role.hierarchyLevel ?? 0
                    return sort.isAscending ? lhsLevel > rhsLevel : lhsLevel < rhsLevel
                }
        case nil:
            let sorted = sortedMembers()
            return [(nil, sorted)]
        }
    }

    /// Helper to get a member by role display name
    private func value(for roleDisplayName: String) -> Member? {
        members.first { $0.role.displayName == roleDisplayName }
    }

    /// Returns members sorted based on the current sort field and direction.
    func sortedMembers() -> [Member] {
        var result = sortMembers(members)

        if !userSelectedSort, sort.field == .alphabetical, groupOption == nil {
            if let index = result.firstIndex(where: { $0.id == currentUserId }) {
                let current = result.remove(at: index)
                result.insert(current, at: 0)
            }
        }

        return result
    }

    private func sortMembers(_ items: [Member]) -> [Member] {
        switch sort.field {
        case .alphabetical:
            items.sorted { lhs, rhs in
                if sort.isAscending {
                    lhs.displayName < rhs.displayName
                } else {
                    lhs.displayName > rhs.displayName
                }
            }
        case .role:
            items.sorted { lhs, rhs in
                let lhsLevel = lhs.role.hierarchyLevel
                let rhsLevel = rhs.role.hierarchyLevel
                if sort.isAscending {
                    return lhsLevel > rhsLevel // Higher level first when ascending
                } else {
                    return lhsLevel < rhsLevel // Lower level first when descending
                }
            }
        }
    }
}
