// Type-level signature test for PluginDialog.

let _check_open_file: (~options: PluginDialog.openOptions=?) => promise<
  Nullable.t<string>,
> = PluginDialog.openFile

let _check_open_files: (~options: PluginDialog.openOptions=?) => promise<
  Nullable.t<array<string>>,
> = PluginDialog.openFiles

let _check_open_directory: (~options: PluginDialog.openOptions=?) => promise<
  Nullable.t<string>,
> = PluginDialog.openDirectory

let _check_open_directories: (~options: PluginDialog.openOptions=?) => promise<
  Nullable.t<array<string>>,
> = PluginDialog.openDirectories

let _check_save: (~options: PluginDialog.saveOptions=?) => promise<
  Nullable.t<string>,
> = PluginDialog.save

let _check_message: (string, ~options: PluginDialog.messageOptions=?) => promise<
  PluginDialog.messageResult,
> = PluginDialog.message

let _check_ask: (string, ~options: PluginDialog.confirmOptions=?) => promise<bool> = PluginDialog.ask

let _check_confirm: (string, ~options: PluginDialog.confirmOptions=?) => promise<
  bool,
> = PluginDialog.confirm

// Variant value smoke checks
let _check_picker_mode: PluginDialog.pickerMode = #document
let _check_file_access: PluginDialog.fileAccessMode = #copy
let _check_kind: PluginDialog.dialogKind = #info
let _check_buttons: PluginDialog.messageButtons = #YesNoCancel
