import SwiftUI

struct RecipeListView: View {
    var viewModel: RecipeListViewModel

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.recipes.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(viewModel.recipes) { recipe in
                            NavigationLink(value: recipe) {
                                RecipeCardView(recipe: recipe)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Recipes")
        .navigationDestination(for: Recipe.self) { recipe in
            RecipeDetailView(recipe: recipe)
        }
        .task {
            await viewModel.start()
        }
    }
}

#Preview {
    NavigationStack {
        RecipeListView(viewModel: {
            let dataSource = LocalRecipeDataSource()
            let repository = ConcreteRecipeRepository(dataSource: dataSource)
            return RecipeListViewModel(repository: repository)
        }())
    }
}
