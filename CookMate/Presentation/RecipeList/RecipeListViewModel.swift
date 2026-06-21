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
            await self.loadRecipe()
        }
    }

    func loadRecipe() async {
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
