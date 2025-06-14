//
//  Recipe.swift
//  myRecipe
//
//  Created by Mohamad Shawal Sapuan Bin Mohamad on 12/06/2025.
//

import Foundation

struct Category: Identifiable, Codable {
    var id: Int
    var name: String
}

struct Recipe: Identifiable, Codable {
    var id = UUID()
    var name: String
    var image: String
    var categoryId: Int
    var ingredients: [String]
    var steps: [String]
}

func getRecipesByCategory(categoryId: Int, recipes: [Recipe]) -> [Recipe] {
    return recipes.filter { $0.categoryId == categoryId }
}
