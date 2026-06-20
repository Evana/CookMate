# CookMate

A native iOS recipe browsing app built with Swift and SwiftUI.

## Setup

1. Clone the repository
2. Open `CookMate.xcodeproj` in Xcode 26+
3. Select an iOS 26 simulator
4. Press ⌘R to build and run — no dependencies to install

## Architecture

MVVM + Clean Architecture with strict layer separation.

```mermaid
graph TD
    subgraph Presentation
        App[CookMateApp]
        VM[RecipeListViewModel]
        RLV[RecipeListView]
        RDV[RecipeDetailView]
        FSV[FilterSheetView]
    end

    subgraph Domain
        RP([RecipeRepository\nprotocol])
        Recipe[Recipe]
        RQ[RecipeQuery]
        DT[DietaryTag]
    end

    subgraph Data
        CRR[ConcreteRecipeRepository]
        DS([RecipeDataSource\nprotocol])
        LDS[LocalRecipeDataSource]
        JSON[(recipes.json)]
    end

    App --> VM
    App --> RLV
    RLV --> RDV
    RLV --> FSV
    VM --> RP
    CRR -- implements --> RP
    CRR --> DS
    LDS -- implements --> DS
    LDS --> JSON
```

- **Domain** — pure Swift. `Recipe`, `RecipeQuery`, `DietaryTag`, `RecipeRepository` protocol. Zero external dependencies.
- **Data** — `ConcreteRecipeRepository` fetches from `RecipeDataSource` (protocol), maps `RecipeResponse` → `Recipe`, applies all query filters.
- **Presentation** — `RecipeListViewModel` (@Observable) owns query state, debounces input, calls the repository. Views are driven by the ViewModel.

Swapping the local JSON for a real API requires one new `RecipeDataSource` conformer and one line change in `CookMateApp.swift`.

## Key Design Decisions

**`RecipeDataSource` protocol over concrete type**
`ConcreteRecipeRepository` depends on the protocol, not `LocalRecipeDataSource`. This mirrors the structure a real API integration would use and makes the repository testable via `MockRecipeDataSource`.

**No service layer**
A service layer was considered but removed — it was a pure passthrough with no added value. The ViewModel depends directly on `RecipeRepository`. A service layer would be introduced if multiple repositories needed orchestrating.

**`RecipeQuery` uses `[DietaryTag]` not `Set`**
Preserves insertion order (useful for displaying active filters). Uniqueness enforced via `toggleTag(_:)`.

**Debounce via Task cancellation**
Real-time search debounce is implemented by cancelling the previous `Task` before sleeping 300ms. No Combine dependency needed.

**No ViewModel on detail screen**
The recipe is already in memory, passed as a value. A ViewModel would be empty boilerplate.

## Assumptions & Tradeoffs

- No image URLs — placeholder color blocks are derived deterministically from recipe ID
- Ingredient matching is substring-based (case-insensitive), not exact
- Servings filter means "at least N", not exact match
- All filtering is client-side (appropriate for local JSON at this scale)
- No persistence — no favourites or user data
