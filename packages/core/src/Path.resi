/** Path utilities from `@tauri-apps/api/path`.

    Bindings to the `path` namespace functions plus the `BaseDirectory`
    numeric enum (kept as a `private int` so the integer values match
    the upstream JS enum without exposing arithmetic to callers).

    See: https://v2.tauri.app/reference/javascript/api/namespacepath/
*/

/** Identifies a base directory for path resolution APIs that accept
    a `~baseDir` argument. Mirrors the upstream numeric enum.

    See: https://v2.tauri.app/reference/javascript/api/namespacepath/#basedirectory
*/
module BaseDirectory: {
  type t = private int

  let audio: t
  let cache: t
  let config: t
  let data: t
  let localData: t
  let document: t
  let download: t
  let picture: t
  let public: t
  let video: t
  let resource: t
  let temp: t
  let appConfig: t
  let appData: t
  let appLocalData: t
  let appCache: t
  let appLog: t
  let desktop: t
  let executable: t
  let font: t
  let home: t
  let runtime: t
  let template: t
}

/** Returns the path to the application's config directory.

    See: https://v2.tauri.app/reference/javascript/api/namespacepath/#appconfigdir
*/
let appConfigDir: unit => promise<string>

/** Returns the path to the application's data directory.

    See: https://v2.tauri.app/reference/javascript/api/namespacepath/#appdatadir
*/
let appDataDir: unit => promise<string>

/** Returns the path to the application's local-data directory.

    See: https://v2.tauri.app/reference/javascript/api/namespacepath/#applocaldatadir
*/
let appLocalDataDir: unit => promise<string>

/** Returns the path to the application's cache directory.

    See: https://v2.tauri.app/reference/javascript/api/namespacepath/#appcachedir
*/
let appCacheDir: unit => promise<string>

/** Returns the path to the application's log directory.

    See: https://v2.tauri.app/reference/javascript/api/namespacepath/#applogdir
*/
let appLogDir: unit => promise<string>

/** Returns the user's audio directory.

    See: https://v2.tauri.app/reference/javascript/api/namespacepath/#audiodir
*/
let audioDir: unit => promise<string>

/** Returns the user's cache directory.

    See: https://v2.tauri.app/reference/javascript/api/namespacepath/#cachedir
*/
let cacheDir: unit => promise<string>

/** Returns the user's config directory.

    See: https://v2.tauri.app/reference/javascript/api/namespacepath/#configdir
*/
let configDir: unit => promise<string>

/** Returns the user's data directory.

    See: https://v2.tauri.app/reference/javascript/api/namespacepath/#datadir
*/
let dataDir: unit => promise<string>

/** Returns the user's local-data directory.

    See: https://v2.tauri.app/reference/javascript/api/namespacepath/#localdatadir
*/
let localDataDir: unit => promise<string>

/** Returns the user's desktop directory.

    See: https://v2.tauri.app/reference/javascript/api/namespacepath/#desktopdir
*/
let desktopDir: unit => promise<string>

/** Returns the user's documents directory.

    See: https://v2.tauri.app/reference/javascript/api/namespacepath/#documentdir
*/
let documentDir: unit => promise<string>

/** Returns the user's downloads directory.

    See: https://v2.tauri.app/reference/javascript/api/namespacepath/#downloaddir
*/
let downloadDir: unit => promise<string>

/** Returns the user's executable directory (Linux-only).

    See: https://v2.tauri.app/reference/javascript/api/namespacepath/#executabledir
*/
let executableDir: unit => promise<string>

/** Returns the user's font directory.

    See: https://v2.tauri.app/reference/javascript/api/namespacepath/#fontdir
*/
let fontDir: unit => promise<string>

/** Returns the user's home directory.

    See: https://v2.tauri.app/reference/javascript/api/namespacepath/#homedir
*/
let homeDir: unit => promise<string>

/** Returns the user's pictures directory.

    See: https://v2.tauri.app/reference/javascript/api/namespacepath/#picturedir
*/
let pictureDir: unit => promise<string>

/** Returns the user's public directory.

    See: https://v2.tauri.app/reference/javascript/api/namespacepath/#publicdir
*/
let publicDir: unit => promise<string>

/** Returns the application's resource directory.

    See: https://v2.tauri.app/reference/javascript/api/namespacepath/#resourcedir
*/
let resourceDir: unit => promise<string>

/** Returns the user's runtime directory (Linux-only).

    See: https://v2.tauri.app/reference/javascript/api/namespacepath/#runtimedir
*/
let runtimeDir: unit => promise<string>

/** Returns the user's templates directory.

    See: https://v2.tauri.app/reference/javascript/api/namespacepath/#templatedir
*/
let templateDir: unit => promise<string>

/** Returns the OS temporary directory.

    See: https://v2.tauri.app/reference/javascript/api/namespacepath/#tempdir
*/
let tempDir: unit => promise<string>

/** Returns the user's videos directory.

    See: https://v2.tauri.app/reference/javascript/api/namespacepath/#videodir
*/
let videoDir: unit => promise<string>

/** Resolves the resource at `resourcePath` relative to the bundled
    resource directory.

    See: https://v2.tauri.app/reference/javascript/api/namespacepath/#resolveresource
*/
let resolveResource: string => promise<string>

/** Returns the path separator character for the current OS.

    See: https://v2.tauri.app/reference/javascript/api/namespacepath/#sep
*/
let sep: unit => string

/** Returns the path delimiter character for the current OS.

    See: https://v2.tauri.app/reference/javascript/api/namespacepath/#delimiter
*/
let delimiter: unit => string

/** Joins all segments using the OS-specific separator.

    See: https://v2.tauri.app/reference/javascript/api/namespacepath/#join
*/
let join: array<string> => promise<string>

/** Normalizes the given path, collapsing `.` / `..` segments.

    See: https://v2.tauri.app/reference/javascript/api/namespacepath/#normalize
*/
let normalize: string => promise<string>

/** Returns everything but the last segment of the given path.

    See: https://v2.tauri.app/reference/javascript/api/namespacepath/#dirname
*/
let dirname: string => promise<string>

/** Returns the last segment of the given path. If `~ext` is given,
    that suffix is stripped from the result.

    See: https://v2.tauri.app/reference/javascript/api/namespacepath/#basename
*/
let basename: (string, ~ext: string=?) => promise<string>

/** Returns the file extension of the given path.

    See: https://v2.tauri.app/reference/javascript/api/namespacepath/#extname
*/
let extname: string => promise<string>

/** Whether the given path is absolute.

    See: https://v2.tauri.app/reference/javascript/api/namespacepath/#isabsolute
*/
let isAbsolute: string => promise<bool>

/** Resolves all given segments into an absolute path.

    See: https://v2.tauri.app/reference/javascript/api/namespacepath/#resolve
*/
let resolve: array<string> => promise<string>
