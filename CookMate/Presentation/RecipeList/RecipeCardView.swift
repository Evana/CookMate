import SwiftUI

struct RecipeCardView: View {
    let recipe: Recipe

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            recipe.cardColor
                .frame(height: 120)

            VStack(alignment: .leading, spacing: 4) {
                Text(recipe.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                    .lineLimit(2)

                Text("\(recipe.servings) servings")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if !recipe.dietaryTags.isEmpty {
                    Text(recipe.dietaryTags.map(\.displayName).joined(separator: " · "))
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                        .lineLimit(1)
                }
            }
            .padding(10)
        }
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
    }
}

#Preview {
    RecipeCardView(recipe: Recipe(
        id: UUID(),
        title: "Spaghetti Carbonara",
        description: "A classic Roman pasta dish.",
        servings: 4,
        ingredients: [Ingredient(name: "spaghetti", quantity: "200g")],
        instructions: ["Boil pasta", "Mix with egg"],
        dietaryTags: [.vegetarian, .glutenFree]
    ))
    .frame(width: 180)
    .padding()
}
