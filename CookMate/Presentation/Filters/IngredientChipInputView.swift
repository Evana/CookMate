import SwiftUI

struct IngredientChipInputView: View {
    @Bindable var viewModel: RecipeListViewModel
    @State private var inputText = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                TextField("e.g. chicken, nuts", text: $inputText)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .onSubmit { addIngredient() }

                Button("Add", action: addIngredient)
                    .disabled(inputText.trimmingCharacters(in: .whitespaces).isEmpty)
            }

            if !chips.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(chips) { chip in
                            ingredientChip(chip)
                        }
                    }
                }
            }

            if !chips.isEmpty {
                Text("Tap a chip to toggle include/exclude. Tap × to remove.")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
    }

    private var chips: [IngredientChip] {
        viewModel.query.includeIngredients.map { IngredientChip(name: $0, isInclude: true) } +
        viewModel.query.excludeIngredients.map { IngredientChip(name: $0, isInclude: false) }
    }

    private func ingredientChip(_ chip: IngredientChip) -> some View {
        HStack(spacing: 4) {
            Text(chip.name)
                .font(.subheadline)

            Button {
                removeChip(chip)
            } label: {
                Image(systemName: "xmark")
                    .font(.caption2)
                    .fontWeight(.semibold)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(chip.isInclude ? Color.green.opacity(0.15) : Color.red.opacity(0.15))
        .foregroundStyle(chip.isInclude ? Color.green : Color.red)
        .clipShape(Capsule())
        .onTapGesture { toggleChip(chip) }
    }

    private func addIngredient() {
        let trimmed = inputText.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        guard !chips.map(\.name).contains(trimmed.lowercased()) else { return }
        viewModel.query.includeIngredients.append(trimmed.lowercased())
        viewModel.onQueryChanged()
        inputText = ""
    }

    private func toggleChip(_ chip: IngredientChip) {
        if chip.isInclude {
            viewModel.query.includeIngredients.removeAll { $0 == chip.name }
            viewModel.query.excludeIngredients.append(chip.name)
        } else {
            viewModel.query.excludeIngredients.removeAll { $0 == chip.name }
            viewModel.query.includeIngredients.append(chip.name)
        }
        viewModel.onQueryChanged()
    }

    private func removeChip(_ chip: IngredientChip) {
        viewModel.query.includeIngredients.removeAll { $0 == chip.name }
        viewModel.query.excludeIngredients.removeAll { $0 == chip.name }
        viewModel.onQueryChanged()
    }
}

private struct IngredientChip: Identifiable {
    let name: String
    let isInclude: Bool
    var id: String { "\(name)-\(isInclude)" }
}

#Preview {
    Form {
        IngredientChipInputView(viewModel: RecipeListViewModel(
            repository: ConcreteRecipeRepository(dataSource: LocalRecipeDataSource())
        ))
    }
}
