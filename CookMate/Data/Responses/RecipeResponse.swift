struct RecipeResponse: Decodable {
    let id: String
    let title: String
    let description: String
    let servings: Int
    let ingredients: [IngredientResponse]
    let instructions: [String]
    let dietaryTags: [String]
}
