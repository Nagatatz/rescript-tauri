/** Application metadata and lifecycle from `@tauri-apps/api/app`.

    Bindings cover the stable, cross-platform subset. Mobile / Webview
    only or experimental APIs (`fetchDataStoreIdentifiers`,
    `removeDataStore`, `getBundleType`, `onBackButtonPress`) are
    deferred to Phase 2 once their stability is confirmed.

    See: https://v2.tauri.app/reference/javascript/api/namespaceapp/
*/

/** App theme. Mirrors `Window.theme`.

    See: https://v2.tauri.app/reference/javascript/api/namespaceapp/#theme
*/
type theme = [#light | #dark]

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

    See: https://v2.tauri.app/reference/javascript/api/namespaceapp/#settheme
*/
let setTheme: (~theme: Nullable.t<theme>=?) => promise<unit>

/** Toggles the dock icon visibility (macOS-only).

    See: https://v2.tauri.app/reference/javascript/api/namespaceapp/#setdockvisibility
*/
let setDockVisibility: bool => promise<unit>
