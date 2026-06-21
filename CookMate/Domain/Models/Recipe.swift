import Foundation

struct Recipe: Identifiable, Hashable, Sendable {
    let id: UUID
    let title: String
    let description: String
    let servings: Int
    let ingredients: [Ingredient]
    let instructions: [String]
    let dietaryTags: [DietaryTag]
}
