protocol RecipeRepository {
    func fetchRecipes(query: RecipeQuery) async throws -> [Recipe]
}
