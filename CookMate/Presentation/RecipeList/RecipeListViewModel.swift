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
    var state: State = .loading

    private let repository: RecipeRepository
    private let debounceMilliseconds: Int
    private var searchTask: Task<Void, Never>?

    init(repository: RecipeRepository, debounceMilliseconds: Int = 300) {
        self.repository = repository
        self.debounceMilliseconds = debounceMilliseconds
    }

    func start() async {
        await load()
    }

    func onQueryChanged() {
        searchTask?.cancel()
        searchTask = Task { [debounceMilliseconds] in
            try? await Task.sleep(for: .milliseconds(debounceMilliseconds))
            guard !Task.isCancelled else { return }
            await self.load()
        }
    }

    func load() async {
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
