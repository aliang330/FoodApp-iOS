//
//  PersistenceContainer.swift
//  FoodApp
//
//  Created by Allen Liang on 3/7/22.
//

import Foundation
import CoreData
import UIKit

protocol PersistenceServiceProvider {
    func checkIfRestaurantInWishList(restaurantID: String) -> Bool
    func loadPhotoEntries(for restaurantID: String) -> [PhotoEntry]
    func removeFromWishList(restaurantID: String)
    func addRestaurantToWishList(restaurant: Business, completion: @escaping (PersistenceError?) ->())
}

enum PersistenceError: Error {
    case noImageData
    case errorSavingImage
    case errorAddingWishListEntry
    case errorCreatingPath
}

class PersistenceManager: PersistenceServiceProvider {
    static let shared = PersistenceManager()
    var moc: NSManagedObjectContext {
        container.viewContext
    }
    
    var userImageCache = NSCache<NSString, UIImage>()
    
    let container: NSPersistentContainer
    
    init() {
        self.container = NSPersistentContainer(name: "Model")
        
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("unable to load persistent stores \(error)")
            }
        }
    }
    
    func storeImageEntry(entryData: PhotoEntry.PhotoEntryData, completion: @escaping (PersistenceError?)->()) {
        let imagesFolder = Folders.images
        guard let imageData = entryData.image.jpegData(compressionQuality: 1.0) else {
            completion(.noImageData)
            return
        }
        do {
            try createPathIfNotExist(url: imagesFolder)
            let fileName = try saveImageToFileDirectory(path: imagesFolder, fileName: entryData.imageName, imageData: imageData)
            
            let photoEntry = PhotoEntry(context: moc)
            photoEntry.set(restaurantID: entryData.restaurantID,
                           imagePath: "images/\(fileName)",
                           caption: entryData.caption)
            
            try moc.save()
        } catch {
            completion(.errorSavingImage)
            return
        }
        completion(nil)
    }
    
    func saveImageToFileDirectory(path: URL, fileName:String, imageData: Data) throws -> String {
        var proposedFileName = fileName + ".jpeg"
        var proposedPath = path.appendingPathComponent(proposedFileName)
        var counter = 1
        while FileManager.default.fileExists(atPath: proposedPath.path) {
            proposedFileName = fileName + "(\(counter))" + ".jpeg"
            proposedPath = path.appendingPathComponent(proposedFileName)
            counter += 1
        }
    
        try imageData.write(to: proposedPath, options: .atomic)
        return proposedFileName
    }
    
    static func loadUserImageFromFileSystem(path: String) -> UIImage? {
        let cache = PersistenceManager.shared.userImageCache
        let cacheKey = NSString(string: path)
        
        if let image = cache.object(forKey: cacheKey) {
            return image
        }
        
        let url = FileManager.documentsDirectory.appendingPathComponent(path)
        do {
            let imageData = try Data(contentsOf: url)
            guard let image = UIImage(data: imageData) else { return nil }
            cache.setObject(image, forKey: cacheKey)
            return image
        } catch {
            return nil
        }
    }
    
    func loadPhotoEntries(for restaurantID: String) -> [PhotoEntry] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "PhotoEntry")
        request.sortDescriptors = [
            NSSortDescriptor(key: "dateAdded", ascending: false)
            ]
        request.predicate = NSPredicate(format: "restaurantID == %@", restaurantID)
        
        do {
            guard let photoEntries = try moc.fetch(request) as? [PhotoEntry] else {
                return []
            }
            return photoEntries
        } catch {
            return []
        }
    }
    
    func addRestaurantToWishList(restaurant: Business, completion: @escaping (PersistenceError?) ->()) {
        var restaurantImagesUrl = FileManager.documentsDirectory.appendingPathComponent("restaurantImages")
        do {
            try createPathIfNotExist(url: restaurantImagesUrl)
        } catch {
            completion(.errorCreatingPath)
        }
        let fileName = restaurant.id + ".jpeg"
        restaurantImagesUrl.appendPathComponent(fileName)
        var imageData = Data()
        let dispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()
        NetworkManager.shared.downloadImageForRestaurant(from: restaurant.image_url) { image in
            imageData = image?.jpegData(compressionQuality: 1.0) ?? Data()
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) {
            do {
                try imageData.write(to: restaurantImagesUrl, options: .atomic)
            } catch {
                print(error)
                completion(.errorSavingImage)
            }
            let wishListEntry = WishListEntry(context: self.moc)
            wishListEntry.set(restaurant: restaurant)
            
            do {
                try self.moc.save()
                completion(nil)
            } catch {
                self.moc.reset()
                print(error)
                completion(.errorAddingWishListEntry)
            }
            
        }
    }
    
    func createPathIfNotExist(url: URL) throws {
        if !FileManager.default.fileExists(atPath: url.path) {
            try FileManager.default.createDirectory(atPath: url.path, withIntermediateDirectories: true, attributes: nil)
        }
    }
    
    static func fetchWishListEntries() -> [WishListEntry]? {
        let moc = shared.container.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "WishListEntry")
        request.sortDescriptors = [
            NSSortDescriptor(key: "dateAdded", ascending: false)
            ]
        
        do {
            guard let wishListEntries = try moc.fetch(request) as? [WishListEntry] else {
                return nil
            }
            return wishListEntries
        } catch {
            print(error)
            return nil
        }
    }
    
    func checkIfRestaurantInWishList(restaurantID: String) -> Bool {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "WishListEntry")
        
        request.fetchLimit = 1
        request.predicate = NSPredicate(format: "restaurantID == %@", restaurantID)
        
        do {
            let count = try moc.count(for: request)
            return count > 0 ? true : false
        } catch {
            print(error)
        }
        return false
    }
    
    func removeFromWishList(restaurantID: String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "WishListEntry")
        fetchRequest.fetchLimit = 1
        fetchRequest.predicate = NSPredicate(format: "restaurantID == %@", restaurantID)
        
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try moc.execute(deleteRequest)
            try moc.save()
        } catch {
            print(error)
        }
    }
    
    static func deletePhotoEntry(photoEntry: PhotoEntry) {
        //delete image from file system
        let path = FileManager.documentsDirectory.appendingPathComponent(photoEntry.imageUrl)
        do {
            try FileManager.default.removeItem(at: path)
        } catch {
            print(error)
        }
        
        let moc = shared.container.viewContext
        moc.delete(photoEntry)
        
        do {
            try moc.save()
        } catch {
            print(error)
        }
    }
    
    static func saveChangesToPhotoEntry(photoEntry: PhotoEntry, newCaption: String) {
        photoEntry.caption = newCaption
        let moc = shared.container.viewContext
        
        do {
            try moc.save()
        } catch {
            print(error)
        }
    }
    
    static func fetchRandomPhotoEntries(count: Int) -> [PhotoEntry] {
        var results: [PhotoEntry] = []
        let moc = shared.moc
        let fetchRequest = NSFetchRequest<PhotoEntry>(entityName: "PhotoEntry")
        

        do {
            let totalPhotoEntriesCount = try moc.count(for: fetchRequest)
            fetchRequest.fetchLimit = 1
            var offsets = Array(0..<totalPhotoEntriesCount)
            offsets.shuffle()
            var randomOffsets: ArraySlice<Int> = []
            totalPhotoEntriesCount < count ? (randomOffsets = offsets[0..<totalPhotoEntriesCount]) : (randomOffsets = offsets[0..<count])
            
            for offset in randomOffsets {
                fetchRequest.fetchOffset = offset
                let fetchedEntries = try moc.fetch(fetchRequest)
                if let photoEntry = fetchedEntries.first {
                    results.append(photoEntry)
                }
            }
        } catch {
            print(error)
        }
        
        return results
    }
    
    static func removeItemsAtUrl(url: URL) {
        do {
            try FileManager.default.removeItem(at: url)
        } catch {
            print(error)
        }
    }
}
  
