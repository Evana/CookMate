import Testing
@testable import CookMate

@MainActor
struct ConcreteRecipeRepositoryTests {

    var dataSource: MockRecipeDataSource
    var sut: ConcreteRecipeRepository

    init() {
        let ds = MockRecipeDataSource()
        self.dataSource = ds
        self.sut = ConcreteRecipeRepository(dataSource: ds)
    }

    // MARK: - Base fetch

    @Test func fetch_returnsAll_whenQueryIsEmpty() async throws {
        dataSource.responses = [.fixture(title: "Pasta"), .fixture(title: "Salad")]
        let results = try await sut.fetchRecipes(query: RecipeQuery())
        #expect(results.count == 2)
    }

    // MARK: - Text search

    @Test func fetch_filtersBy_titleSearch() async throws {
        dataSource.responses = [
            .fixture(title: "Spaghetti Carbonara"),
            .fixture(title: "Greek Salad")
        ]
        var query = RecipeQuery()
        query.searchText = "spaghetti"
        let results = try await sut.fetchRecipes(query: query)
        #expect(results.count == 1)
        #expect(results.first?.title == "Spaghetti Carbonara")
    }

    @Test func fetch_titleSearch_isCaseInsensitive() async throws {
        dataSource.responses = [.fixture(title: "Mushroom Risotto")]
        var query = RecipeQuery()
        query.searchText = "MUSHROOM"
        let results = try await sut.fetchRecipes(query: query)
        #expect(results.count == 1)
    }

    @Test func fetch_filtersBy_instructionContent() async throws {
        dataSource.responses = [
            .fixture(title: "Pasta", instructions: ["boil water", "add pasta"]),
            .fixture(title: "Salad", instructions: ["chop vegetables", "toss with dressing"])
        ]
        var query = RecipeQuery()
        query.searchText = "boil"
        let results = try await sut.fetchRecipes(query: query)
        #expect(results.count == 1)
        #expect(results.first?.title == "Pasta")
    }

    // MARK: - Servings filter

    @Test func fetch_filtersBy_minServings() async throws {
        dataSource.responses = [
            .fixture(title: "Small", servings: 2),
            .fixture(title: "Medium", servings: 4),
            .fixture(title: "Large", servings: 6)
        ]
        var query = RecipeQuery()
        query.minServings = 4
        let results = try await sut.fetchRecipes(query: query)
        #expect(results.count == 2)
        #expect(results.allSatisfy { $0.servings >= 4 })
    }

    // MARK: - Dietary tags

    @Test func fetch_filtersBy_singleDietaryTag() async throws {
        dataSource.responses = [
            .fixture(title: "Veg", dietaryTags: ["vegetarian"]),
            .fixture(title: "NotVeg", dietaryTags: [])
        ]
        var query = RecipeQuery()
        query.toggleTag(.vegetarian)
        let results = try await sut.fetchRecipes(query: query)
        #expect(results.count == 1)
        #expect(results.first?.title == "Veg")
    }

    @Test func fetch_filtersBy_multipleDietaryTags() async throws {
        dataSource.responses = [
            .fixture(title: "Both", dietaryTags: ["vegetarian", "glutenFree"]),
            .fixture(title: "VegOnly", dietaryTags: ["vegetarian"]),
            .fixture(title: "Neither", dietaryTags: [])
        ]
        var query = RecipeQuery()
        query.toggleTag(.vegetarian)
        query.toggleTag(.glutenFree)
        let results = try await sut.fetchRecipes(query: query)
        #expect(results.count == 1)
        #expect(results.first?.title == "Both")
    }

    // MARK: - Ingredient filters

    @Test func fetch_filtersBy_includeIngredient() async throws {
        dataSource.responses = [
            .fixture(title: "Chicken Dish", ingredients: [IngredientResponse(name: "chicken breast", quantity: "500g")]),
            .fixture(title: "Pasta Dish", ingredients: [IngredientResponse(name: "spaghetti", quantity: "200g")])
        ]
        var query = RecipeQuery()
        query.includeIngredients = ["chicken"]
        let results = try await sut.fetchRecipes(query: query)
        #expect(results.count == 1)
        #expect(results.first?.title == "Chicken Dish")
    }

    @Test func fetch_filtersBy_excludeIngredient() async throws {
        dataSource.responses = [
            .fixture(title: "With Nuts", ingredients: [IngredientResponse(name: "walnuts", quantity: "80g")]),
            .fixture(title: "Without Nuts", ingredients: [IngredientResponse(name: "flour", quantity: "200g")])
        ]
        var query = RecipeQuery()
        query.excludeIngredients = ["walnuts"]
        let results = try await sut.fetchRecipes(query: query)
        #expect(results.count == 1)
        #expect(results.first?.title == "Without Nuts")
    }

    @Test func fetch_ingredientMatching_isCaseInsensitive() async throws {
        dataSource.responses = [
            .fixture(title: "Dish", ingredients: [IngredientResponse(name: "Chicken Breast", quantity: "500g")])
        ]
        var query = RecipeQuery()
        query.includeIngredients = ["chicken"]
        let results = try await sut.fetchRecipes(query: query)
        #expect(results.count == 1)
    }

    // MARK: - Error propagation

    @Test func fetch_propagatesError_whenDataSourceThrows() async {
        dataSource.shouldThrow = true
        await #expect(throws: (any Error).self) {
            try await sut.fetchRecipes(query: RecipeQuery())
        }
    }
}
