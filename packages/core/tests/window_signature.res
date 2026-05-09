// Type-level signature test for Window. Compilation success = all
// public symbols still match the documented signatures.

let _check_make: (string, ~options: Window.options=?) => Window.t = Window.make
let _check_get_current: unit => Window.t = Window.getCurrent
let _check_get_all: unit => array<Window.t> = Window.getAll
let _check_get_by_label: string => promise<Nullable.t<Window.t>> = Window.getByLabel
let _check_get_focused_window: unit => promise<Nullable.t<Window.t>> = Window.getFocusedWindow

let _check_current_monitor: unit => promise<Nullable.t<Window.monitor>> = Window.currentMonitor
let _check_primary_monitor: unit => promise<Nullable.t<Window.monitor>> = Window.primaryMonitor
let _check_monitor_from_point: (~x: float, ~y: float) => promise<
  Nullable.t<Window.monitor>,
> = Window.monitorFromPoint
let _check_available_monitors: unit => promise<array<Window.monitor>> = Window.availableMonitors
let _check_cursor_position: unit => promise<Dpi.PhysicalPosition.t> = Window.cursorPosition

let _check_label: Window.t => string = Window.label
let _check_set_title: (Window.t, string) => promise<unit> = Window.setTitle
let _check_title: Window.t => promise<string> = Window.title
let _check_close: Window.t => promise<unit> = Window.close
let _check_destroy: Window.t => promise<unit> = Window.destroy
let _check_show: Window.t => promise<unit> = Window.show
let _check_hide: Window.t => promise<unit> = Window.hide
let _check_is_visible: Window.t => promise<bool> = Window.isVisible
let _check_minimize: Window.t => promise<unit> = Window.minimize
let _check_maximize: Window.t => promise<unit> = Window.maximize
let _check_unmaximize: Window.t => promise<unit> = Window.unmaximize
let _check_is_maximized: Window.t => promise<bool> = Window.isMaximized
let _check_is_minimized: Window.t => promise<bool> = Window.isMinimized
let _check_is_fullscreen: Window.t => promise<bool> = Window.isFullscreen
let _check_is_decorated: Window.t => promise<bool> = Window.isDecorated
let _check_is_resizable: Window.t => promise<bool> = Window.isResizable
let _check_is_maximizable: Window.t => promise<bool> = Window.isMaximizable
let _check_is_minimizable: Window.t => promise<bool> = Window.isMinimizable
let _check_is_closable: Window.t => promise<bool> = Window.isClosable
let _check_is_always_on_top: Window.t => promise<bool> = Window.isAlwaysOnTop
let _check_is_enabled: Window.t => promise<bool> = Window.isEnabled
let _check_set_focus: Window.t => promise<unit> = Window.setFocus
let _check_is_focused: Window.t => promise<bool> = Window.isFocused
let _check_set_size: (Window.t, Dpi.Size.t) => promise<unit> = Window.setSize
let _check_set_min_size: (Window.t, Nullable.t<Dpi.Size.t>) => promise<unit> = Window.setMinSize
let _check_set_max_size: (Window.t, Nullable.t<Dpi.Size.t>) => promise<unit> = Window.setMaxSize
let _check_set_size_constraints: (
  Window.t,
  Nullable.t<Window.windowSizeConstraints>,
) => promise<unit> = Window.setSizeConstraints
let _check_set_position: (Window.t, Dpi.Position.t) => promise<unit> = Window.setPosition
let _check_center: Window.t => promise<unit> = Window.center
let _check_set_fullscreen: (Window.t, bool) => promise<unit> = Window.setFullscreen
let _check_set_resizable: (Window.t, bool) => promise<unit> = Window.setResizable
let _check_set_enabled: (Window.t, bool) => promise<unit> = Window.setEnabled
let _check_set_maximizable: (Window.t, bool) => promise<unit> = Window.setMaximizable
let _check_set_minimizable: (Window.t, bool) => promise<unit> = Window.setMinimizable
let _check_set_closable: (Window.t, bool) => promise<unit> = Window.setClosable
let _check_set_always_on_top: (Window.t, bool) => promise<unit> = Window.setAlwaysOnTop
let _check_set_always_on_bottom: (Window.t, bool) => promise<unit> = Window.setAlwaysOnBottom
let _check_set_content_protected: (Window.t, bool) => promise<unit> = Window.setContentProtected
let _check_set_decorations: (Window.t, bool) => promise<unit> = Window.setDecorations
let _check_set_shadow: (Window.t, bool) => promise<unit> = Window.setShadow
let _check_set_effects: (Window.t, Window.effects) => promise<unit> = Window.setEffects
let _check_clear_effects: Window.t => promise<unit> = Window.clearEffects
let _check_set_icon: (Window.t, 'icon) => promise<unit> = Window.setIcon
let _check_set_skip_taskbar: (Window.t, bool) => promise<unit> = Window.setSkipTaskbar
let _check_set_background_color: (Window.t, Nullable.t<Common.color>) => promise<unit> = Window.setBackgroundColor
let _check_set_ignore_cursor_events: (Window.t, bool) => promise<unit> = Window.setIgnoreCursorEvents
let _check_set_cursor_icon: (Window.t, Window.cursorIcon) => promise<unit> = Window.setCursorIcon
let _check_set_cursor_visible: (Window.t, bool) => promise<unit> = Window.setCursorVisible
let _check_set_cursor_grab: (Window.t, bool) => promise<unit> = Window.setCursorGrab
let _check_set_cursor_position: (Window.t, Dpi.Position.t) => promise<unit> = Window.setCursorPosition
let _check_start_dragging: Window.t => promise<unit> = Window.startDragging
let _check_start_resize_dragging: (Window.t, Window.resizeDirection) => promise<
  unit,
> = Window.startResizeDragging
let _check_request_user_attention: (Window.t, Nullable.t<Window.userAttentionType>) => promise<
  unit,
> = Window.requestUserAttention
let _check_set_badge_count: (Window.t, ~count: int=?) => promise<unit> = Window.setBadgeCount
let _check_set_badge_label: (Window.t, ~label: string=?) => promise<unit> = Window.setBadgeLabel
let _check_set_overlay_icon: (Window.t, ~icon: 'icon=?) => promise<unit> = Window.setOverlayIcon
let _check_set_progress_bar: (Window.t, Window.progressBarState) => promise<unit> = Window.setProgressBar
let _check_set_visible_on_all_workspaces: (Window.t, bool) => promise<
  unit,
> = Window.setVisibleOnAllWorkspaces
let _check_set_title_bar_style: (Window.t, Window.titleBarStyle) => promise<unit> = Window.setTitleBarStyle
let _check_set_theme: (Window.t, Nullable.t<Window.theme>) => promise<unit> = Window.setTheme
let _check_theme: Window.t => promise<Nullable.t<Window.theme>> = Window.theme
let _check_scale_factor: Window.t => promise<float> = Window.scaleFactor
let _check_inner_size: Window.t => promise<Dpi.PhysicalSize.t> = Window.innerSize
let _check_outer_size: Window.t => promise<Dpi.PhysicalSize.t> = Window.outerSize
let _check_inner_position: Window.t => promise<Dpi.PhysicalPosition.t> = Window.innerPosition
let _check_outer_position: Window.t => promise<Dpi.PhysicalPosition.t> = Window.outerPosition

let _check_on_resized: (Window.t, Dpi.PhysicalSize.t => unit) => promise<
  Common.unlisten,
> = Window.onResized
let _check_on_moved: (Window.t, Dpi.PhysicalPosition.t => unit) => promise<
  Common.unlisten,
> = Window.onMoved
let _check_on_close_requested: (
  Window.t,
  Window.closeRequestedEvent => unit,
) => promise<Common.unlisten> = Window.onCloseRequested
let _check_on_focus_changed: (Window.t, bool => unit) => promise<Common.unlisten> = Window.onFocusChanged
let _check_on_scale_changed: (
  Window.t,
  Window.scaleFactorChanged => unit,
) => promise<Common.unlisten> = Window.onScaleChanged
let _check_on_theme_changed: (Window.t, Window.theme => unit) => promise<
  Common.unlisten,
> = Window.onThemeChanged

// Type aliases — referencing them at the value level keeps the type
// in scope and counts towards public-symbol coverage.
let _check_theme_value: Window.theme = #light
let _check_cursor_icon_value: Window.cursorIcon = #default

let _check_activity_name: Window.t => promise<string> = Window.activityName
let _check_scene_identifier: Window.t => promise<string> = Window.sceneIdentifier
let _check_set_focusable: (Window.t, bool) => promise<unit> = Window.setFocusable
let _check_set_simple_fullscreen: (Window.t, bool) => promise<unit> = Window.setSimpleFullscreen
let _check_toggle_maximize: Window.t => promise<unit> = Window.toggleMaximize
let _check_unminimize: Window.t => promise<unit> = Window.unminimize
let _check_on_drag_drop_event: (Window.t, Common.dragDropEvent => unit) => promise<
  Common.unlisten,
> = Window.onDragDropEvent
