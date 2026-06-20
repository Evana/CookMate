struct RecipeQuery {
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
}
