//
//  RecipeListView.swift
//  myRecipe
//
//  Created by Mohamad Shawal Sapuan Bin Mohamad on 12/06/2025.
//

import SwiftUI

struct RecipeListView: View {
    @State private var selectedCategoryId: Int? = nil
    @State private var categories: [Category] = []
    @State private var showAddRecipeView = false
    @State private var recipes: [RecipeEntity] = []
    @State private var reloadTrigger = false
    
    var filteredRecipes: [RecipeEntity] {
        guard let categoryId = selectedCategoryId, categoryId != -1 else {
            return recipes
        }
        return recipes.filter { $0.categoryId == categoryId }
    }
    
    func getCategoryName(categoryId: Int) -> String {
        categories.first { $0.id == categoryId }?.name ?? "Unknown Category"
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if reloadTrigger { EmptyView() }
                if filteredRecipes.isEmpty {
                    Text("No recipes found for this category.")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List(filteredRecipes, id: \.id) { recipe in
                        NavigationLink(destination: RecipeDetailView(recipe: recipe, categories: categories)) {
                            HStack {
                                Image(uiImage: loadImage(from: recipe.imageName ?? "") ?? UIImage(named: "placeholder")!)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100, height: 100)
                                    .cornerRadius(10)
                                VStack(alignment: .leading) {
                                    Text(recipe.name ?? "Unknown Recipe")
                                        .font(.headline)
                                    Text(getCategoryName(categoryId: Int(recipe.categoryId)))
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Recipes")
            .onAppear {
                recipes = DataManager.shared.fetchRecipes()
            }
            .onReceive(NotificationCenter.default.publisher(for: .didUpdateRecipes)) { _ in
                recipes = DataManager.shared.fetchRecipes()
                reloadTrigger.toggle()
                print("Notification received: Refreshing list!")
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        Button(action: { selectedCategoryId = nil }) {
                            Label("All", systemImage: selectedCategoryId == nil ? "checkmark" : "")
                        }
                        
                        ForEach(categories) { category in
                            Button(action: { selectedCategoryId = category.id }) {
                                Label(category.name, systemImage: selectedCategoryId == category.id ? "checkmark" : "")
                            }
                        }
                    } label: {
                        Label("Category", systemImage: "line.horizontal.3.decrease.circle")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAddRecipeView = true }) {
                        Image(systemName: "plus")
                            .font(.title)
                    }
                }
            }
            .sheet(isPresented: $showAddRecipeView) {
                AddRecipeView(categories: categories)
            }
        }
        .onAppear {
            if let categoryData: [Category] = loadJSON(fileName: "recipetypes") {
                categories = categoryData
            }
        }
    }
}

//cat
