import Foundation

struct LocalRecipeDataSource: RecipeDataSource {
    func fetchRecipes(query: RecipeQuery) async throws -> [RecipeResponse] {
        // `query` is intentionally unused here — a remote implementation would
        // serialize it into URL query items and let the server filter.
        // Filtering is applied by ConcreteRecipeRepository after the full dataset is returned.
        guard let url = Bundle.main.url(forResource: "recipes", withExtension: "json") else {
            throw RecipeError.fileNotFound
        }
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode([RecipeResponse].self, from: data)
        } catch is DecodingError {
            throw RecipeError.decodingFailed
        }
    }
}
