type t

type options = {
  url?: string,
  title?: string,
  width?: float,
  height?: float,
  x?: float,
  y?: float,
  resizable?: bool,
  fullscreen?: bool,
  focus?: bool,
  transparent?: bool,
  decorations?: bool,
  alwaysOnTop?: bool,
  skipTaskbar?: bool,
}

@module("@tauri-apps/api/window") @new
external make: (string, ~options: options=?) => t = "Window"

@module("@tauri-apps/api/window") @scope("Window")
external getCurrent: unit => t = "getCurrent"

@module("@tauri-apps/api/window") @scope("Window")
external getAll: unit => array<t> = "getAll"

@module("@tauri-apps/api/window") @scope("Window")
external getByLabel: string => promise<Nullable.t<t>> = "getByLabel"

@send external label: t => string = "label"
@send external setTitle: (t, string) => promise<unit> = "setTitle"
@send external title: t => promise<string> = "title"
@send external close: t => promise<unit> = "close"
@send external destroy: t => promise<unit> = "destroy"
@send external show: t => promise<unit> = "show"
@send external hide: t => promise<unit> = "hide"
@send external isVisible: t => promise<bool> = "isVisible"
@send external minimize: t => promise<unit> = "minimize"
@send external maximize: t => promise<unit> = "maximize"
@send external unmaximize: t => promise<unit> = "unmaximize"
@send external isMaximized: t => promise<bool> = "isMaximized"
@send external isMinimized: t => promise<bool> = "isMinimized"
@send external setFocus: t => promise<unit> = "setFocus"
@send external isFocused: t => promise<bool> = "isFocused"
@send external setSize: (t, 'size) => promise<unit> = "setSize"
@send external setPosition: (t, 'position) => promise<unit> = "setPosition"
@send external center: t => promise<unit> = "center"
@send external setFullscreen: (t, bool) => promise<unit> = "setFullscreen"
@send external setResizable: (t, bool) => promise<unit> = "setResizable"
@send external setAlwaysOnTop: (t, bool) => promise<unit> = "setAlwaysOnTop"
