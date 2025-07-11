//
//  isDrinkWidgetLiveActivity.swift
//  isDrinkWidget
//
//  Created by 岩澤慎平 on 2025/07/11.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct isDrinkWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct isDrinkWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: isDrinkWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension isDrinkWidgetAttributes {
    fileprivate static var preview: isDrinkWidgetAttributes {
        isDrinkWidgetAttributes(name: "World")
    }
}

extension isDrinkWidgetAttributes.ContentState {
    fileprivate static var smiley: isDrinkWidgetAttributes.ContentState {
        isDrinkWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: isDrinkWidgetAttributes.ContentState {
         isDrinkWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: isDrinkWidgetAttributes.preview) {
   isDrinkWidgetLiveActivity()
} contentStates: {
    isDrinkWidgetAttributes.ContentState.smiley
    isDrinkWidgetAttributes.ContentState.starEyes
}
