//
//  Utils.swift
//  myRecipe
//
//  Created by Mohamad Shawal Sapuan Bin Mohamad on 12/06/2025.
//

import Foundation
import UIKit

func loadJSON<T: Decodable>(fileName: String) -> T? {
    guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
        print("JSON file not found")
        return nil
    }
    
    do {
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(T.self, from: data)
    } catch {
        print("Error decoding JSON: \(error)")
        return nil
    }
}

//func saveImageLocally(image: UIImage, imageName: String) -> URL? {
//    guard let data = image.jpegData(compressionQuality: 0.8) else { return nil }
//    
//    let filename = getDocumentsDirectory().appendingPathComponent("\(imageName).jpg")
//    
//    do {
//        try data.write(to: filename)
//        print("Image saved successfully!")
//        return filename
//    } catch {
//        print("Error saving image: \(error.localizedDescription)")
//        return nil
//    }
//}

func saveImageLocally(image: UIImage) -> URL? {
    guard let data = image.jpegData(compressionQuality: 0.8) else { return nil }
    let filename = getDocumentsDirectory().appendingPathComponent("\(UUID().uuidString).jpg")
    
    do {
        try data.write(to: filename)
        print("Image saved successfully!")
        return filename
    } catch {
        print("Error saving image: \(error.localizedDescription)")
        return nil
    }
}

func getDocumentsDirectory() -> URL {
    FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
}

func loadImage(from imageName: String) -> UIImage? {
    let fileURL = getDocumentsDirectory().appendingPathComponent(imageName)
    
    if FileManager.default.fileExists(atPath: fileURL.path) {
        return UIImage(contentsOfFile: fileURL.path)
    }
    
    return UIImage(named: "placeholder_image") // Fallback image
}

extension Notification.Name {
    static let didUpdateRecipes = Notification.Name("didUpdateRecipes")
}
