protocol RecipeDataSource: Sendable {
    func fetchRecipes(query: RecipeQuery) async throws -> [RecipeResponse]
}
