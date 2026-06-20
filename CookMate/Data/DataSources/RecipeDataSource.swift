protocol RecipeDataSource {
    func fetchRecipes(query: RecipeQuery) async throws -> [RecipeResponse]
}
