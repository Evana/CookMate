final class ConcreteRecipeRepository: RecipeRepository, Sendable {

    private let dataSource: RecipeDataSource

    init(dataSource: RecipeDataSource) {
        self.dataSource = dataSource
    }

    func fetchRecipes(query: RecipeQuery) async throws -> [Recipe] {
        try await dataSource.fetchRecipes(query: query)
            .map { try Recipe(response: $0) }
            .filter { query.matches($0) }
    }
}
