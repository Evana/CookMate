import SwiftUI

struct ServingsStepperView: View {
    @Bindable var viewModel: RecipeListViewModel

    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(viewModel.query.minServings == nil ? .secondary : .primary)
            Spacer()
            Stepper(
                "",
                value: Binding(
                    get: { viewModel.query.minServings ?? 0 },
                    set: { newValue in
                        viewModel.query.minServings = newValue == 0 ? nil : newValue
                        viewModel.applyFilters()
                    }
                ),
                in: 0...20
            )
            .labelsHidden()
        }
    }

    private var label: String {
        if let min = viewModel.query.minServings {
            return "Serves at least \(min)"
        }
        return "Any number of servings"
    }
}

#Preview {
    Form {
        ServingsStepperView(viewModel: RecipeListViewModel(
            repository: ConcreteRecipeRepository(dataSource: RecipeServiceDataSource())
        ))
    }
}
