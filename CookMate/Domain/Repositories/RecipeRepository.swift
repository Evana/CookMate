protocol RecipeRepository: Sendable {
    func fetchRecipes(query: RecipeQuery) async throws -> [Recipe]
}
