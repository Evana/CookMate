import SwiftUI

struct RecipeListView: View {
    var viewModel: RecipeListViewModel

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.recipes.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.recipes.isEmpty {
                ContentUnavailableView(
                    "No Recipes Found",
                    systemImage: "fork.knife",
                    description: Text("Try adjusting your search or filters.")
                )
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
        .searchable(text: Binding(
            get: { viewModel.query.searchText },
            set: { viewModel.query.searchText = $0 }
        ), prompt: "Search recipes")
        .onChange(of: viewModel.query.searchText) {
            viewModel.onQueryChanged()
        }
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
