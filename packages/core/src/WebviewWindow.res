type t

external asWindow: t => Window.t = "%identity"
external asWebview: t => Webview.t = "%identity"

type options = {
  url?: string,
  userAgent?: string,
  zoomHotkeysEnabled?: bool,
  acceptFirstMouse?: bool,
  dragDropEnabled?: bool,
  transparent?: bool,
  title?: string,
  width?: float,
  height?: float,
  x?: float,
  y?: float,
  resizable?: bool,
  fullscreen?: bool,
  focus?: bool,
  decorations?: bool,
  alwaysOnTop?: bool,
  alwaysOnBottom?: bool,
  contentProtected?: bool,
  skipTaskbar?: bool,
  shadow?: bool,
  theme?: Window.theme,
  titleBarStyle?: Window.titleBarStyle,
  hiddenTitle?: bool,
  tabbingIdentifier?: string,
  maximized?: bool,
  visible?: bool,
  closable?: bool,
  parent?: Window.t,
  visibleOnAllWorkspaces?: bool,
  backgroundColor?: Common.color,
}

@module("@tauri-apps/api/webviewWindow") @new
external make: (string, ~options: options=?) => t = "WebviewWindow"

@module("@tauri-apps/api/webviewWindow")
external getCurrent: unit => t = "getCurrentWebviewWindow"

@module("@tauri-apps/api/webviewWindow")
external getAll: unit => promise<array<t>> = "getAllWebviewWindows"

@module("@tauri-apps/api/webviewWindow") @scope("WebviewWindow")
external getByLabel: string => promise<Nullable.t<t>> = "getByLabel"

@get external label: t => string = "label"
@send external setTitle: (t, string) => promise<unit> = "setTitle"
@send external close: t => promise<unit> = "close"
@send
external setBackgroundColor: (t, Nullable.t<Common.color>) => promise<unit> = "setBackgroundColor"
