/** Bindings for `@tauri-apps/plugin-fs` (Tauri 2.x filesystem plugin).

    Phase 2 first-iteration scope: synchronous single-shot IO functions
    plus their record types. `FileHandle` (open / create), `watch` /
    `watchImmediate`, `readTextFileLines`, and the iOS-only
    security-scoped resource APIs are deferred to follow-up steerings
    so this binding can ship in a tractable size.

    See: https://v2.tauri.app/plugin/file-system/
*/

module BaseDirectory = RescriptTauriCore.Path.BaseDirectory

/** Metadata returned by `stat` / `lstat`.

    See: https://v2.tauri.app/reference/javascript/fs/#fileinfo
*/
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

/** A single entry from `readDir`.

    See: https://v2.tauri.app/reference/javascript/fs/#direntry
*/
type dirEntry = {
  name: string,
  isDirectory: bool,
  isFile: bool,
  isSymlink: bool,
}

/** Options for `readFile` / `readTextFile`.

    `encoding` is currently a `string` because upstream
    `@tauri-apps/plugin-fs` accepts only `"utf-8"` at the time of this
    binding (v2.5.0). Passing any other value falls through to the
    Rust side as a runtime error. The shape will tighten to a
    polymorphic variant once upstream documents additional values.

    See: https://v2.tauri.app/reference/javascript/fs/#readfileoptions
*/
type readFileOptions = {
  baseDir?: BaseDirectory.t,
  encoding?: string,
}

/** Options for `writeFile` / `writeTextFile`.

    See: https://v2.tauri.app/reference/javascript/fs/#writefileoptions
*/
type writeFileOptions = {
  append?: bool,
  create?: bool,
  createNew?: bool,
  mode?: int,
  baseDir?: BaseDirectory.t,
}

/** Options for `mkdir`.

    See: https://v2.tauri.app/reference/javascript/fs/#mkdiroptions
*/
type mkdirOptions = {
  mode?: int,
  recursive?: bool,
  baseDir?: BaseDirectory.t,
}

/** Options for `remove`.

    See: https://v2.tauri.app/reference/javascript/fs/#removeoptions
*/
type removeOptions = {
  recursive?: bool,
  baseDir?: BaseDirectory.t,
}

/** Options for `rename`. Each base dir applies to its own path.

    See: https://v2.tauri.app/reference/javascript/fs/#renameoptions
*/
type renameOptions = {
  oldPathBaseDir?: BaseDirectory.t,
  newPathBaseDir?: BaseDirectory.t,
}

/** Options for `copyFile`.

    See: https://v2.tauri.app/reference/javascript/fs/#copyfileoptions
*/
type copyFileOptions = {
  fromPathBaseDir?: BaseDirectory.t,
  toPathBaseDir?: BaseDirectory.t,
}

/** Options for `stat` / `lstat`.

    See: https://v2.tauri.app/reference/javascript/fs/#statoptions
*/
type statOptions = {baseDir?: BaseDirectory.t}

/** Options for `exists`.

    See: https://v2.tauri.app/reference/javascript/fs/#existsoptions
*/
type existsOptions = {baseDir?: BaseDirectory.t}

/** Options for `readDir`.

    See: https://v2.tauri.app/reference/javascript/fs/#readdiroptions
*/
type readDirOptions = {baseDir?: BaseDirectory.t}

/** Options for `truncate`.

    See: https://v2.tauri.app/reference/javascript/fs/#truncateoptions
*/
type truncateOptions = {baseDir?: BaseDirectory.t}

/** Reads the entire contents of a UTF-8 text file.

    See: https://v2.tauri.app/reference/javascript/fs/#readtextfile
*/
let readTextFile: (string, ~options: readFileOptions=?) => promise<string>

/** Writes a string to a file as UTF-8.

    See: https://v2.tauri.app/reference/javascript/fs/#writetextfile
*/
let writeTextFile: (string, string, ~options: writeFileOptions=?) => promise<unit>

/** Reads the entire contents of a file as raw bytes.

    See: https://v2.tauri.app/reference/javascript/fs/#readfile
*/
let readFile: (string, ~options: readFileOptions=?) => promise<Uint8Array.t>

/** Writes raw bytes to a file.

    See: https://v2.tauri.app/reference/javascript/fs/#writefile
*/
let writeFile: (string, Uint8Array.t, ~options: writeFileOptions=?) => promise<unit>

/** Whether a path exists at all (file, directory, or symlink).

    See: https://v2.tauri.app/reference/javascript/fs/#exists
*/
let exists: (string, ~options: existsOptions=?) => promise<bool>

/** Removes a file or directory.

    See: https://v2.tauri.app/reference/javascript/fs/#remove
*/
let remove: (string, ~options: removeOptions=?) => promise<unit>

/** Renames (moves) `oldPath` to `newPath`.

    See: https://v2.tauri.app/reference/javascript/fs/#rename
*/
let rename: (string, string, ~options: renameOptions=?) => promise<unit>

/** Creates a directory.

    See: https://v2.tauri.app/reference/javascript/fs/#mkdir
*/
let mkdir: (string, ~options: mkdirOptions=?) => promise<unit>

/** Reads a directory and returns its immediate children.

    See: https://v2.tauri.app/reference/javascript/fs/#readdir
*/
let readDir: (string, ~options: readDirOptions=?) => promise<array<dirEntry>>

/** Returns metadata for the path, following symlinks.

    See: https://v2.tauri.app/reference/javascript/fs/#stat
*/
let stat: (string, ~options: statOptions=?) => promise<fileInfo>

/** Like `stat` but does **not** follow symlinks (returns metadata for
    the symlink itself when `path` is one).

    See: https://v2.tauri.app/reference/javascript/fs/#lstat
*/
let lstat: (string, ~options: statOptions=?) => promise<fileInfo>

/** Truncates / extends a file to `len` bytes (defaults to 0 when
    omitted).

    See: https://v2.tauri.app/reference/javascript/fs/#truncate
*/
let truncate: (string, ~len: int=?, ~options: truncateOptions=?) => promise<unit>

/** Copies one file to another path, overwriting by default.

    See: https://v2.tauri.app/reference/javascript/fs/#copyfile
*/
let copyFile: (string, string, ~options: copyFileOptions=?) => promise<unit>

/** Returns the file size in bytes.

    See: https://v2.tauri.app/reference/javascript/fs/#size
*/
let size: string => promise<float>
