import Testing
@testable import CookMate

@MainActor
struct RecipeListViewModelTests {

    var mockRepository: MockRecipeRepository
    var viewModel: RecipeListViewModel

    init() {
        let repo = MockRecipeRepository()
        self.mockRepository = repo
        self.viewModel = RecipeListViewModel(repository: repo, debounceInterval: .milliseconds(0))
    }

    @Test func load_setsLoadedState_withRecipes() async {
        mockRepository.recipesToReturn = [.fixture(title: "Pasta"), .fixture(title: "Salad")]
        await viewModel.loadRecipes()
        guard case .loaded(let recipes) = viewModel.state else {
            Issue.record("Expected .loaded state"); return
        }
        #expect(recipes.count == 2)
    }

    @Test func load_setsEmptyState_whenNoResults() async {
        mockRepository.recipesToReturn = []
        await viewModel.loadRecipes()
        guard case .empty = viewModel.state else {
            Issue.record("Expected .empty state"); return
        }
    }

    @Test func load_setsErrorState_whenRepositoryThrows() async {
        mockRepository.shouldThrow = true
        await viewModel.loadRecipes()
        guard case .error = viewModel.state else {
            Issue.record("Expected .error state"); return
        }
    }

    @Test func load_recoversToLoadedState_afterError() async {
        mockRepository.shouldThrow = true
        await viewModel.loadRecipes()
        mockRepository.shouldThrow = false
        mockRepository.recipesToReturn = [.fixture()]
        await viewModel.loadRecipes()
        guard case .loaded(let recipes) = viewModel.state else {
            Issue.record("Expected .loaded state"); return
        }
        #expect(recipes.count == 1)
    }

    @Test func onQueryChanged_triggersLoad() async {
        mockRepository.recipesToReturn = [.fixture(title: "Pasta")]
        viewModel.query.searchText = "pasta"
        viewModel.onQueryChanged()
        try? await Task.sleep(for: .milliseconds(50))
        guard case .loaded(let recipes) = viewModel.state else {
            Issue.record("Expected .loaded state"); return
        }
        #expect(recipes.count == 1)
    }

    @Test func onQueryChanged_cancelsInFlight_whenCalledAgain() async {
        mockRepository.recipesToReturn = [.fixture()]
        viewModel.onQueryChanged()
        viewModel.onQueryChanged()
        try? await Task.sleep(for: .milliseconds(50))
        guard case .loaded(let recipes) = viewModel.state else {
            Issue.record("Expected .loaded state"); return
        }
        #expect(recipes.count == 1)
    }
}
