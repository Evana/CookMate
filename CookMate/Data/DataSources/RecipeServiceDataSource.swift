import Foundation

struct RecipeServiceDataSource: RecipeDataSource {

    private let session: URLSession
    private let endpoint: URL

    /// Production initialiser points at a real REST endpoint.
    /// Defaults to the bundled JSON file URL so the app runs without a live server —
    /// the URLSession path (request building, decoding, error handling) is identical either way.
    init(
        endpoint: URL = Bundle.main.url(forResource: "recipes", withExtension: "json")!,
        session: URLSession = .shared
    ) {
        self.endpoint = endpoint
        self.session = session
    }

    func fetchRecipes(query: RecipeQuery) async throws -> [RecipeResponse] {
        let request = buildRequest(for: query)

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw RecipeError.networkError
        }

        try validate(response)

        do {
            return try JSONDecoder().decode([RecipeResponse].self, from: data)
        } catch {
            throw RecipeError.decodingFailed
        }
    }

    // MARK: - Private

    /// Builds a URLRequest that mirrors what a production endpoint would receive.
    /// A real server would use these query items for server-side filtering;
    /// ConcreteRecipeRepository applies client-side filtering after mapping.
    private func buildRequest(for query: RecipeQuery) -> URLRequest {
        var components = URLComponents(url: endpoint, resolvingAgainstBaseURL: false)!
        var items: [URLQueryItem] = []

        if !query.searchText.isEmpty {
            items.append(URLQueryItem(name: "q", value: query.searchText))
        }
        if let min = query.minServings {
            items.append(URLQueryItem(name: "minServings", value: String(min)))
        }
        if !query.dietaryTags.isEmpty {
            let tags = query.dietaryTags.map(\.rawValue).joined(separator: ",")
            items.append(URLQueryItem(name: "tags", value: tags))
        }
        if !query.includeIngredients.isEmpty {
            items.append(URLQueryItem(name: "include", value: query.includeIngredients.joined(separator: ",")))
        }
        if !query.excludeIngredients.isEmpty {
            items.append(URLQueryItem(name: "exclude", value: query.excludeIngredients.joined(separator: ",")))
        }

        components.queryItems = items.isEmpty ? nil : items

        var request = URLRequest(url: components.url ?? endpoint)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 10
        return request
    }

    /// Validates HTTP status codes. File URLs produce a plain URLResponse (not HTTPURLResponse),
    /// so they pass through — this lets the same implementation work for both local and remote endpoints.
    private func validate(_ response: URLResponse) throws {
        guard let http = response as? HTTPURLResponse else { return }
        guard (200...299).contains(http.statusCode) else {
            throw RecipeError.unexpectedStatusCode(http.statusCode)
        }
    }
}
