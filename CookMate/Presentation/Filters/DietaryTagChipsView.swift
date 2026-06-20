import SwiftUI

struct DietaryTagChipsView: View {
    @Bindable var viewModel: RecipeListViewModel

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(DietaryTag.allCases, id: \.self) { tag in
                    Button(tag.displayName) {
                        viewModel.query.toggleTag(tag)
                        viewModel.onQueryChanged()
                    }
                    .buttonStyle(ChipButtonStyle(isSelected: viewModel.query.hasTag(tag)))
                }
            }
            .padding(.vertical, 4)
        }
    }
}
