/** Opaque handle to a Tauri Window. The underlying value is the JS
    Window class instance from `@tauri-apps/api/window`.

    **Resource lifetime**: Tauri does not garbage-collect native
    resources. Call `close` (graceful) or `destroy` (forced) when the
    window is no longer needed; otherwise the OS handle leaks.

    See: https://v2.tauri.app/reference/javascript/api/namespacewindow/
*/
type t

/** Returned by `on*` handlers — call it to detach the listener.
    Identical in shape to `Event.unlisten` so the two can be used
    interchangeably from a caller's perspective.

    See: https://v2.tauri.app/reference/javascript/api/namespacewindow/#unlistenfn
*/
type unlisten = unit => unit

/** Window theme as exposed by Tauri.

    See: https://v2.tauri.app/reference/javascript/api/namespacewindow/#theme
*/
type theme = [#light | #dark]

/** Hint priority for `requestUserAttention`. `null` clears any
    previously requested attention.

    See: https://v2.tauri.app/reference/javascript/api/namespacewindow/#userattentiontype
*/
type userAttentionType = [#critical | #informational]

/** Cursor icons exposed by Tauri.

    See: https://v2.tauri.app/reference/javascript/api/namespacewindow/#cursoricon
*/
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

/** Direction passed to `startResizeDragging`.

    See: https://v2.tauri.app/reference/javascript/api/namespacewindow/#resizedirection
*/
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

/** macOS title bar style.

    See: https://v2.tauri.app/reference/javascript/api/namespacewindow/#titlebarstyle
*/
type titleBarStyle = [#visible | #transparent | #overlay]

/** Status of the OS-provided progress bar (Windows / macOS).

    See: https://v2.tauri.app/reference/javascript/api/namespacewindow/#progressbarstatus
*/
type progressBarStatus = [#none | #normal | #indeterminate | #paused | #error]

/** Progress bar state passed to `setProgressBar`.

    See: https://v2.tauri.app/reference/javascript/api/namespacewindow/#progressbarstate
*/
type progressBarState = {
  status?: progressBarStatus,
  progress?: int,
}

/** Min / max size constraints for `setSizeConstraints`.

    See: https://v2.tauri.app/reference/javascript/api/namespacewindow/#windowsizeconstraints
*/
type windowSizeConstraints = {
  minWidth?: float,
  minHeight?: float,
  maxWidth?: float,
  maxHeight?: float,
}

/** Event payload delivered to `onCloseRequested`. Calling
    `preventDefault()` keeps the window alive; `isPreventDefault()`
    reports whether any handler has already opted out.

    See: https://v2.tauri.app/reference/javascript/api/namespacewindow/#closerequestedevent
*/
type closeRequestedEvent = {
  preventDefault: unit => unit,
  isPreventDefault: unit => bool,
}

/** Payload of the `onScaleChanged` event. `size` is the window's new
    physical size after the scale change.

    See: https://v2.tauri.app/reference/javascript/api/namespacewindow/#scalefactorchanged
*/
type scaleFactorChanged = {
  scaleFactor: float,
  size: Dpi.PhysicalSize.t,
}

/** RGBA color used by `setBackgroundColor` / `effects.color`.

    See: https://v2.tauri.app/reference/javascript/api/namespacewindow/#color
*/
type color = {r: int, g: int, b: int, a: int}

/** Allowed visual effect styles. Most are macOS-only; refer to the
    Tauri docs for cross-platform availability.

    See: https://v2.tauri.app/reference/javascript/api/namespacewindow/#effect
*/
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

/** Effect activity state.

    See: https://v2.tauri.app/reference/javascript/api/namespacewindow/#effectstate
*/
type effectState = [
  | #followsWindowActiveState
  | #active
  | #inactive
]

/** Visual effects applied via `setEffects`.

    See: https://v2.tauri.app/reference/javascript/api/namespacewindow/#effects
*/
type effects = {
  effects: array<effectStyle>,
  state?: effectState,
  radius?: float,
  color?: color,
}

/** Monitor descriptor returned by `currentMonitor` / `primaryMonitor`
    / `availableMonitors`. `size` and `position` are reported in
    physical (DPI-independent) pixels.

    See: https://v2.tauri.app/reference/javascript/api/namespacewindow/#monitor
*/
type monitor = {
  name: Nullable.t<string>,
  size: Dpi.PhysicalSize.t,
  position: Dpi.PhysicalPosition.t,
  scaleFactor: float,
}

/** Construction options for `make`. All fields are optional. */
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

/** Creates a new window. The label must be unique among all windows.

    See: https://v2.tauri.app/reference/javascript/api/namespacewindow/#window
*/
let make: (string, ~options: options=?) => t

/** Returns the currently focused window.

    See: https://v2.tauri.app/reference/javascript/api/namespacewindow/#getcurrent
*/
let getCurrent: unit => t

/** Returns every Window known to the app.

    See: https://v2.tauri.app/reference/javascript/api/namespacewindow/#getall
*/
let getAll: unit => array<t>

/** Looks up a window by label, returning `Nullable.null` if no match.

    See: https://v2.tauri.app/reference/javascript/api/namespacewindow/#getbylabel
*/
let getByLabel: string => promise<Nullable.t<t>>

/** Returns the currently focused window, or `Nullable.null` if none
    has focus.

    See: https://v2.tauri.app/reference/javascript/api/namespacewindow/#getfocusedwindow
*/
let getFocusedWindow: unit => promise<Nullable.t<t>>

/** Returns the monitor on which the OS reports the current window
    is displayed.

    See: https://v2.tauri.app/reference/javascript/api/namespacewindow/#currentmonitor
*/
let currentMonitor: unit => promise<Nullable.t<monitor>>

/** Returns the primary OS monitor.

    See: https://v2.tauri.app/reference/javascript/api/namespacewindow/#primarymonitor
*/
let primaryMonitor: unit => promise<Nullable.t<monitor>>

/** Returns the monitor that contains the given physical point.

    See: https://v2.tauri.app/reference/javascript/api/namespacewindow/#monitorfrompoint
*/
let monitorFromPoint: (float, float) => promise<Nullable.t<monitor>>

/** Returns every monitor available to the OS.

    See: https://v2.tauri.app/reference/javascript/api/namespacewindow/#availablemonitors
*/
let availableMonitors: unit => promise<array<monitor>>

/** Returns the cursor position in physical pixels.

    See: https://v2.tauri.app/reference/javascript/api/namespacewindow/#cursorposition
*/
let cursorPosition: unit => promise<Dpi.PhysicalPosition.t>

/** The window's label.

    See: https://v2.tauri.app/reference/javascript/api/namespacewindow/#label
*/
let label: t => string

/** Sets the window's title.

    See: https://v2.tauri.app/reference/javascript/api/namespacewindow/#settitle
*/
let setTitle: (t, string) => promise<unit>

/** Returns the current title.

    See: https://v2.tauri.app/reference/javascript/api/namespacewindow/#title
*/
let title: t => promise<string>

/** Requests a graceful close (the user can prevent it via the
    `tauri://close-requested` event).

    See: https://v2.tauri.app/reference/javascript/api/namespacewindow/#close
*/
let close: t => promise<unit>

/** Forces the window to close immediately.

    See: https://v2.tauri.app/reference/javascript/api/namespacewindow/#destroy
*/
let destroy: t => promise<unit>

/** Shows the window.

    See: https://v2.tauri.app/reference/javascript/api/namespacewindow/#show
*/
let show: t => promise<unit>

/** Hides the window.

    See: https://v2.tauri.app/reference/javascript/api/namespacewindow/#hide
*/
let hide: t => promise<unit>

/** Whether the window is currently visible.

    See: https://v2.tauri.app/reference/javascript/api/namespacewindow/#isvisible
*/
let isVisible: t => promise<bool>

/** Minimizes the window.

    See: https://v2.tauri.app/reference/javascript/api/namespacewindow/#minimize
*/
let minimize: t => promise<unit>

/** Maximizes the window.

    See: https://v2.tauri.app/reference/javascript/api/namespacewindow/#maximize
*/
let maximize: t => promise<unit>

/** Unmaximizes (restores) the window.

    See: https://v2.tauri.app/reference/javascript/api/namespacewindow/#unmaximize
*/
let unmaximize: t => promise<unit>

/** Whether the window is currently maximized.

    See: https://v2.tauri.app/reference/javascript/api/namespacewindow/#ismaximized
*/
let isMaximized: t => promise<bool>

/** Whether the window is currently minimized.

    See: https://v2.tauri.app/reference/javascript/api/namespacewindow/#isminimized
*/
let isMinimized: t => promise<bool>

/** Whether the window is currently fullscreen.

    See: https://v2.tauri.app/reference/javascript/api/namespacewindow/#isfullscreen
*/
let isFullscreen: t => promise<bool>

/** Whether the window has system decorations.

    See: https://v2.tauri.app/reference/javascript/api/namespacewindow/#isdecorated
*/
let isDecorated: t => promise<bool>

/** Whether the window can be resized by the user.

    See: https://v2.tauri.app/reference/javascript/api/namespacewindow/#isresizable
*/
let isResizable: t => promise<bool>

/** Whether the window can be maximized.

    See: https://v2.tauri.app/reference/javascript/api/namespacewindow/#ismaximizable
*/
let isMaximizable: t => promise<bool>

/** Whether the window can be minimized.

    See: https://v2.tauri.app/reference/javascript/api/namespacewindow/#isminimizable
*/
let isMinimizable: t => promise<bool>

/** Whether the window can be closed.

    See: https://v2.tauri.app/reference/javascript/api/namespacewindow/#isclosable
*/
let isClosable: t => promise<bool>

/** Whether the window is pinned above all others.

    See: https://v2.tauri.app/reference/javascript/api/namespacewindow/#isalwaysontop
*/
let isAlwaysOnTop: t => promise<bool>

/** Whether the window receives input.

    See: https://v2.tauri.app/reference/javascript/api/namespacewindow/#isenabled
*/
let isEnabled: t => promise<bool>

/** Brings the window to focus.

    See: https://v2.tauri.app/reference/javascript/api/namespacewindow/#setfocus
*/
let setFocus: t => promise<unit>

/** Whether the window currently has focus.

    See: https://v2.tauri.app/reference/javascript/api/namespacewindow/#isfocused
*/
let isFocused: t => promise<bool>

/** Sets the window size. Wrap a `LogicalSize` or `PhysicalSize` with
    `Dpi.Size.fromLogical` / `Dpi.Size.fromPhysical`.

    See: https://v2.tauri.app/reference/javascript/api/namespacewindow/#setsize
*/
let setSize: (t, Dpi.Size.t) => promise<unit>

/** Sets the window's minimum size, or clears it when given
    `Nullable.null`.

    See: https://v2.tauri.app/reference/javascript/api/namespacewindow/#setminsize
*/
let setMinSize: (t, Nullable.t<Dpi.Size.t>) => promise<unit>

/** Sets the window's maximum size, or clears it when given
    `Nullable.null`.

    See: https://v2.tauri.app/reference/javascript/api/namespacewindow/#setmaxsize
*/
let setMaxSize: (t, Nullable.t<Dpi.Size.t>) => promise<unit>

/** Sets the window's resize constraints, or clears them when given
    `Nullable.null`.

    See: https://v2.tauri.app/reference/javascript/api/namespacewindow/#setsizeconstraints
*/
let setSizeConstraints: (t, Nullable.t<windowSizeConstraints>) => promise<unit>

/** Sets the window position. Wrap a `LogicalPosition` or
    `PhysicalPosition` with `Dpi.Position.fromLogical` /
    `Dpi.Position.fromPhysical`.

    See: https://v2.tauri.app/reference/javascript/api/namespacewindow/#setposition
*/
let setPosition: (t, Dpi.Position.t) => promise<unit>

/** Centers the window on the current monitor.

    See: https://v2.tauri.app/reference/javascript/api/namespacewindow/#center
*/
let center: t => promise<unit>

/** Toggles fullscreen mode.

    See: https://v2.tauri.app/reference/javascript/api/namespacewindow/#setfullscreen
*/
let setFullscreen: (t, bool) => promise<unit>

/** Toggles whether the window can be resized by the user.

    See: https://v2.tauri.app/reference/javascript/api/namespacewindow/#setresizable
*/
let setResizable: (t, bool) => promise<unit>

/** Toggles whether the window accepts input events.

    See: https://v2.tauri.app/reference/javascript/api/namespacewindow/#setenabled
*/
let setEnabled: (t, bool) => promise<unit>

/** Toggles whether the window can be maximized.

    See: https://v2.tauri.app/reference/javascript/api/namespacewindow/#setmaximizable
*/
let setMaximizable: (t, bool) => promise<unit>

/** Toggles whether the window can be minimized.

    See: https://v2.tauri.app/reference/javascript/api/namespacewindow/#setminimizable
*/
let setMinimizable: (t, bool) => promise<unit>

/** Toggles whether the window can be closed.

    See: https://v2.tauri.app/reference/javascript/api/namespacewindow/#setclosable
*/
let setClosable: (t, bool) => promise<unit>

/** Pins the window above other windows.

    See: https://v2.tauri.app/reference/javascript/api/namespacewindow/#setalwaysontop
*/
let setAlwaysOnTop: (t, bool) => promise<unit>

/** Pins the window below other windows.

    See: https://v2.tauri.app/reference/javascript/api/namespacewindow/#setalwaysonbottom
*/
let setAlwaysOnBottom: (t, bool) => promise<unit>

/** Toggles content protection (prevents the window from being
    captured by screenshots / screen recording on supported OSes).

    See: https://v2.tauri.app/reference/javascript/api/namespacewindow/#setcontentprotected
*/
let setContentProtected: (t, bool) => promise<unit>

/** Toggles system window decorations.

    See: https://v2.tauri.app/reference/javascript/api/namespacewindow/#setdecorations
*/
let setDecorations: (t, bool) => promise<unit>

/** Toggles the OS shadow drawn around the window.

    See: https://v2.tauri.app/reference/javascript/api/namespacewindow/#setshadow
*/
let setShadow: (t, bool) => promise<unit>

/** Applies the given visual effects.

    See: https://v2.tauri.app/reference/javascript/api/namespacewindow/#seteffects
*/
let setEffects: (t, effects) => promise<unit>

/** Removes any previously applied visual effects.

    See: https://v2.tauri.app/reference/javascript/api/namespacewindow/#cleareffects
*/
let clearEffects: t => promise<unit>

/** Sets the window icon. The argument is polymorphic until the
    `Image` module lands; pass a path string, `Image.t`, `Uint8Array`,
    `ArrayBuffer`, or `array<int>`.

    See: https://v2.tauri.app/reference/javascript/api/namespacewindow/#seticon
*/
let setIcon: (t, 'icon) => promise<unit>

/** Hides or shows the window's taskbar entry.

    See: https://v2.tauri.app/reference/javascript/api/namespacewindow/#setskiptaskbar
*/
let setSkipTaskbar: (t, bool) => promise<unit>

/** Sets the window background color.

    See: https://v2.tauri.app/reference/javascript/api/namespacewindow/#setbackgroundcolor
*/
let setBackgroundColor: (t, color) => promise<unit>

/** Toggles whether cursor events pass through this window to the
    window beneath it.

    See: https://v2.tauri.app/reference/javascript/api/namespacewindow/#setignorecursorevents
*/
let setIgnoreCursorEvents: (t, bool) => promise<unit>

/** Sets the cursor icon.

    See: https://v2.tauri.app/reference/javascript/api/namespacewindow/#setcursoricon
*/
let setCursorIcon: (t, cursorIcon) => promise<unit>

/** Toggles cursor visibility.

    See: https://v2.tauri.app/reference/javascript/api/namespacewindow/#setcursorvisible
*/
let setCursorVisible: (t, bool) => promise<unit>

/** Toggles whether the cursor is locked to this window.

    See: https://v2.tauri.app/reference/javascript/api/namespacewindow/#setcursorgrab
*/
let setCursorGrab: (t, bool) => promise<unit>

/** Sets the cursor position. Wrap with `Dpi.Position.fromLogical` /
    `Dpi.Position.fromPhysical`.

    See: https://v2.tauri.app/reference/javascript/api/namespacewindow/#setcursorposition
*/
let setCursorPosition: (t, Dpi.Position.t) => promise<unit>

/** Begins a window drag operation. Call from a mousedown handler.

    See: https://v2.tauri.app/reference/javascript/api/namespacewindow/#startdragging
*/
let startDragging: t => promise<unit>

/** Begins a window resize operation in the given direction.

    See: https://v2.tauri.app/reference/javascript/api/namespacewindow/#startresizedragging
*/
let startResizeDragging: (t, resizeDirection) => promise<unit>

/** Requests user attention via the platform-specific mechanism
    (taskbar flash on Windows, dock bounce on macOS, ...). Pass
    `Nullable.null` to clear a pending request.

    See: https://v2.tauri.app/reference/javascript/api/namespacewindow/#requestuserattention
*/
let requestUserAttention: (t, Nullable.t<userAttentionType>) => promise<unit>

/** Sets the badge count overlaid on the dock / taskbar icon. Omit
    `count` to clear the badge.

    See: https://v2.tauri.app/reference/javascript/api/namespacewindow/#setbadgecount
*/
let setBadgeCount: (t, ~count: int=?) => promise<unit>

/** Sets a textual badge label (Windows-only). Omit `label` to clear.

    See: https://v2.tauri.app/reference/javascript/api/namespacewindow/#setbadgelabel
*/
let setBadgeLabel: (t, ~label: string=?) => promise<unit>

/** Sets the overlay icon (Windows-only). Omit `icon` to clear.

    See: https://v2.tauri.app/reference/javascript/api/namespacewindow/#setoverlayicon
*/
let setOverlayIcon: (t, ~icon: 'icon=?) => promise<unit>

/** Sets the OS-provided progress bar state.

    See: https://v2.tauri.app/reference/javascript/api/namespacewindow/#setprogressbar
*/
let setProgressBar: (t, progressBarState) => promise<unit>

/** Toggles whether the window is visible on every virtual desktop.

    See: https://v2.tauri.app/reference/javascript/api/namespacewindow/#setvisibleonallworkspaces
*/
let setVisibleOnAllWorkspaces: (t, bool) => promise<unit>

/** macOS title bar appearance.

    See: https://v2.tauri.app/reference/javascript/api/namespacewindow/#settitlebarstyle
*/
let setTitleBarStyle: (t, titleBarStyle) => promise<unit>

/** Sets the window's preferred theme; `Nullable.null` defers to the
    OS setting.

    See: https://v2.tauri.app/reference/javascript/api/namespacewindow/#settheme
*/
let setTheme: (t, Nullable.t<theme>) => promise<unit>

/** Returns the currently effective theme, or `Nullable.null` if the
    OS does not expose one.

    See: https://v2.tauri.app/reference/javascript/api/namespacewindow/#theme
*/
let theme: t => promise<Nullable.t<theme>>

/** Returns the device pixel ratio for this window.

    See: https://v2.tauri.app/reference/javascript/api/namespacewindow/#scalefactor
*/
let scaleFactor: t => promise<float>

/** Returns the size of the client area in physical pixels.

    See: https://v2.tauri.app/reference/javascript/api/namespacewindow/#innersize
*/
let innerSize: t => promise<Dpi.PhysicalSize.t>

/** Returns the size including decorations in physical pixels.

    See: https://v2.tauri.app/reference/javascript/api/namespacewindow/#outersize
*/
let outerSize: t => promise<Dpi.PhysicalSize.t>

/** Returns the position of the client area in physical pixels.

    See: https://v2.tauri.app/reference/javascript/api/namespacewindow/#innerposition
*/
let innerPosition: t => promise<Dpi.PhysicalPosition.t>

/** Returns the position including decorations in physical pixels.

    See: https://v2.tauri.app/reference/javascript/api/namespacewindow/#outerposition
*/
let outerPosition: t => promise<Dpi.PhysicalPosition.t>

/** Subscribes to `tauri://resize`. Returns an `unlisten` function
    that detaches the handler.

    See: https://v2.tauri.app/reference/javascript/api/namespacewindow/#onresized
*/
let onResized: (t, Dpi.PhysicalSize.t => unit) => promise<unlisten>

/** Subscribes to `tauri://move`.

    See: https://v2.tauri.app/reference/javascript/api/namespacewindow/#onmoved
*/
let onMoved: (t, Dpi.PhysicalPosition.t => unit) => promise<unlisten>

/** Subscribes to `tauri://close-requested`. The handler can call
    `event.preventDefault()` to keep the window open.

    See: https://v2.tauri.app/reference/javascript/api/namespacewindow/#oncloserequested
*/
let onCloseRequested: (t, closeRequestedEvent => unit) => promise<unlisten>

/** Subscribes to `tauri://focus` / `tauri://blur` (delivered as a
    boolean `focused` payload).

    See: https://v2.tauri.app/reference/javascript/api/namespacewindow/#onfocuschanged
*/
let onFocusChanged: (t, bool => unit) => promise<unlisten>

/** Subscribes to `tauri://scale-change`.

    See: https://v2.tauri.app/reference/javascript/api/namespacewindow/#onscalechanged
*/
let onScaleChanged: (t, scaleFactorChanged => unit) => promise<unlisten>

/** Subscribes to `tauri://theme-changed`.

    See: https://v2.tauri.app/reference/javascript/api/namespacewindow/#onthemechanged
*/
let onThemeChanged: (t, theme => unit) => promise<unlisten>
