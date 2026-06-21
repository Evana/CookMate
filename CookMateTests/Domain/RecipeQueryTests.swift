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

    @Test func matches_whitespaceOnlySearch_doesNotFilter() {
        var query = RecipeQuery()
        query.searchText = "   "
        let recipe = Recipe.fixture(title: "Pasta")
        #expect(query.matches(recipe))
    }

    @Test func matches_instructionSearch_doesNotJoinAcrossWordBoundaries() {
        let recipe = Recipe.fixture(instructions: ["boil pasta", "add sauce"])
        var query = RecipeQuery()
        query.searchText = "pastaadd"
        #expect(!query.matches(recipe))
    }

    @Test func clearFilters_preservesSearchText_andResetsFilters() {
        var query = RecipeQuery()
        query.searchText = "pasta"
        query.minServings = 4
        query.toggleTag(.vegetarian)
        let search = query.searchText
        query = RecipeQuery()
        query.searchText = search
        #expect(query.searchText == "pasta")
        #expect(query.minServings == nil)
        #expect(query.dietaryTags.isEmpty)
    }
}
