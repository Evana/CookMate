import Observation

@Observable
@MainActor
final class RecipeListViewModel {

    var query = RecipeQuery()
    var recipes: [Recipe] = []
    var isLoading = false
    var error: Error?

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
        isLoading = true
        error = nil
        defer { isLoading = false }
        do {
            recipes = try await repository.fetchRecipes(query: query)
        } catch {
            self.error = error
        }
    }
}
