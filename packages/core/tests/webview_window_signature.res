// Type-level signature test for WebviewWindow.

let _check_make: (string, ~options: WebviewWindow.options=?) => WebviewWindow.t = WebviewWindow.make
let _check_get_current: unit => WebviewWindow.t = WebviewWindow.getCurrent
let _check_get_all: unit => promise<array<WebviewWindow.t>> = WebviewWindow.getAll
let _check_get_by_label: string => promise<Nullable.t<WebviewWindow.t>> = WebviewWindow.getByLabel
let _check_label: WebviewWindow.t => string = WebviewWindow.label
let _check_set_title: (WebviewWindow.t, string) => promise<unit> = WebviewWindow.setTitle
let _check_close: WebviewWindow.t => promise<unit> = WebviewWindow.close
let _check_set_background_color: (
  WebviewWindow.t,
  Nullable.t<Common.color>,
) => promise<unit> = WebviewWindow.setBackgroundColor

// %identity casts are externals (not lets) so they don't count toward
// the public-symbol coverage gate, but exercise them to confirm they
// compile.
let _check_as_window: WebviewWindow.t => Window.t = WebviewWindow.asWindow
let _check_as_webview: WebviewWindow.t => Webview.t = WebviewWindow.asWebview
