import SwiftUI

struct RecipeDetailView: View {
    let recipe: Recipe

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                recipe.cardColor
                    .frame(height: 220)

                VStack(alignment: .leading, spacing: 24) {
                    headerSection
                    Divider()
                    ingredientsSection
                    Divider()
                    instructionsSection
                }
                .padding(20)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .ignoresSafeArea(edges: .top)
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(recipe.title)
                .font(.title2)
                .fontWeight(.bold)

            HStack(spacing: 4) {
                Label("\(recipe.servings) servings", systemImage: "person.2")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                if !recipe.dietaryTags.isEmpty {
                    Text("·")
                        .foregroundStyle(.secondary)
                    Text(recipe.dietaryTags.map(\.displayName).joined(separator: ", "))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            Text(recipe.description)
                .font(.body)
                .foregroundStyle(.secondary)
        }
    }

    private var ingredientsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Ingredients")
                .font(.headline)

            ForEach(recipe.ingredients) { ingredient in
                HStack {
                    Text(ingredient.name.capitalized)
                        .font(.body)
                    Spacer()
                    Text(ingredient.quantity)
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private var instructionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Instructions")
                .font(.headline)

            ForEach(Array(recipe.instructions.enumerated()), id: \.offset) { index, step in
                HStack(alignment: .center, spacing: 14) {
                    Text("\(index + 1)")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .frame(width: 28, height: 28)
                        .background(recipe.cardColor)
                        .clipShape(Circle())

                    Text(step)
                        .font(.body)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        RecipeDetailView(recipe: Recipe(
            id: UUID(),
            title: "Spaghetti Carbonara",
            description: "A classic Roman pasta dish made with egg, cheese, pancetta and pepper.",
            servings: 4,
            ingredients: [
                Ingredient(id: UUID(), name: "spaghetti", quantity: "200g"),
                Ingredient(id: UUID(), name: "pancetta", quantity: "100g"),
                Ingredient(id: UUID(), name: "eggs", quantity: "2 large"),
                Ingredient(id: UUID(), name: "pecorino", quantity: "50g")
            ],
            instructions: [
                "Cook spaghetti in salted boiling water until al dente.",
                "Fry pancetta until crispy.",
                "Whisk eggs with pecorino and black pepper.",
                "Combine off the heat and serve immediately."
            ],
            dietaryTags: [.glutenFree]
        ))
    }
}
