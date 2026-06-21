import SwiftUI

struct RecipeListView: View {
    var viewModel: RecipeListViewModel

    @State private var isFilterSheetPresented = false

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        Group {
            switch viewModel.state {
            case .loading:
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .error(let error):
                ContentUnavailableView(
                    "Could Not Load Recipes",
                    systemImage: "exclamationmark.triangle",
                    description: Text(error.localizedDescription)
                )
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
        .searchable(text: Binding(
            get: { viewModel.query.searchText },
            set: { viewModel.query.searchText = $0 }
        ), prompt: "Search recipes")
        .onChange(of: viewModel.query.searchText) {
            viewModel.onQueryChanged()
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isFilterSheetPresented = true
                } label: {
                    Label("Filter", systemImage: activeFilterCount > 0
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

    private var activeFilterCount: Int {
        (viewModel.query.minServings != nil ? 1 : 0)
        + viewModel.query.dietaryTags.count
        + viewModel.query.includeIngredients.count
        + viewModel.query.excludeIngredients.count
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
