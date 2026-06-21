import Observation

@Observable
@MainActor
final class RecipeListViewModel {

    enum State {
        case loading
        case loaded([Recipe])
        case empty
        case error(Error)
    }

    var query = RecipeQuery()
    private(set) var state: State = .loading

    private let repository: RecipeRepository
    private let debounceInterval: Duration
    private var searchTask: Task<Void, Never>?

    init(repository: RecipeRepository, debounceInterval: Duration = .milliseconds(300)) {
        self.repository = repository
        self.debounceInterval = debounceInterval
    }

    var activeFilterCount: Int {
        (query.minServings != nil ? 1 : 0)
        + query.dietaryTags.count
        + query.includeIngredients.count
        + query.excludeIngredients.count
    }

    func clearFilters() {
        let search = query.searchText
        query = RecipeQuery()
        query.searchText = search
        applyFilters()
    }

    /// Cancels any pending debounced search and loads immediately.
    /// Use for discrete controls (chips, stepper) where results should update instantly.
    func applyFilters() {
        searchTask?.cancel()
        Task { await loadRecipes() }
    }

    /// Debounces by 300 ms before loading. Use for text input to avoid a fetch on every keystroke.
    func onQueryChanged() {
        searchTask?.cancel()
        searchTask = Task {
            do {
                try await Task.sleep(for: self.debounceInterval)
            } catch {
                return  // CancellationError — a new task will update state
            }
            await self.loadRecipes()
        }
    }

    func loadRecipes() async {
        if case .loaded = state { /* keep existing results visible while re-filtering */ }
        else { state = .loading }
        do {
            let recipes = try await repository.fetchRecipes(query: query)
            state = recipes.isEmpty ? .empty : .loaded(recipes)
        } catch is CancellationError {
            // a new task will update state
        } catch {
            state = .error(error)
        }
    }
}

extension RecipeListViewModel.State: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.loading, .loading), (.empty, .empty):
            true
        case (.loaded(let a), .loaded(let b)):
            a == b
        case (.error, .error):
            true
        default:
            false
        }
    }
}
