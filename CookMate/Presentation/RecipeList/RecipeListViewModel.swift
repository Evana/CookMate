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
    private let debounceInterval: Duration = .milliseconds(300)
    private var searchTask: Task<Void, Never>?

    init(repository: RecipeRepository) {
        self.repository = repository
    }

    func onQueryChanged() {
        searchTask?.cancel()
        searchTask = Task { [debounceInterval] in
            try? await Task.sleep(for: debounceInterval)
            guard !Task.isCancelled else { return }
            await self.loadRecipes()
        }
    }

    func loadRecipes() async {
        state = .loading
        do {
            let recipes = try await repository.fetchRecipes(query: query)
            state = recipes.isEmpty ? .empty : .loaded(recipes)
        } catch is CancellationError {
            // no-op: a new task will update state
        } catch {
            state = .error(error)
        }
    }
}

extension RecipeListViewModel.State: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.loading, .loading), (.empty, .empty): true
        case (.loaded(let a), .loaded(let b)):        a == b
        case (.error, .error):                        true
        default:                                      false
        }
    }
}
