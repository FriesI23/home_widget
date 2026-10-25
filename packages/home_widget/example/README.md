# home_widget_example

Demonstrates how to use the home_widget plugin.

## macOS widget scaffold

Run this example with `flutter run -d macos --target lib/main_macos.dart`.
The dedicated macOS entry starts without Workmanager or calls to plugin APIs
that have not yet been connected on macOS. The macOS Xcode configurations select
the same entry; keep `--target lib/main_macos.dart` when using Flutter CLI tools.
The embedded `HomeWidgetExampleExtension` currently displays a static widget;
data, images, configuration, URLs, and interactive callbacks will be connected
in later implementation steps.

Open `macos/Runner.xcworkspace` in Xcode and select your signing team for the
Runner and HomeWidgetExampleExtension targets. Use your own matching bundle
identifiers (the extension identifier must start with the host identifier).
Build and launch the app once, then add **HomeWidget macOS** from Notification
Center or, on macOS 14 and later, the desktop widget gallery. This static
scaffold does not require an App Group.

The macOS plugin supports `setAppGroupId`, `saveWidgetData`, and `getWidgetData`.
To share data, add the same App Group to the host and Widget Extension's signing
entitlements, then set that group as the default or pass `appGroupId` per data
call. The per-call group takes precedence. Read the same suite with
`UserDefaults(suiteName:)` in Swift. Null deletes a value; missing keys use the
requested default, and typed byte data is stored as `Data`.

`setAppGroupId` only records the identifier. On macOS, data access fails with
`PlatformException` code `-9` if the resolved group is absent from the current
process's App Groups entitlement or its preferences are unavailable. It does
not fall back to private storage. The static scaffold remains independent of
App Groups; data, configuration, and interaction UI are added separately.

The host uses Flutter's macOS 12 deployment target; the Widget target is declared
for macOS 11. Flutter 3.47.8 raises the Widget build target to macOS 12 during
the build. These declarations do not establish compatibility with older
Flutter SDKs or prove that the example runs on macOS 11.

See Apple's [widget extension guide](https://developer.apple.com/documentation/widgetkit/creating-a-widget-extension)
for the WidgetKit target and configuration model.
