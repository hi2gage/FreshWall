import Foundation

public protocol AuthRepository {
    func signIn(email: String, password: String) async throws -> AuthenticatedUser
    func signUp(email: String, password: String) async throws -> AuthenticatedUser
    func signOut() async throws
    func getCurrentUser() async -> AuthenticatedUser?
}
