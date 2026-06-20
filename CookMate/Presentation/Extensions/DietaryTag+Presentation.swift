extension DietaryTag {
    var displayName: String {
        switch self {
        case .vegetarian: return "Vegetarian"
        case .vegan: return "Vegan"
        case .glutenFree: return "Gluten Free"
        case .dairyFree: return "Dairy Free"
        case .nutFree: return "Nut Free"
        }
    }
}
