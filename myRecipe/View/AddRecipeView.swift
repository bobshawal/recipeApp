//
//  AddRecipeView.swift
//  myRecipe
//
//  Created by Mohamad Shawal Sapuan Bin Mohamad on 12/06/2025.
//

import SwiftUI
import PhotosUI

struct AddRecipeView: View {
    @Environment(\.dismiss) var dismiss
    let viewContext = DataManager.shared.container.viewContext
    
    var categories: [Category]
    @State private var recipeName = ""
    @State private var imageName = ""
    @State private var selectedCategoryId = 1
    @State private var ingredients = ""
    @State private var steps = ""
    
    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Recipe Details")) {
                    TextField("Recipe Name", text: $recipeName)
                }
                
                Section(header: Text("Category")) {
                    Picker("Select Category", selection: $selectedCategoryId) {
                        ForEach(categories) { category in
                            Text(category.name).tag(category.id)
                        }
                    }
                }
                
                Section(header: Text("Ingredients")) {
                    TextField("Comma-separated (e.g., Flour, Milk, Sugar)", text: $ingredients)
                }
                
                Section(header: Text("Steps")) {
                    TextField("Comma-separated (e.g., Mix, Bake, Serve)", text: $steps)
                }
                
                Section(header: Text("Image")) {
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 150)
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
                
                Button("Save Recipe") {
                    saveRecipe()
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .navigationTitle("Add New Recipe")
            .toolbar {
                Button("Close") {
                    dismiss()
                }
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(selectedImage: $selectedImage, sourceType: sourceType)
            }
        }
    }
    
    private func saveRecipe() {
        let recipe = RecipeEntity(context: viewContext)
        recipe.id = UUID()
        recipe.name = recipeName
        recipe.categoryId = Int64(selectedCategoryId)
        recipe.ingredients = ingredients
        recipe.steps = steps
        
        if let image = selectedImage, let imagePath = saveImageLocally(image: image) {
            recipe.imageName = imagePath.lastPathComponent
        }
        
        do {
            try viewContext.save()
            NotificationCenter.default.post(name: .didUpdateRecipes, object: nil)
            dismiss()
            print("Recipe saved successfully!")
        } catch {
            print("Error saving recipe: \(error.localizedDescription)")
        }
    }
}

//#Preview {
//    let categories = [
//        Category(id: 1, name: "Breakfast"),
//        Category(id: 2, name: "Lunch & Dinner")
//    ]
//    
//    AddRecipeView(categories: categories)
//}
