@testable import CookMate

final class MockRecipeDataSource: RecipeDataSource {
    var responses: [RecipeResponse] = []
    var shouldThrow = false

    func fetchRecipes() async throws -> [RecipeResponse] {
        if shouldThrow { throw RecipeError.fileNotFound }
        return responses
    }
}
