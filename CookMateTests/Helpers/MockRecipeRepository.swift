@testable import CookMate

final class MockRecipeRepository: RecipeRepository {
    var recipesToReturn: [Recipe] = []
    var shouldThrow = false

    func fetchRecipes(query: RecipeQuery) async throws -> [Recipe] {
        if shouldThrow { throw RecipeError.fileNotFound }
        return recipesToReturn
    }
}
