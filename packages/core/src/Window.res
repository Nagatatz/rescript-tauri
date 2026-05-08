type t

type unlisten = unit => unit

type theme = [#light | #dark]

type userAttentionType = [#critical | #informational]

type cursorIcon = [
  | #default
  | #crosshair
  | #hand
  | #arrow
  | #move
  | #text
  | #wait
  | #help
  | #progress
  | #notAllowed
  | #contextMenu
  | #cell
  | #verticalText
  | #alias
  | #copy
  | #noDrop
  | #grab
  | #grabbing
  | #allScroll
  | #zoomIn
  | #zoomOut
  | #eResize
  | #nResize
  | #neResize
  | #nwResize
  | #sResize
  | #seResize
  | #swResize
  | #wResize
  | #ewResize
  | #nsResize
  | #neswResize
  | #nwseResize
  | #colResize
  | #rowResize
]

type resizeDirection = [
  | #East
  | #North
  | #NorthEast
  | #NorthWest
  | #South
  | #SouthEast
  | #SouthWest
  | #West
]

type titleBarStyle = [#visible | #transparent | #overlay]

type progressBarStatus = [#none | #normal | #indeterminate | #paused | #error]

type progressBarState = {
  status?: progressBarStatus,
  progress?: int,
}

type windowSizeConstraints = {
  minWidth?: float,
  minHeight?: float,
  maxWidth?: float,
  maxHeight?: float,
}

type closeRequestedEvent = {
  preventDefault: unit => unit,
  isPreventDefault: unit => bool,
}

type scaleFactorChanged = {
  scaleFactor: float,
  size: Dpi.PhysicalSize.t,
}

type color = {r: int, g: int, b: int, a: int}

type effectStyle = [
  | #appearanceBased
  | #blur
  | #acrylic
  | #vibrancy
  | #mica
  | #tabbed
  | #tabbedDark
  | #tabbedLight
  | #titlebar
  | #selection
  | #menu
  | #popover
  | #sidebar
  | #headerView
  | #sheet
  | #windowBackground
  | #hudWindow
  | #fullScreenUI
  | #toolTip
  | #contentBackground
  | #underWindowBackground
  | #underPageBackground
]

type effectState = [
  | #followsWindowActiveState
  | #active
  | #inactive
]

type effects = {
  effects: array<effectStyle>,
  state?: effectState,
  radius?: float,
  color?: color,
}

type monitor = {
  name: Nullable.t<string>,
  size: Dpi.PhysicalSize.t,
  position: Dpi.PhysicalPosition.t,
  scaleFactor: float,
}

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
  alwaysOnBottom?: bool,
  contentProtected?: bool,
  skipTaskbar?: bool,
  shadow?: bool,
  theme?: theme,
  titleBarStyle?: titleBarStyle,
  hiddenTitle?: bool,
  acceptFirstMouse?: bool,
  tabbingIdentifier?: string,
  maximized?: bool,
  visible?: bool,
  closable?: bool,
  parent?: t,
  visibleOnAllWorkspaces?: bool,
  backgroundColor?: color,
}

@module("@tauri-apps/api/window") @new
external make: (string, ~options: options=?) => t = "Window"

@module("@tauri-apps/api/window") @scope("Window")
external getCurrent: unit => t = "getCurrent"

@module("@tauri-apps/api/window") @scope("Window")
external getAll: unit => array<t> = "getAll"

@module("@tauri-apps/api/window") @scope("Window")
external getByLabel: string => promise<Nullable.t<t>> = "getByLabel"

@module("@tauri-apps/api/window")
external getFocusedWindow: unit => promise<Nullable.t<t>> = "getFocusedWindow"

@module("@tauri-apps/api/window")
external currentMonitor: unit => promise<Nullable.t<monitor>> = "currentMonitor"

@module("@tauri-apps/api/window")
external primaryMonitor: unit => promise<Nullable.t<monitor>> = "primaryMonitor"

@module("@tauri-apps/api/window")
external monitorFromPoint: (float, float) => promise<Nullable.t<monitor>> = "monitorFromPoint"

@module("@tauri-apps/api/window")
external availableMonitors: unit => promise<array<monitor>> = "availableMonitors"

@module("@tauri-apps/api/window")
external cursorPosition: unit => promise<Dpi.PhysicalPosition.t> = "cursorPosition"

@get external label: t => string = "label"
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
@send external isFullscreen: t => promise<bool> = "isFullscreen"
@send external isDecorated: t => promise<bool> = "isDecorated"
@send external isResizable: t => promise<bool> = "isResizable"
@send external isMaximizable: t => promise<bool> = "isMaximizable"
@send external isMinimizable: t => promise<bool> = "isMinimizable"
@send external isClosable: t => promise<bool> = "isClosable"
@send external isAlwaysOnTop: t => promise<bool> = "isAlwaysOnTop"
@send external isEnabled: t => promise<bool> = "isEnabled"
@send external setFocus: t => promise<unit> = "setFocus"
@send external isFocused: t => promise<bool> = "isFocused"
@send external setSize: (t, Dpi.Size.t) => promise<unit> = "setSize"
@send external setMinSize: (t, Nullable.t<Dpi.Size.t>) => promise<unit> = "setMinSize"
@send external setMaxSize: (t, Nullable.t<Dpi.Size.t>) => promise<unit> = "setMaxSize"
@send
external setSizeConstraints: (t, Nullable.t<windowSizeConstraints>) => promise<unit> =
  "setSizeConstraints"
@send external setPosition: (t, Dpi.Position.t) => promise<unit> = "setPosition"
@send external center: t => promise<unit> = "center"
@send external setFullscreen: (t, bool) => promise<unit> = "setFullscreen"
@send external setResizable: (t, bool) => promise<unit> = "setResizable"
@send external setEnabled: (t, bool) => promise<unit> = "setEnabled"
@send external setMaximizable: (t, bool) => promise<unit> = "setMaximizable"
@send external setMinimizable: (t, bool) => promise<unit> = "setMinimizable"
@send external setClosable: (t, bool) => promise<unit> = "setClosable"
@send external setAlwaysOnTop: (t, bool) => promise<unit> = "setAlwaysOnTop"
@send external setAlwaysOnBottom: (t, bool) => promise<unit> = "setAlwaysOnBottom"
@send external setContentProtected: (t, bool) => promise<unit> = "setContentProtected"
@send external setDecorations: (t, bool) => promise<unit> = "setDecorations"
@send external setShadow: (t, bool) => promise<unit> = "setShadow"
@send external setEffects: (t, effects) => promise<unit> = "setEffects"
@send external clearEffects: t => promise<unit> = "clearEffects"
@send external setIcon: (t, 'icon) => promise<unit> = "setIcon"
@send external setSkipTaskbar: (t, bool) => promise<unit> = "setSkipTaskbar"
@send external setBackgroundColor: (t, color) => promise<unit> = "setBackgroundColor"
@send external setIgnoreCursorEvents: (t, bool) => promise<unit> = "setIgnoreCursorEvents"
@send external setCursorIcon: (t, cursorIcon) => promise<unit> = "setCursorIcon"
@send external setCursorVisible: (t, bool) => promise<unit> = "setCursorVisible"
@send external setCursorGrab: (t, bool) => promise<unit> = "setCursorGrab"
@send external setCursorPosition: (t, Dpi.Position.t) => promise<unit> = "setCursorPosition"
@send external startDragging: t => promise<unit> = "startDragging"
@send external startResizeDragging: (t, resizeDirection) => promise<unit> = "startResizeDragging"
@send
external requestUserAttention: (t, Nullable.t<userAttentionType>) => promise<unit> =
  "requestUserAttention"
@send external setBadgeCount: (t, ~count: int=?) => promise<unit> = "setBadgeCount"
@send external setBadgeLabel: (t, ~label: string=?) => promise<unit> = "setBadgeLabel"
@send external setOverlayIcon: (t, ~icon: 'icon=?) => promise<unit> = "setOverlayIcon"
@send external setProgressBar: (t, progressBarState) => promise<unit> = "setProgressBar"
@send
external setVisibleOnAllWorkspaces: (t, bool) => promise<unit> = "setVisibleOnAllWorkspaces"
@send external setTitleBarStyle: (t, titleBarStyle) => promise<unit> = "setTitleBarStyle"
@send external setTheme: (t, Nullable.t<theme>) => promise<unit> = "setTheme"
@send external theme: t => promise<Nullable.t<theme>> = "theme"
@send external scaleFactor: t => promise<float> = "scaleFactor"
@send external innerSize: t => promise<Dpi.PhysicalSize.t> = "innerSize"
@send external outerSize: t => promise<Dpi.PhysicalSize.t> = "outerSize"
@send external innerPosition: t => promise<Dpi.PhysicalPosition.t> = "innerPosition"
@send external outerPosition: t => promise<Dpi.PhysicalPosition.t> = "outerPosition"

@send external onResized: (t, Dpi.PhysicalSize.t => unit) => promise<unlisten> = "onResized"
@send external onMoved: (t, Dpi.PhysicalPosition.t => unit) => promise<unlisten> = "onMoved"
@send
external onCloseRequested: (t, closeRequestedEvent => unit) => promise<unlisten> =
  "onCloseRequested"
@send external onFocusChanged: (t, bool => unit) => promise<unlisten> = "onFocusChanged"
@send
external onScaleChanged: (t, scaleFactorChanged => unit) => promise<unlisten> = "onScaleChanged"
@send external onThemeChanged: (t, theme => unit) => promise<unlisten> = "onThemeChanged"
