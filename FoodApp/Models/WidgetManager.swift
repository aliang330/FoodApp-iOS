//
//  WidgetManager.swift
//  FoodApp
//
//  Created by Allen Liang on 3/18/22.
//

import Foundation
import WidgetKit

struct WidgetManager {
    
    static func refreshWidgetData() {

        let lastRefreshDate = ProfileManager.lastWidgetRefreshDate
        
        if let lastRefreshDate = lastRefreshDate,
        let refreshDate = Calendar.current.date(byAdding: .hour, value: 24, to: lastRefreshDate) {
            if refreshDate > Date() { return }
        }
        
        let sharedImagesURL = AppGroup.main.sharedImageURL
        let widgetEntryDataUrl = AppGroup.main.widgetDataURL
        PersistenceManager.removeItemsAtUrl(url: sharedImagesURL)
        let photoEntries = PersistenceManager.fetchRandomPhotoEntries(count: 3)
        if photoEntries.count == 0 {
            return
        }
        
        var widgetEntries: [WidgetEntry] = []
        
        do {
            try PersistenceManager.shared.createPathIfNotExist(url: sharedImagesURL)
            
            try photoEntries.forEach {
                if let image = PersistenceManager.loadUserImageFromFileSystem(path: $0.imageUrl),
                   let imageData = image.jpegData(compressionQuality: 1.0),
                   let relativePath = URL(string: $0.imageUrl) {
                    
                    let fileNameWithoutExtension = relativePath.deletingPathExtension().lastPathComponent
                    let actualFileName = try PersistenceManager.shared.saveImageToFileDirectory(path: sharedImagesURL, fileName: fileNameWithoutExtension, imageData: imageData)
                    let widgetEntry = WidgetEntry(restaurantID: $0.restaurantID, imageName: actualFileName)
                    widgetEntries.append(widgetEntry)
                }
            }
            
            let widgetEntryData = try JSONEncoder().encode(widgetEntries)
            try widgetEntryData.write(to: widgetEntryDataUrl, options: .atomic)
            ProfileManager.setWidgetRefreshDate(date: Date())
            WidgetCenter.shared.reloadTimelines(ofKind: "FoodAppWidget")
            copyImagesFolder()
        } catch {
            print(error)
            PersistenceManager.removeItemsAtUrl(url: widgetEntryDataUrl)
        }
    }
    
    static func copyImagesFolder() {
        let sharedImageUrl = AppGroup.main.sharedImageURL
        let dest = FileManager.documentsDirectory.appendingPathComponent("debugging")
        
        do {
            try FileManager.default.copyItem(at: sharedImageUrl, to: dest)
        } catch {
            print(error)
        }
    }
}


