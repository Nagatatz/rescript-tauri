/** Application metadata and lifecycle from `@tauri-apps/api/app`.

    Bindings cover the full stable surface of `@tauri-apps/api/app`,
    including macOS / iOS data-store helpers, the Android back-button
    listener, and capability checks.

    See: https://v2.tauri.app/reference/javascript/api/namespaceapp/
*/

/** App theme. Re-exported from `Window.theme` so values flow between
    `App.setTheme` and `Window.setTheme` without conversion.

    See: https://v2.tauri.app/reference/javascript/api/namespaceapp/#theme
*/
type theme = Window.theme

/** A 128-bit identifier (16 bytes) used to address a data store on
    macOS / iOS. Represented as `array<int>` matching upstream's
    fixed-length-tuple encoding.

    See: https://v2.tauri.app/reference/javascript/api/namespaceapp/#datastoreidentifier
*/
type dataStoreIdentifier = array<int>

/** Bundle format the running application was packaged in.

    See: https://v2.tauri.app/reference/javascript/api/namespaceapp/#bundletype
*/
type bundleType = [
  | /** Windows NSIS installer. */
  #nsis
  | /** Windows MSI installer. */
  #msi
  | /** Linux Debian package. */
  #deb
  | /** Linux RPM package. */
  #rpm
  | /** Linux AppImage. */
  #appimage
  | /** macOS `.app` bundle. */
  #app
]

/** Payload delivered to the `onBackButtonPress` callback (Android).

    `canGoBack` mirrors the webview's `canGoBack` property — the
    handler can choose to navigate back rather than exit the app.

    See: https://v2.tauri.app/reference/javascript/api/namespaceapp/#onbackbuttonpresspayload
*/
type onBackButtonPressPayload = {canGoBack: bool}

/** Returns the application name from `tauri.conf.json`.

    See: https://v2.tauri.app/reference/javascript/api/namespaceapp/#getname
*/
let getName: unit => promise<string>

/** Returns the application version from `tauri.conf.json`.

    See: https://v2.tauri.app/reference/javascript/api/namespaceapp/#getversion
*/
let getVersion: unit => promise<string>

/** Returns the version of the Tauri runtime the app was bundled with.

    See: https://v2.tauri.app/reference/javascript/api/namespaceapp/#gettauriversion
*/
let getTauriVersion: unit => promise<string>

/** Returns the application's bundle identifier.

    See: https://v2.tauri.app/reference/javascript/api/namespaceapp/#getidentifier
*/
let getIdentifier: unit => promise<string>

/** Shows the application (macOS-specific).

    See: https://v2.tauri.app/reference/javascript/api/namespaceapp/#show
*/
let show: unit => promise<unit>

/** Hides the application (macOS-specific).

    See: https://v2.tauri.app/reference/javascript/api/namespaceapp/#hide
*/
let hide: unit => promise<unit>

/** Returns the default window icon, or `Nullable.null` if none is
    configured. The opaque return value is a Tauri `Image` resource —
    it can be passed to `Window.setIcon`, `TrayIcon.setIcon`, etc.

    See: https://v2.tauri.app/reference/javascript/api/namespaceapp/#defaultwindowicon
*/
let defaultWindowIcon: unit => promise<Nullable.t<Image.t>>

/** Sets the application's preferred theme. Pass `Nullable.null` to
    defer to the OS setting.

    Aligned with `Window.setTheme(t, Nullable.t<theme>)` so callers
    can flow theme values between the two APIs without restructuring
    the call site.

    See: https://v2.tauri.app/reference/javascript/api/namespaceapp/#settheme
*/
let setTheme: Nullable.t<theme> => promise<unit>

/** Toggles the dock icon visibility (macOS-only).

    See: https://v2.tauri.app/reference/javascript/api/namespaceapp/#setdockvisibility
*/
let setDockVisibility: bool => promise<unit>

/** Returns the `WKWebsiteDataStore` identifiers known to the OS
    (macOS / iOS only).

    See: https://v2.tauri.app/reference/javascript/api/namespaceapp/#fetchdatastoreidentifiers
*/
let fetchDataStoreIdentifiers: unit => promise<array<dataStoreIdentifier>>

/** Removes a `WKWebsiteDataStore` by its identifier (macOS / iOS).

    Any webview using the targeted data store should be closed before
    invoking this; the upstream API rejects otherwise.

    See: https://v2.tauri.app/reference/javascript/api/namespaceapp/#removedatastore
*/
let removeDataStore: dataStoreIdentifier => promise<unit>

/** Returns the bundle type the running application was installed as.

    See: https://v2.tauri.app/reference/javascript/api/namespaceapp/#getbundletype
*/
let getBundleType: unit => promise<bundleType>

/** Subscribes to the Android back-button press event. The callback
    receives `{canGoBack}` so the handler can decide between webview
    navigation and app exit. Returns a `Core.PluginListener.t` —
    call its `unregister` to stop listening.

    See: https://v2.tauri.app/reference/javascript/api/namespaceapp/#onbackbuttonpress
*/
let onBackButtonPress: (
  onBackButtonPressPayload => unit,
) => promise<Core.PluginListener.t>

/** Returns whether the platform supports multiple top-level windows.

    See: https://v2.tauri.app/reference/javascript/api/namespaceapp/#supportsmultiplewindows
*/
let supportsMultipleWindows: unit => promise<bool>
