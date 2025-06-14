//
//  DataManager.swift
//  myRecipe
//
//  Created by Mohamad Shawal Sapuan Bin Mohamad on 13/06/2025.
//

import Foundation
import CoreData

class DataManager {
    static let shared = DataManager()
    let container: NSPersistentContainer
    
    init() {
        container = NSPersistentContainer(name: "myRecipe")
        container.loadPersistentStores { _, error in
            if let error = error {
                print("Error loading Core Data: \(error.localizedDescription)")
            }
        }
        seedInitialData()
    }
    
    func seedInitialData() {
        let context = container.viewContext
        let fetchRequest: NSFetchRequest<RecipeEntity> = RecipeEntity.fetchRequest()
        
        if UserDefaults.standard.bool(forKey: "didSeedDummyData") {
            print("Dummy data already exists, skipping seeding.")
            return
        }
        
        do {
            let count = try context.count(for: fetchRequest)
            if count == 0 { // Only insert if Core Data is empty
                addDummyRecipes(context: context)
                UserDefaults.standard.set(true, forKey: "didSeedDummyData")
            }
        } catch {
            print("Error checking existing data: \(error.localizedDescription)")
        }
    }
    
    private func addDummyRecipes(context: NSManagedObjectContext) {
        let recipes = [
            ("Pancakes", "pancakes.jpg", 1, ["Flour", "Milk", "Eggs"], ["Mix ingredients", "Cook on pan", "Serve"]),
            ("Grilled Chicken", "grilled_chicken.jpg", 2, ["Chicken", "Olive Oil", "Garlic"], ["Marinate", "Grill", "Serve"]),
            ("Chocolate Cake", "chocolate_cake.jpg", 3, ["Flour", "Cocoa Powder", "Sugar"], ["Mix", "Bake", "Cool"]),
            ("Vegan Salad", "vegan_salad.jpg", 4,["Lettuce", "Tomatoes", "Avocado"],["Chop veggies", "Mix dressing", "Combine everything", "Serve"])
        ]
        
        for recipe in recipes {
            let newRecipe = RecipeEntity(context: context)
            newRecipe.id = UUID()
            newRecipe.name = recipe.0
            newRecipe.imageName = recipe.1
            newRecipe.categoryId = Int64(recipe.2)
            newRecipe.ingredients = recipe.3.joined(separator: ",")
            newRecipe.steps = recipe.4.joined(separator: ",")
            
            print("Added dummy recipe: \(recipe.0)")
        }
        
        do {
            try context.save()
            print("Dummy data saved successfully!")
        } catch {
            print("Error saving dummy data: \(error.localizedDescription)")
        }
    }
    
    func saveRecipe(name: String, imageName: String, categoryId: Int, ingredients: [String], steps: [String]) {
        let context = container.viewContext
        let recipe = RecipeEntity(context: context)
        
        recipe.id = UUID()
        recipe.name = name
        recipe.imageName = imageName
        recipe.categoryId = Int64(categoryId)
        recipe.ingredients = ingredients.joined(separator: ",")
        recipe.steps = steps.joined(separator: ",")
        
        do {
            try context.save()
            print("Recipe saved successfully!")
        } catch {
            print("Error saving recipe: \(error.localizedDescription)")
        }
    }
    
    func fetchRecipes() -> [RecipeEntity] {
        let context = container.viewContext
        let fetchRequest: NSFetchRequest<RecipeEntity> = RecipeEntity.fetchRequest()
        
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Error fetching recipes: \(error.localizedDescription)")
            return []
        }
    }
}
