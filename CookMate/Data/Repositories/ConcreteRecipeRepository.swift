final class ConcreteRecipeRepository: RecipeRepository {

    private let dataSource: RecipeDataSource

    init(dataSource: RecipeDataSource) {
        self.dataSource = dataSource
    }

    func fetchRecipes(query: RecipeQuery) async throws -> [Recipe] {
        let recipes = try await dataSource.fetchRecipes(query: query).map { try Recipe(response: $0) }
        return recipes.filter { matches($0, query: query) }
    }

    private func matches(_ recipe: Recipe, query: RecipeQuery) -> Bool {
        if !query.searchText.isEmpty {
            let text = query.searchText.lowercased()
            let inTitle = recipe.title.lowercased().contains(text)
            let inInstructions = recipe.instructions.joined().lowercased().contains(text)
            guard inTitle || inInstructions else { return false }
        }

        if let min = query.minServings {
            guard recipe.servings >= min else { return false }
        }

        if !query.dietaryTags.isEmpty {
            guard query.dietaryTags.allSatisfy({ recipe.dietaryTags.contains($0) }) else { return false }
        }

        if !query.includeIngredients.isEmpty {
            let names = recipe.ingredients.map { $0.name.lowercased() }
            guard query.includeIngredients.allSatisfy({ inc in
                names.contains(where: { $0.contains(inc.lowercased()) })
            }) else { return false }
        }

        if !query.excludeIngredients.isEmpty {
            let names = recipe.ingredients.map { $0.name.lowercased() }
            guard !query.excludeIngredients.contains(where: { exc in
                names.contains(where: { $0.contains(exc.lowercased()) })
            }) else { return false }
        }

        return true
    }
}
