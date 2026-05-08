module BaseDirectory = RescriptTauriCore.Path.BaseDirectory

type fileInfo = {
  isFile: bool,
  isDirectory: bool,
  isSymlink: bool,
  size: float,
  mtime: Nullable.t<Date.t>,
  atime: Nullable.t<Date.t>,
  birthtime: Nullable.t<Date.t>,
  readonly: bool,
  fileAttributes: Nullable.t<int>,
  dev: Nullable.t<float>,
  ino: Nullable.t<float>,
  mode: Nullable.t<int>,
  nlink: Nullable.t<int>,
  uid: Nullable.t<int>,
  gid: Nullable.t<int>,
  rdev: Nullable.t<float>,
  blksize: Nullable.t<int>,
  blocks: Nullable.t<float>,
}

type dirEntry = {
  name: string,
  isDirectory: bool,
  isFile: bool,
  isSymlink: bool,
}

type readFileOptions = {
  baseDir?: BaseDirectory.t,
  encoding?: string,
}

type writeFileOptions = {
  append?: bool,
  create?: bool,
  createNew?: bool,
  mode?: int,
  baseDir?: BaseDirectory.t,
}

type mkdirOptions = {
  mode?: int,
  recursive?: bool,
  baseDir?: BaseDirectory.t,
}

type removeOptions = {
  recursive?: bool,
  baseDir?: BaseDirectory.t,
}

type renameOptions = {
  oldPathBaseDir?: BaseDirectory.t,
  newPathBaseDir?: BaseDirectory.t,
}

type copyFileOptions = {
  fromPathBaseDir?: BaseDirectory.t,
  toPathBaseDir?: BaseDirectory.t,
}

type statOptions = {baseDir?: BaseDirectory.t}
type existsOptions = {baseDir?: BaseDirectory.t}
type readDirOptions = {baseDir?: BaseDirectory.t}
type truncateOptions = {baseDir?: BaseDirectory.t}

@module("@tauri-apps/plugin-fs")
external readTextFile: (string, ~options: readFileOptions=?) => promise<string> = "readTextFile"

@module("@tauri-apps/plugin-fs")
external writeTextFile: (string, string, ~options: writeFileOptions=?) => promise<unit> =
  "writeTextFile"

@module("@tauri-apps/plugin-fs")
external readFile: (string, ~options: readFileOptions=?) => promise<Uint8Array.t> = "readFile"

@module("@tauri-apps/plugin-fs")
external writeFile: (string, Uint8Array.t, ~options: writeFileOptions=?) => promise<unit> =
  "writeFile"

@module("@tauri-apps/plugin-fs")
external exists: (string, ~options: existsOptions=?) => promise<bool> = "exists"

@module("@tauri-apps/plugin-fs")
external remove: (string, ~options: removeOptions=?) => promise<unit> = "remove"

@module("@tauri-apps/plugin-fs")
external rename: (string, string, ~options: renameOptions=?) => promise<unit> = "rename"

@module("@tauri-apps/plugin-fs")
external mkdir: (string, ~options: mkdirOptions=?) => promise<unit> = "mkdir"

@module("@tauri-apps/plugin-fs")
external readDir: (string, ~options: readDirOptions=?) => promise<array<dirEntry>> = "readDir"

@module("@tauri-apps/plugin-fs")
external stat: (string, ~options: statOptions=?) => promise<fileInfo> = "stat"

@module("@tauri-apps/plugin-fs")
external lstat: (string, ~options: statOptions=?) => promise<fileInfo> = "lstat"

@module("@tauri-apps/plugin-fs")
external truncate: (string, ~len: int=?, ~options: truncateOptions=?) => promise<unit> = "truncate"

@module("@tauri-apps/plugin-fs")
external copyFile: (string, string, ~options: copyFileOptions=?) => promise<unit> = "copyFile"

@module("@tauri-apps/plugin-fs")
external size: string => promise<float> = "size"
