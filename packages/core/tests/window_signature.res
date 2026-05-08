// Type-level signature test for Window.

let _check_make: (string, ~options: Window.options=?) => Window.t = Window.make
let _check_get_current: unit => Window.t = Window.getCurrent
let _check_get_all: unit => array<Window.t> = Window.getAll
let _check_get_by_label: string => promise<Nullable.t<Window.t>> = Window.getByLabel

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
let _check_set_focus: Window.t => promise<unit> = Window.setFocus
let _check_is_focused: Window.t => promise<bool> = Window.isFocused
let _check_set_size: (Window.t, 'size) => promise<unit> = Window.setSize
let _check_set_position: (Window.t, 'position) => promise<unit> = Window.setPosition
let _check_center: Window.t => promise<unit> = Window.center
let _check_set_fullscreen: (Window.t, bool) => promise<unit> = Window.setFullscreen
let _check_set_resizable: (Window.t, bool) => promise<unit> = Window.setResizable
let _check_set_always_on_top: (Window.t, bool) => promise<unit> = Window.setAlwaysOnTop
