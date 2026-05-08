// Type-level signature test for PluginFs.

let _check_read_text_file: (string, ~options: PluginFs.readFileOptions=?) => promise<
  string,
> = PluginFs.readTextFile
let _check_write_text_file: (string, string, ~options: PluginFs.writeFileOptions=?) => promise<
  unit,
> = PluginFs.writeTextFile
let _check_read_file: (string, ~options: PluginFs.readFileOptions=?) => promise<
  Uint8Array.t,
> = PluginFs.readFile
let _check_write_file: (string, Uint8Array.t, ~options: PluginFs.writeFileOptions=?) => promise<
  unit,
> = PluginFs.writeFile
let _check_exists: (string, ~options: PluginFs.existsOptions=?) => promise<bool> = PluginFs.exists
let _check_remove: (string, ~options: PluginFs.removeOptions=?) => promise<unit> = PluginFs.remove
let _check_rename: (string, string, ~options: PluginFs.renameOptions=?) => promise<
  unit,
> = PluginFs.rename
let _check_mkdir: (string, ~options: PluginFs.mkdirOptions=?) => promise<unit> = PluginFs.mkdir
let _check_read_dir: (string, ~options: PluginFs.readDirOptions=?) => promise<
  array<PluginFs.dirEntry>,
> = PluginFs.readDir
let _check_stat: (string, ~options: PluginFs.statOptions=?) => promise<
  PluginFs.fileInfo,
> = PluginFs.stat
let _check_lstat: (string, ~options: PluginFs.statOptions=?) => promise<
  PluginFs.fileInfo,
> = PluginFs.lstat
let _check_truncate: (string, ~len: int=?, ~options: PluginFs.truncateOptions=?) => promise<
  unit,
> = PluginFs.truncate
let _check_copy_file: (string, string, ~options: PluginFs.copyFileOptions=?) => promise<
  unit,
> = PluginFs.copyFile
let _check_size: string => promise<float> = PluginFs.size

// Re-exported BaseDirectory module
let _check_base_dir_value: PluginFs.BaseDirectory.t = PluginFs.BaseDirectory.appConfig
