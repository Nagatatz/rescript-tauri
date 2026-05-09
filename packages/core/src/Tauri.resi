/** Top-level umbrella module for `@rescript-tauri/core`.

    `open Tauri` brings the most commonly co-used Phase 1 modules into
    scope: shared cross-cutting types (`Common`), IPC (`Core`), event
    pub/sub (`Event`), and the window / webview surface (`Window`,
    `Webview`, `WebviewWindow`). Other modules (`Path`, `App`, `Dpi`,
    `Image`, `Menu`, `Tray`, `Mocks`) are intentionally **not**
    re-exported — they are either utility namespaces, heavy sub-module
    trees, or test-only — and should be referenced explicitly as
    `Path.appConfigDir()`, `Menu.Menu.make()`, etc.

    Decision recorded in PRD §10 #1 and steering 023.

    See: https://v2.tauri.app/reference/javascript/api/
*/

/** Shared cross-cutting types used across Window / Webview /
    WebviewWindow / Event: `unlisten`, `color`, `dragDropEvent`.
*/
module Common = Common

/** IPC bridge: `Raw.invoke`, typed `Command`, streaming `Channel`,
    and `convertFileSrc`.
*/
module Core = Core

/** Pub/sub event bus: `make`, `listen`, `once`, `emit`, `emitTo`. */
module Event = Event

/** Window class: opaque handle + 80+ methods (theme, cursor, monitor,
    drag/resize, on* event handlers, etc.).
*/
module Window = Window

/** Webview class: opaque handle + 14 instance methods + drag-and-drop
    event subscription.
*/
module Webview = Webview

/** Combined Window + Webview surface. Use `WebviewWindow.asWindow` /
    `asWebview` for zero-cost view casts.
*/
module WebviewWindow = WebviewWindow
