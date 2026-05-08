type dialogFilter = {
  name: string,
  extensions: array<string>,
}

type pickerMode = [
  | #document
  | #media
  | #image
  | #video
]

type fileAccessMode = [#copy | #scoped]

type dialogKind = [#info | #warning | #error]

type messageButtons = [#Ok | #OkCancel | #YesNo | #YesNoCancel]

type messageResult = string

type openOptions = {
  title?: string,
  filters?: array<dialogFilter>,
  defaultPath?: string,
  recursive?: bool,
  canCreateDirectories?: bool,
  pickerMode?: pickerMode,
  fileAccessMode?: fileAccessMode,
}

type saveOptions = {
  title?: string,
  filters?: array<dialogFilter>,
  defaultPath?: string,
  canCreateDirectories?: bool,
}

type messageOptions = {
  title?: string,
  kind?: dialogKind,
  okLabel?: string,
  buttons?: messageButtons,
}

type confirmOptions = {
  title?: string,
  kind?: dialogKind,
  okLabel?: string,
  cancelLabel?: string,
}

// Internal options shape that includes multiple/directory so we can
// drive upstream's overloaded `open` from the four split functions.
type _openOptionsJs = {
  title?: string,
  filters?: array<dialogFilter>,
  defaultPath?: string,
  recursive?: bool,
  canCreateDirectories?: bool,
  pickerMode?: pickerMode,
  fileAccessMode?: fileAccessMode,
  multiple?: bool,
  directory?: bool,
}

@module("@tauri-apps/plugin-dialog")
external _open: _openOptionsJs => promise<Nullable.t<'a>> = "open"

let _toJsOpen = (opts: option<openOptions>, ~multiple, ~directory): _openOptionsJs =>
  switch opts {
  | None => {multiple, directory}
  | Some(o) => {
      title: ?o.title,
      filters: ?o.filters,
      defaultPath: ?o.defaultPath,
      recursive: ?o.recursive,
      canCreateDirectories: ?o.canCreateDirectories,
      pickerMode: ?o.pickerMode,
      fileAccessMode: ?o.fileAccessMode,
      multiple,
      directory,
    }
  }

let openFile = (~options=?): promise<Nullable.t<string>> =>
  _open(_toJsOpen(options, ~multiple=false, ~directory=false))

let openFiles = (~options=?): promise<Nullable.t<array<string>>> =>
  _open(_toJsOpen(options, ~multiple=true, ~directory=false))

let openDirectory = (~options=?): promise<Nullable.t<string>> =>
  _open(_toJsOpen(options, ~multiple=false, ~directory=true))

let openDirectories = (~options=?): promise<Nullable.t<array<string>>> =>
  _open(_toJsOpen(options, ~multiple=true, ~directory=true))

@module("@tauri-apps/plugin-dialog")
external save: (~options: saveOptions=?) => promise<Nullable.t<string>> = "save"

@module("@tauri-apps/plugin-dialog")
external message: (string, ~options: messageOptions=?) => promise<messageResult> = "message"

@module("@tauri-apps/plugin-dialog")
external ask: (string, ~options: confirmOptions=?) => promise<bool> = "ask"

@module("@tauri-apps/plugin-dialog")
external confirm: (string, ~options: confirmOptions=?) => promise<bool> = "confirm"
