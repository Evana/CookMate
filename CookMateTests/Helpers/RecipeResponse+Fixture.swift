@testable import CookMate

extension RecipeResponse {
    static func fixture(
        id: String = "00000000-0000-0000-0000-000000000001",
        title: String = "Test Recipe",
        description: String = "A test recipe description",
        servings: Int = 4,
        ingredients: [IngredientResponse] = [IngredientResponse(name: "flour", quantity: "200g")],
        instructions: [String] = ["Step one", "Step two"],
        dietaryTags: [String] = []
    ) -> RecipeResponse {
        RecipeResponse(
            id: id,
            title: title,
            description: description,
            servings: servings,
            ingredients: ingredients,
            instructions: instructions,
            dietaryTags: dietaryTags
        )
    }
}
