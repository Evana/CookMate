import Testing
@testable import CookMate

@MainActor
struct RecipeListViewModelTests {

    var mockRepository: MockRecipeRepository
    var sut: RecipeListViewModel

    init() {
        let repo = MockRecipeRepository()
        self.mockRepository = repo
        self.sut = RecipeListViewModel(repository: repo, debounceMilliseconds: 0)
    }

    @Test func load_populatesRecipes() async {
        mockRepository.recipesToReturn = [.fixture(title: "Pasta"), .fixture(title: "Salad")]
        await sut.load()
        #expect(sut.recipes.count == 2)
    }

    @Test func load_setsIsLoading_falseAfterCompletion() async {
        await sut.load()
        #expect(!sut.isLoading)
    }

    @Test func load_setsError_whenRepositoryThrows() async {
        mockRepository.shouldThrow = true
        await sut.load()
        #expect(sut.error != nil)
        #expect(sut.recipes.isEmpty)
    }

    @Test func load_clearsError_onSuccessAfterFailure() async {
        mockRepository.shouldThrow = true
        await sut.load()
        mockRepository.shouldThrow = false
        mockRepository.recipesToReturn = [.fixture()]
        await sut.load()
        #expect(sut.error == nil)
        #expect(sut.recipes.count == 1)
    }

    @Test func onQueryChanged_triggersLoad() async {
        mockRepository.recipesToReturn = [.fixture(title: "Pasta")]
        sut.query.searchText = "pasta"
        sut.onQueryChanged()
        try? await Task.sleep(for: .milliseconds(10))
        #expect(sut.recipes.count == 1)
    }

    @Test func onQueryChanged_cancelsInFlight_whenCalledAgain() async {
        mockRepository.recipesToReturn = [.fixture()]
        sut.onQueryChanged()
        sut.onQueryChanged()
        try? await Task.sleep(for: .milliseconds(10))
        #expect(sut.recipes.count == 1)
    }
}
