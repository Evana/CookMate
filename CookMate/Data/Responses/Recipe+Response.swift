import Foundation

extension Recipe {
    init(response: RecipeResponse) throws {
        guard let id = UUID(uuidString: response.id) else {
            throw RecipeError.decodingFailed
        }
        self.init(
            id: id,
            title: response.title,
            description: response.description,
            servings: response.servings,
            ingredients: response.ingredients.map {
                Ingredient(name: $0.name, quantity: $0.quantity)
            },
            instructions: response.instructions,
            dietaryTags: response.dietaryTags.compactMap { DietaryTag(rawValue: $0) }
        )
    }
}
