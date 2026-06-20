import Testing
@testable import CookMate

struct RecipeQueryTests {

    @Test func hasTag_returnsFalse_whenTagNotAdded() {
        let query = RecipeQuery()
        #expect(!query.hasTag(.vegetarian))
    }

    @Test func toggleTag_addsTag_whenAbsent() {
        var query = RecipeQuery()
        query.toggleTag(.vegetarian)
        #expect(query.hasTag(.vegetarian))
    }

    @Test func toggleTag_removesTag_whenPresent() {
        var query = RecipeQuery()
        query.toggleTag(.vegetarian)
        query.toggleTag(.vegetarian)
        #expect(!query.hasTag(.vegetarian))
    }

    @Test func toggleTag_preservesInsertionOrder() {
        var query = RecipeQuery()
        query.toggleTag(.vegan)
        query.toggleTag(.vegetarian)
        #expect(query.dietaryTags == [.vegan, .vegetarian])
    }

    @Test func toggleTag_noDuplicates() {
        var query = RecipeQuery()
        query.toggleTag(.glutenFree)
        query.toggleTag(.glutenFree) // remove
        query.toggleTag(.glutenFree) // re-add
        #expect(query.dietaryTags.filter { $0 == .glutenFree }.count == 1)
    }
}
