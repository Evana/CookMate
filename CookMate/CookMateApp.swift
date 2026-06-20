//
//  CookMateApp.swift
//  CookMate
//
//  Created by Evana Islam on 20/6/2026.
//

import SwiftUI

@main
struct CookMateApp: App {

    private let viewModel: RecipeListViewModel = {
        let dataSource = LocalRecipeDataSource()
        let repository = ConcreteRecipeRepository(dataSource: dataSource)
        return RecipeListViewModel(repository: repository)
    }()

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                RecipeListView(viewModel: viewModel)
            }
        }
    }
}
