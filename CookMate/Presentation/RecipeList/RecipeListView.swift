import SwiftUI

struct RecipeListView: View {
    @Bindable var viewModel: RecipeListViewModel

    @State private var isFilterSheetPresented = false

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        Group {
            switch viewModel.state {
            case .loading:
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .error(let error):
                ContentUnavailableView {
                    Label("Could Not Load Recipes", systemImage: "exclamationmark.triangle")
                } description: {
                    Text(error.localizedDescription)
                } actions: {
                    Button("Try Again") {
                        Task { await viewModel.loadRecipes() }
                    }
                    .buttonStyle(.borderedProminent)
                }
            case .empty:
                ContentUnavailableView(
                    "No Recipes Found",
                    systemImage: "fork.knife",
                    description: Text("Try adjusting your search or filters.")
                )
            case .loaded(let recipes):
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(recipes) { recipe in
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
        .searchable(text: $viewModel.query.searchText, prompt: "Search recipes")
        .onChange(of: viewModel.query.searchText) {
            viewModel.onQueryChanged()
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isFilterSheetPresented = true
                } label: {
                    Label("Filter", systemImage: viewModel.activeFilterCount > 0
                          ? "line.3.horizontal.decrease.circle.fill"
                          : "line.3.horizontal.decrease.circle")
                }
            }
        }
        .sheet(isPresented: $isFilterSheetPresented) {
            FilterSheetView(viewModel: viewModel)
        }
        .navigationDestination(for: Recipe.self) { recipe in
            RecipeDetailView(recipe: recipe)
        }
        .task {
            await viewModel.loadRecipes()
        }
    }

}

#Preview {
    NavigationStack {
        RecipeListView(viewModel: RecipeListViewModel(
            repository: ConcreteRecipeRepository(dataSource: RecipeServiceDataSource())
        ))
    }
}
