import Foundation

final class LocalRecipeDataSource: RecipeDataSource {
    func fetchRecipes() async throws -> [RecipeResponse] {
        guard let url = Bundle.main.url(forResource: "recipes", withExtension: "json") else {
            throw RecipeError.fileNotFound
        }
        let data = try Data(contentsOf: url)
        do {
            return try JSONDecoder().decode([RecipeResponse].self, from: data)
        } catch {
            throw RecipeError.decodingFailed
        }
    }
}
