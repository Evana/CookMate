import SwiftUI

struct DietaryTagChipsView: View {
    @Bindable var viewModel: RecipeListViewModel

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(DietaryTag.allCases, id: \.self) { tag in
                    Button(tag.displayName) {
                        viewModel.query.toggleTag(tag)
                        viewModel.applyFilters()
                    }
                    .buttonStyle(ChipButtonStyle(isSelected: viewModel.query.hasTag(tag)))
                }
            }
            .padding(.vertical, 4)
        }
    }
}

#Preview {
    DietaryTagChipsView(viewModel: RecipeListViewModel(
        repository: ConcreteRecipeRepository(dataSource: RecipeServiceDataSource())
    ))
    .padding()
}
