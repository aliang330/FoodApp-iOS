//
//  FoodAppWidget.swift
//  FoodAppWidget
//
//  Created by Allen Liang on 3/16/22.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    
    func placeholder(in context: Context) -> WidgetTimelineEntry {
        WidgetTimelineEntry(date: Date(), foodImage: .shakeShack)
    }

    func getSnapshot(in context: Context, completion: @escaping (WidgetTimelineEntry) -> ()) {
        let entry = WidgetTimelineEntry(date: Date(), foodImage: .shakeShack)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [WidgetTimelineEntry] = []

        // get entry data from shared url
        let sharedUrl = AppGroup.main.containerURL
        let imagesUrl = sharedUrl.appendingPathComponent("images")
        var widgetEntries: [WidgetEntry] = []
        do {
            let widgetEntryData = try Data(contentsOf: sharedUrl.appendingPathComponent("widgetEntryData"))
            widgetEntries = try JSONDecoder().decode([WidgetEntry].self, from: widgetEntryData)
        } catch {
            print(error)
        }

        if widgetEntries.isEmpty {
            entries = [.init(date: Date(), foodImage: .shakeShack)]
            let timeline = Timeline(entries: entries, policy: .never)
            completion(timeline)
            return
        }

        let entriesCount = widgetEntries.count

        let currentDate = Date()
        for i in 0 ..< entriesCount {
            let entryDate = Calendar.current.date(byAdding: .hour, value: i * 3, to: currentDate)!
            let widgetEntry = widgetEntries[i]
            let foodImageUrl = imagesUrl.appendingPathComponent(widgetEntry.imageName)

            do {
                let imageData = try Data(contentsOf: foodImageUrl)
                print(imageData)
                if let foodImage = UIImage(data: imageData) {
                    
                    let entry = WidgetTimelineEntry(date: entryDate, foodImage: foodImage)
                    entries.append(entry)
                } else {
                    let entry = WidgetTimelineEntry(date: entryDate, foodImage: sampleImages[entriesCount])
                    entries.append(entry)
                }
            } catch {
                print(error)
            }
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
    
//    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
//        var entries: [WidgetTimelineEntry] = []
//        let currentDate = Date()
//
//        for i in 0..<sampleImages.count {
//            let entryDate = Calendar.current.date(byAdding: .second, value: i * 2, to: currentDate)!
//            entries.append(.init(date: entryDate, foodImage: sampleImages[i]))
//        }
//
//        let timeline = Timeline(entries: entries, policy: .atEnd)
//        completion(timeline)
//    }
}

struct PlaceholderView: View {
    var body: some View {
        FoodImageView(uiImage: .shakeShack)
//            .redacted(reason: .placeholder)
    }
}

struct WidgetTimelineEntry: TimelineEntry {
    let date: Date
    let foodImage: UIImage
}

struct FoodAppWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        FoodImageView(uiImage: entry.foodImage)
    }
}

@main
struct FoodAppWidget: Widget {
    let kind: String = "FoodAppWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            FoodAppWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct FoodAppWidget_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            FoodAppWidgetEntryView(entry: WidgetTimelineEntry(date: Date(), foodImage: .shakeShack))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
            
            FoodAppWidgetEntryView(entry: WidgetTimelineEntry(date: Date(), foodImage: .shakeShack))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
            
            FoodAppWidgetEntryView(entry: WidgetTimelineEntry(date: Date(), foodImage: .shakeShack))
                .previewContext(WidgetPreviewContext(family: .systemExtraLarge))
            
            PlaceholderView()
                .previewContext(WidgetPreviewContext(family: .systemSmall))
        }
       
    }
}

struct FoodImageView: View {
    let uiImage: UIImage
    
    var body: some View {
        Image(uiImage: uiImage)
            .resizable()
            .aspectRatio(contentMode: .fill)
    }
}

extension UIImage {
    static var shakeShack = UIImage(named: "shake-shack")!
}

var sampleImages: [UIImage] = [
    .init(named: "shake-shack")!,
    .init(named: "chinese-food")!,
    .init(named: "pancakes")!,
    .init(named: "pizza")!,
    .init(named: "taco")!,
    .init(named: "yelp")!,
    
    
]
