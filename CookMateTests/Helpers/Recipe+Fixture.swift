@testable import CookMate
import Foundation

extension Recipe {
    static func fixture(
        id: UUID = UUID(),
        title: String = "Test Recipe",
        description: String = "A test description",
        servings: Int = 4,
        ingredients: [Ingredient] = [Ingredient(name: "flour", quantity: "200g")],
        instructions: [String] = ["Step one"],
        dietaryTags: [DietaryTag] = []
    ) -> Recipe {
        Recipe(
            id: id, title: title, description: description,
            servings: servings, ingredients: ingredients,
            instructions: instructions, dietaryTags: dietaryTags
        )
    }
}
