import Foundation

struct RecipeQuery: Sendable {
    var searchText: String = ""
    private(set) var dietaryTags: [DietaryTag] = []
    var minServings: Int? = nil
    var includeIngredients: [String] = []
    var excludeIngredients: [String] = []

    mutating func toggleTag(_ tag: DietaryTag) {
        if let index = dietaryTags.firstIndex(of: tag) {
            dietaryTags.remove(at: index)
        } else {
            dietaryTags.append(tag)
        }
    }

    func hasTag(_ tag: DietaryTag) -> Bool {
        dietaryTags.contains(tag)
    }

    func matches(_ recipe: Recipe) -> Bool {
        let trimmedSearch = searchText.trimmingCharacters(in: .whitespaces)
        if !trimmedSearch.isEmpty {
            let text = trimmedSearch.lowercased()
            let inTitle = recipe.title.lowercased().contains(text)
            let inInstructions = recipe.instructions.joined(separator: " ").lowercased().contains(text)
            guard inTitle || inInstructions else { return false }
        }

        if let min = minServings {
            guard recipe.servings >= min else { return false }
        }

        if !dietaryTags.isEmpty {
            guard dietaryTags.allSatisfy({ recipe.dietaryTags.contains($0) }) else { return false }
        }

        if !includeIngredients.isEmpty {
            let names = recipe.ingredients.map { $0.name.lowercased() }
            guard includeIngredients.allSatisfy({ inc in
                names.contains(where: { $0.contains(inc.lowercased()) })
            }) else { return false }
        }

        if !excludeIngredients.isEmpty {
            let names = recipe.ingredients.map { $0.name.lowercased() }
            guard !excludeIngredients.contains(where: { exc in
                names.contains(where: { $0.contains(exc.lowercased()) })
            }) else { return false }
        }

        return true
    }
}
