import SwiftUI

struct FilterSheetView: View {
    @Bindable var viewModel: RecipeListViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Dietary") {
                    DietaryTagChipsView(viewModel: viewModel)
                }
                Section("Servings") {
                    ServingsStepperView(viewModel: viewModel)
                }
                Section("Ingredients") {
                    IngredientChipInputView(viewModel: viewModel)
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Clear All") {
                        viewModel.query = RecipeQuery()
                        viewModel.onQueryChanged()
                    }
                }
            }
        }
    }
}
