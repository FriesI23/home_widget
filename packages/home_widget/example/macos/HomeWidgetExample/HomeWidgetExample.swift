import AppKit
import Security
import SwiftUI
import WidgetKit

private struct HomeWidgetEntry: TimelineEntry {
  let date: Date
  var image: Data?
  var screenshot: Data?
  var token: String?
}

private struct Provider: TimelineProvider {
  private func entry() -> HomeWidgetEntry {
    var entry = HomeWidgetEntry(date: Date())
    guard let task = SecTaskCreateFromSelf(nil),
      let groups = SecTaskCopyValueForEntitlement(
        task, "com.apple.security.application-groups" as CFString, nil) as? [String],
      let group = groups.first,
      let defaults = UserDefaults(suiteName: group)
    else {
      return entry
    }
    if let path = defaults.string(forKey: "example_image") {
      entry.image = try? Data(contentsOf: URL(fileURLWithPath: path))
    }
    if let path = defaults.string(forKey: "example_screenshot") {
      entry.screenshot = try? Data(contentsOf: URL(fileURLWithPath: path))
    }
    entry.token = defaults.string(forKey: "example_token")
    return entry
  }

  func placeholder(in context: Context) -> HomeWidgetEntry {
    HomeWidgetEntry(date: Date())
  }

  func getSnapshot(in context: Context, completion: @escaping (HomeWidgetEntry) -> Void) {
    completion(entry())
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<HomeWidgetEntry>) -> Void) {
    completion(Timeline(entries: [entry()], policy: .never))
  }
}

private struct HomeWidgetView: View {
  let entry: HomeWidgetEntry

  var body: some View {
    if #available(macOS 14.0, *) {
      content.containerBackground(.fill.tertiary, for: .widget)
    } else {
      content.padding()
    }
  }

  private var content: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("Home Widget").font(.headline)
      if let data = entry.image, let image = NSImage(data: data),
        let screenshotData = entry.screenshot, let screenshot = NSImage(data: screenshotData)
      {
        HStack {
          Image(nsImage: image).resizable().scaledToFit()
          Image(nsImage: screenshot).resizable().scaledToFit()
        }
        .frame(height: 60)
        Text("Images ready").font(.caption)
        Text(entry.token ?? "").font(.caption2).lineLimit(1)
      } else {
        Image(systemName: "rectangle.3.group").font(.title)
        Text("Ready")
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    .widgetURL(URL(string: "homewidget-macos://widget?homeWidget"))
  }
}

@main
struct HomeWidgetExample: Widget {
  var body: some WidgetConfiguration {
    StaticConfiguration(kind: "HomeWidgetMacOSExample", provider: Provider()) { entry in
      HomeWidgetView(entry: entry)
    }
    .configurationDisplayName("HomeWidget macOS")
    .description("Shared image and Flutter screenshot example.")
    .supportedFamilies([.systemSmall, .systemMedium])
  }
}
