// Verifies that the Tauri umbrella module re-exports Common / Core /
// Event / Window / Webview / WebviewWindow without altering their
// signatures.

let _check_common_unlisten: Tauri.Common.unlisten = () => ()
let _check_common_color: Tauri.Common.color = {r: 0, g: 0, b: 0, a: 255}
let _check_common_drag_drop_leave: Tauri.Common.dragDropEvent = Leave

let _check_core_invoke: (
  string,
  ~args: 'args=?,
  ~options: Tauri.Core.Raw.invokeOptions=?,
) => promise<'r> = Tauri.Core.Raw.invoke

let _check_command_make: (
  ~name: string,
  ~encodeArgs: 'a => JSON.t,
  ~decodeResult: JSON.t => result<'r, string>,
) => Tauri.Core.Command.t<'a, 'r> = Tauri.Core.Command.make

let _check_channel_make: (
  ~decode: JSON.t => result<'m, string>,
) => Tauri.Core.Channel.t<'m> = Tauri.Core.Channel.make

let _check_event_make: (
  ~name: string,
  ~decode: JSON.t => result<'p, string>,
) => Tauri.Event.t<'p> = Tauri.Event.make

let _check_window_get_current: unit => Tauri.Window.t = Tauri.Window.getCurrent
let _check_window_set_title: (Tauri.Window.t, string) => promise<unit> = Tauri.Window.setTitle

let _check_webview_get_current: unit => Tauri.Webview.t = Tauri.Webview.getCurrentWebview

let _check_webview_window_get_current: unit => Tauri.WebviewWindow.t = Tauri.WebviewWindow.getCurrent
let _check_webview_window_as_window: Tauri.WebviewWindow.t => Tauri.Window.t = Tauri.WebviewWindow.asWindow
let _check_webview_window_as_webview: Tauri.WebviewWindow.t => Tauri.Webview.t = Tauri.WebviewWindow.asWebview
