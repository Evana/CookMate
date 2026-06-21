//
//  CookMateApp.swift
//  CookMate
//
//  Created by Evana Islam on 20/6/2026.
//

import SwiftUI

@main
struct CookMateApp: App {

    @State private var viewModel = RecipeListViewModel(
        repository: ConcreteRecipeRepository(
            dataSource: LocalRecipeDataSource()
        )
    )

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                RecipeListView(viewModel: viewModel)
            }
        }
    }
}
