import Flutter
import UIKit
import XCTest
import home_widget

class RunnerTests: XCTestCase {

  private func initialUrl(of plugin: HomeWidgetPlugin) -> String? {
    var value: String?
    var completed = false
    plugin.handle(
      FlutterMethodCall(methodName: "initiallyLaunchedFromHomeWidget", arguments: nil)
    ) { result in
      value = result as? String
      completed = true
    }
    XCTAssertTrue(completed)
    return value
  }

  func testColdLaunchCachesWidgetUrlAndEmitsEvent() {
    let plugin = HomeWidgetPlugin()
    let url = URL(string: "homewidget://launch?homeWidget")!
    var events: [String] = []
    XCTAssertNil(plugin.onListen(withArguments: nil) { events.append($0 as! String) })

    XCTAssertTrue(
      plugin.application(
        UIApplication.shared,
        didFinishLaunchingWithOptions: [UIApplication.LaunchOptionsKey.url: url]
      ))

    XCTAssertEqual(initialUrl(of: plugin), url.absoluteString)
    XCTAssertEqual(events, [url.absoluteString])
  }

  func testRunningClicksPreserveInitialUrlAndEmitRepeatedEvents() {
    let plugin = HomeWidgetPlugin()
    let launch = URL(string: "homewidget://launch?homeWidget=true")!
    let click = URL(string: "homewidget://click?homeWidget=false")!
    XCTAssertTrue(
      plugin.application(
        UIApplication.shared,
        didFinishLaunchingWithOptions: [UIApplication.LaunchOptionsKey.url: launch]
      ))
    var events: [String] = []
    XCTAssertNil(plugin.onListen(withArguments: nil) { events.append($0 as! String) })
    XCTAssertTrue(events.isEmpty, "Listening does not replay the initial event")

    XCTAssertTrue(plugin.application(UIApplication.shared, open: click))
    XCTAssertTrue(plugin.application(UIApplication.shared, open: click))

    XCTAssertEqual(initialUrl(of: plugin), launch.absoluteString)
    XCTAssertEqual(events, [click.absoluteString, click.absoluteString])
  }

  func testWarmClickDoesNotCreateInitialUrl() {
    let plugin = HomeWidgetPlugin()
    XCTAssertTrue(
      plugin.application(UIApplication.shared, open: URL(string: "homewidget://click?homeWidget")!))
    XCTAssertNil(initialUrl(of: plugin))
  }

  func testOrdinaryUrlsAreNotConsumedOrEmitted() {
    let plugin = HomeWidgetPlugin()
    var events: [String] = []
    XCTAssertNil(plugin.onListen(withArguments: nil) { events.append($0 as! String) })
    for url in [
      URL(string: "homewidget://ordinary")!,
      URL(string: "homewidget://ordinary?other=homeWidget")!,
      URL(string: "homewidget://ordinary?homewidget=true")!,
    ] {
      XCTAssertTrue(
        plugin.application(
          UIApplication.shared,
          didFinishLaunchingWithOptions: [UIApplication.LaunchOptionsKey.url: url]
        ))
      XCTAssertFalse(plugin.application(UIApplication.shared, open: url))
    }
    XCTAssertNil(initialUrl(of: plugin))
    XCTAssertTrue(events.isEmpty)
  }

  func testCancelStopsEventsAndLateListenerCanQueryInitialUrl() {
    let plugin = HomeWidgetPlugin()
    let url = URL(string: "homewidget://launch?homeWidget")!
    XCTAssertTrue(
      plugin.application(
        UIApplication.shared,
        didFinishLaunchingWithOptions: [UIApplication.LaunchOptionsKey.url: url]
      ))
    var events: [String] = []
    XCTAssertNil(plugin.onListen(withArguments: nil) { events.append($0 as! String) })
    XCTAssertTrue(events.isEmpty)
    XCTAssertEqual(initialUrl(of: plugin), url.absoluteString)
    XCTAssertNil(plugin.onCancel(withArguments: nil))
    XCTAssertTrue(plugin.application(UIApplication.shared, open: url))
    XCTAssertTrue(events.isEmpty)
    XCTAssertEqual(initialUrl(of: plugin), url.absoluteString)
  }

  func testLifecycleSelectorsRemainVisibleToFlutter() {
    let plugin = HomeWidgetPlugin()
    let selectors = [
      "application:didFinishLaunchingWithOptions:",
      "application:openURL:options:",
      "scene:willConnectToSession:options:",
      "scene:openURLContexts:",
    ]
    for selector in selectors {
      XCTAssertTrue(plugin.responds(to: NSSelectorFromString(selector)), selector)
    }
    XCTAssertTrue(plugin.conforms(to: FlutterSceneLifeCycleDelegate.self))
  }

}
