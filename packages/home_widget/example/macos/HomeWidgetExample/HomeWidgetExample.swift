import SwiftUI
import WidgetKit

private struct HomeWidgetEntry: TimelineEntry {
  let date: Date
}

private struct Provider: TimelineProvider {
  func placeholder(in context: Context) -> HomeWidgetEntry {
    HomeWidgetEntry(date: Date())
  }

  func getSnapshot(in context: Context, completion: @escaping (HomeWidgetEntry) -> Void) {
    completion(HomeWidgetEntry(date: Date()))
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<HomeWidgetEntry>) -> Void) {
    completion(Timeline(entries: [HomeWidgetEntry(date: Date())], policy: .never))
  }
}

private struct HomeWidgetView: View {
  var body: some View {
    if #available(macOS 14.0, *) {
      content.containerBackground(.fill.tertiary, for: .widget)
    } else {
      content.padding()
    }
  }

  private var content: some View {
    VStack(alignment: .leading, spacing: 8) {
      Image(systemName: "rectangle.3.group").font(.title)
      Text("Home Widget").font(.headline)
      Text("Ready")
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
  }
}

@main
struct HomeWidgetExample: Widget {
  var body: some WidgetConfiguration {
    StaticConfiguration(kind: "HomeWidgetMacOSExample", provider: Provider()) { _ in
      HomeWidgetView()
    }
    .configurationDisplayName("HomeWidget macOS")
    .description("A simple Home Widget example.")
    .supportedFamilies([.systemSmall, .systemMedium])
  }
}
