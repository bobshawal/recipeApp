//
//  RecipeDetailView.swift
//  myRecipe
//
//  Created by Mohamad Shawal Sapuan Bin Mohamad on 12/06/2025.
//

import SwiftUI

struct RecipeDetailView: View {
    
    @Environment(\.dismiss) var dismiss
    var recipe: RecipeEntity
    var categories: [Category]
    let viewContext = DataManager.shared.container.viewContext
    
    @State private var isEditing = false
    @State private var updatedName: String
    @State private var updatedImage: UIImage?
    @State private var updatedCategoryId: Int
    @State private var updatedIngredients: String
    @State private var updatedSteps: String
    @State private var showDeleteAlert = false
    @State private var showImagePicker = false
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    
    init(recipe: RecipeEntity, categories: [Category]) {
        self.recipe = recipe
        self.categories = categories
        _updatedName = State(initialValue: recipe.name ?? "")
        _updatedCategoryId = State(initialValue: Int(recipe.categoryId))
        _updatedIngredients = State(initialValue: recipe.ingredients ?? "")
        _updatedSteps = State(initialValue: recipe.steps ?? "")
        
        if let imagePath = recipe.imageName, let image = loadImage(from: imagePath) {
            _updatedImage = State(initialValue: image)
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                if isEditing {
                    TextField("Recipe Name", text: $updatedName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Picker("Category", selection: $updatedCategoryId) {
                        ForEach(categories) { category in
                            Text(category.name).tag(category.id)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    
                    TextField("Ingredients (comma-separated)", text: $updatedIngredients)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("Steps (comma-separated)", text: $updatedSteps)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Section(header: Text("Image")) {
                        if let image = updatedImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 200)
                                .cornerRadius(10)
                        } else {
                            Text("No Image Selected")
                        }
                        
                        HStack {
                            Button("Pick from Gallery") {
                                sourceType = .photoLibrary
                                showImagePicker = true
                            }
                            
                            Button("Take a Photo") {
                                sourceType = .camera
                                showImagePicker = true
                            }
                        }
                    }
                    
                    Button("Save Changes") {
                        updateRecipe()
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    
                } else {
                    Text(recipe.name ?? "Unknown Recipe")
                        .font(.largeTitle)
                        .bold()
                    
                    Text(categories.first { $0.id == recipe.categoryId }?.name ?? "Unknown Category")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    Image(uiImage: loadImage(from: recipe.imageName ?? "") ?? UIImage(named: "placeholder")!)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .cornerRadius(10)
                    
                    Text("Ingredients")
                        .font(.title2)
                        .bold()
                    Text(recipe.ingredients ?? "No ingredients available")
                        .font(.body)
                    
                    Text("Steps")
                        .font(.title2)
                        .bold()
                    Text(recipe.steps ?? "No steps available")
                        .font(.body)
                }
            }
            .padding()
            .navigationTitle("Recipe Details")
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isEditing ? "Cancel" : "Edit") {
                        if !isEditing {
                            updatedName = recipe.name ?? ""
                            updatedCategoryId = Int(recipe.categoryId)
                            updatedIngredients = recipe.ingredients ?? ""
                            updatedSteps = recipe.steps ?? ""
                            if let imagePath = recipe.imageName {
                                updatedImage = loadImage(from: imagePath)
                            }
                        }
                        isEditing.toggle()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(role: .destructive) {
                        showDeleteAlert = true
                    } label: {
                        Image(systemName: "trash")
                    }
                }
            }
            .alert("Delete Recipe?", isPresented: $showDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) { deleteRecipe() } // Proceed only if confirmed
            } message: {
                Text("Are you sure you want to delete this recipe? This action cannot be undone.")
            }
        }
    }
    
    private func updateRecipe() {
        recipe.name = updatedName
        recipe.categoryId = Int64(updatedCategoryId)
        recipe.ingredients = updatedIngredients
        recipe.steps = updatedSteps
        if let image = updatedImage, let imagePath = saveImageLocally(image: image) {
            recipe.imageName = imagePath.lastPathComponent
        }
        
        do {
            try viewContext.save()
            NotificationCenter.default.post(name: .didUpdateRecipes, object: nil)
            isEditing = false
            print("Recipe updated successfully!")
        } catch {
            print("Error updating recipe: \(error.localizedDescription)")
        }
    }
    
    func deleteRecipe() {
        let context = recipe.managedObjectContext ?? viewContext
        context.delete(recipe)

        do {
            try context.save()
            print("Recipe deleted successfully!")
            NotificationCenter.default.post(name: .didUpdateRecipes, object: nil)
            dismiss() // Close detail view after deletion
        } catch {
            print("Error deleting recipe: \(error.localizedDescription)")
        }
    }
    
    func getCategoryName(categoryId: Int) -> String {
        categories.first { $0.id == categoryId }?.name ?? "Unknown Category"
    }
    
}

//#Preview {
//    RecipeDetailView(recipe: Recipe(name: "Pasta Carbonara",
//                                    image: "pasta",
//                                    categoryId: 2,
//                                    ingredients: ["Pasta", "Eggs", "Cheese", "Bacon"],
//                                    steps: ["Boil pasta", "Cook bacon", "Mix eggs & cheese", "Combine everything"]))
//}
