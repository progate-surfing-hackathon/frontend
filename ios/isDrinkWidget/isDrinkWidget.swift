//
//  isDrinkWidget.swift
//  isDrinkWidget
//
//  Created by 岩澤慎平 on 2025/07/11.
//

import WidgetKit
import SwiftUI
import AppIntents

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationAppIntent(), counter: 0)
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        let counter = UserDefaults(suiteName: "group.progateSurfing.hackathon")?.integer(forKey: "counter") ?? 0
        return SimpleEntry(date: Date(), configuration: configuration, counter: counter)
    }

    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        var entries: [SimpleEntry] = []
        let counter = UserDefaults(suiteName: "group.com.progateSurfing.hackathon")?.integer(forKey: "counter") ?? 0
        print("WidgetKit: timeline loaded counter=\(counter)")
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, configuration: configuration, counter: counter)
            entries.append(entry)
        }
        return Timeline(entries: entries, policy: .atEnd)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
    let counter: Int
}


struct isDrinkWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack {
            Text("Steps: \(entry.counter)")
        }
    }
}

struct isDrinkWidget: Widget {
    let kind: String = "isDrinkWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            isDrinkWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
    }
}

extension ConfigurationAppIntent {
    fileprivate static var smiley: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.favoriteEmoji = "😀"
        return intent
    }
    
    fileprivate static var starEyes: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.favoriteEmoji = "🤩"
        return intent
    }
}

#Preview(as: .systemSmall) {
    isDrinkWidget()
} timeline: {
    SimpleEntry(date: .now, configuration: .smiley, counter: 0)
    SimpleEntry(date: .now, configuration: .starEyes, counter: 123)
}
