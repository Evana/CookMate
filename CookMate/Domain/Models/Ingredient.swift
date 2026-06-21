import Foundation

struct Ingredient: Identifiable, Hashable, Sendable {
    let id: UUID
    let name: String
    let quantity: String
}
