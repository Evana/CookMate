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

    @Test func load_setsLoadedState_withRecipes() async {
        mockRepository.recipesToReturn = [.fixture(title: "Pasta"), .fixture(title: "Salad")]
        await sut.load()
        guard case .loaded(let recipes) = sut.state else {
            Issue.record("Expected .loaded state"); return
        }
        #expect(recipes.count == 2)
    }

    @Test func load_setsEmptyState_whenNoResults() async {
        mockRepository.recipesToReturn = []
        await sut.load()
        guard case .empty = sut.state else {
            Issue.record("Expected .empty state"); return
        }
    }

    @Test func load_setsErrorState_whenRepositoryThrows() async {
        mockRepository.shouldThrow = true
        await sut.load()
        guard case .error = sut.state else {
            Issue.record("Expected .error state"); return
        }
    }

    @Test func load_recoversToLoadedState_afterError() async {
        mockRepository.shouldThrow = true
        await sut.load()
        mockRepository.shouldThrow = false
        mockRepository.recipesToReturn = [.fixture()]
        await sut.load()
        guard case .loaded(let recipes) = sut.state else {
            Issue.record("Expected .loaded state"); return
        }
        #expect(recipes.count == 1)
    }

    @Test func onQueryChanged_triggersLoad() async {
        mockRepository.recipesToReturn = [.fixture(title: "Pasta")]
        sut.query.searchText = "pasta"
        sut.onQueryChanged()
        try? await Task.sleep(for: .milliseconds(10))
        guard case .loaded(let recipes) = sut.state else {
            Issue.record("Expected .loaded state"); return
        }
        #expect(recipes.count == 1)
    }

    @Test func onQueryChanged_cancelsInFlight_whenCalledAgain() async {
        mockRepository.recipesToReturn = [.fixture()]
        sut.onQueryChanged()
        sut.onQueryChanged()
        try? await Task.sleep(for: .milliseconds(10))
        guard case .loaded(let recipes) = sut.state else {
            Issue.record("Expected .loaded state"); return
        }
        #expect(recipes.count == 1)
    }
}
