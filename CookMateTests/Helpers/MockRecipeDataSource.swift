@testable import CookMate

final class MockRecipeDataSource: RecipeDataSource, @unchecked Sendable {
    var responses: [RecipeResponse] = []
    var shouldThrow = false

    func fetchRecipes(query: CookMate.RecipeQuery) async throws -> [RecipeResponse] {
        if shouldThrow { throw RecipeError.fileNotFound }
        return responses
    }
}
