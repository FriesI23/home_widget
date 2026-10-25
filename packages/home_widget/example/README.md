# home_widget_example

Demonstrates how to use the home_widget plugin.

## macOS shared images example

Run this example with `flutter run -d macos --target lib/main_macos.dart`.
The dedicated macOS entry starts without Workmanager or calls to plugin APIs
that have not yet been connected on macOS. The macOS Xcode configurations select
the same entry; keep `--target lib/main_macos.dart` when using Flutter CLI tools.
The embedded `HomeWidgetExampleExtension` displays shared PNG images and Flutter
screenshots. Configuration, URLs, refresh calls, and interactive callbacks are
connected separately.

Open `macos/Runner.xcworkspace` in Xcode and select your signing team for the
Runner and HomeWidgetExampleExtension targets. Use your own matching bundle
identifiers (the extension identifier must start with the host identifier).
Without an App Group, the app shows setup instructions and the widget displays
Ready. To share images, add **one matching App Group** to both targets in
Signing & Capabilities. Ensure it is present in the host's Debug and Release
entitlements and the Widget Extension's entitlements. The demo selects the first
signed App Group in each process, so use just one group in this example; no
personal team or group identifier is stored in the public project.

Launch the signed app and select **Save images**. It shows a blue image with an
orange circle and a teal Flutter screenshot. Then add **HomeWidget macOS** from
Notification Center or, on macOS 14 and later, the desktop widget gallery. The
widget displays the same images and token. Reopen the app to restore its saved
previews. The provider reads persisted paths on snapshot/timeline creation.
Until refresh support is connected, remove and add the widget after changing
images; this step does not call the unfinished plugin refresh API.

The macOS plugin supports `setAppGroupId`, `saveWidgetData`, and `getWidgetData`.
To share data, add the same App Group to the host and Widget Extension's signing
entitlements, then set that group as the default or pass `appGroupId` per data
call. The per-call group takes precedence. Read the same suite with
`UserDefaults(suiteName:)` in Swift. Null deletes a value; missing keys use the
requested default, and typed byte data is stored as `Data`.

`setAppGroupId` only records the identifier. On macOS, data access fails with
`PlatformException` code `-9` if the resolved group is absent from the current
process's App Groups entitlement or its preferences are unavailable. It does
not fall back to private storage. The unconfigured example remains usable without an
App Group; configuration and interaction UI are added separately.

`saveFile`, `saveImage`, and `renderFlutterWidget` now resolve the App Group
container through the plugin on both iOS and macOS. Files keep the layout
`{container}/home_widget/{key}.{extension}`; the path is stored in widget data
only after the file write succeeds. Clearing a key retains the existing managed
file cleanup rules. Android continues to use its application support directory.

File saving throws if the group is not set (`-7`), the macOS process lacks its
entitlement (`-9`), the system container is unavailable (`-10`), or file I/O
fails. These errors are wrapped by the existing file-save exception. No private
directory fallback is used. Screenshot rendering requires a Dart Flutter view.
A windowless macOS engine can still provide an implicit Dart view: the current
Flutter 3.47.8 Release probe rendered a PNG without a native window or
ViewController. An engine without an implicit Dart view receives an explicit
error. This is separate from background callback execution and app-termination
support; file sharing does not depend on screenshot rendering. The output is a PNG, not a live Flutter widget embedded in
WidgetKit.

The host uses Flutter's macOS 12 deployment target; the Widget target is declared
for macOS 11. Flutter 3.47.8 raises the Widget build target to macOS 12 during
the build. These declarations do not establish compatibility with older
Flutter SDKs or prove that the example runs on macOS 11.

See Apple's [widget extension guide](https://developer.apple.com/documentation/widgetkit/creating-a-widget-extension)
for the WidgetKit target and configuration model.
