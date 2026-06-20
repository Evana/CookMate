protocol RecipeDataSource {
    func fetchRecipes() async throws -> [RecipeResponse]
}
