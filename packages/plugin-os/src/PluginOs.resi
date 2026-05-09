/** Bindings for `@tauri-apps/plugin-os` (Tauri 2.x OS info plugin).

    Phase 2+ first iteration: 100% coverage of the stable public
    surface of `@tauri-apps/plugin-os` v2.3.2 — 7 sync getters
    (`eol` / `platform` / `version` / `family` / `osType_` / `arch` /
    `exeExtension`) plus 2 async getters (`locale` / `hostname`),
    backed by 4 polymorphic-variant types matching the upstream
    string-literal types.

    See: https://v2.tauri.app/plugin/os-info/
*/

/** Compile-time platform name. Matches the upstream string-literal
    union `'linux' | 'macos' | 'ios' | 'freebsd' | 'dragonfly' |
    'netbsd' | 'openbsd' | 'solaris' | 'android' | 'windows'`.

    See: https://v2.tauri.app/reference/javascript/os/#platform
*/
type platform = [
  | #linux
  | #macos
  | #ios
  | #freebsd
  | #dragonfly
  | #netbsd
  | #openbsd
  | #solaris
  | #android
  | #windows
]

/** Coarse OS type. Matches the upstream
    `'linux' | 'windows' | 'macos' | 'ios' | 'android'` union.

    See: https://v2.tauri.app/reference/javascript/os/#ostype
*/
type osType = [#linux | #windows | #macos | #ios | #android]

/** CPU architecture. Matches the upstream 11-variant union.

    See: https://v2.tauri.app/reference/javascript/os/#arch
*/
type arch = [
  | #x86
  | #x86_64
  | #arm
  | #aarch64
  | #mips
  | #mips64
  | #powerpc
  | #powerpc64
  | #riscv64
  | #s390x
  | #sparc64
]

/** OS family. `unix` covers POSIX-like systems; `windows` is its own
    family.

    See: https://v2.tauri.app/reference/javascript/os/#family
*/
type family = [#unix | #windows]

/** OS-specific end-of-line marker (`"\n"` on POSIX, `"\r\n"` on
    Windows).

    See: https://v2.tauri.app/reference/javascript/os/#eol
*/
let eol: unit => string

/** Returns the platform name. Synchronous because the value is set at
    compile time.

    See: https://v2.tauri.app/reference/javascript/os/#platform
*/
let platform: unit => platform

/** Returns the OS version string. Synchronous (compile-time).

    See: https://v2.tauri.app/reference/javascript/os/#version
*/
let version: unit => string

/** Returns the OS family. Synchronous (compile-time).

    See: https://v2.tauri.app/reference/javascript/os/#family
*/
let family: unit => family

/** Returns the OS type. Renamed from upstream `type()` because `type`
    is a reserved keyword in ReScript. Synchronous (compile-time).

    See: https://v2.tauri.app/reference/javascript/os/#type
*/
let osType_: unit => osType

/** Returns the CPU architecture. Synchronous (compile-time).

    See: https://v2.tauri.app/reference/javascript/os/#arch
*/
let arch: unit => arch

/** Returns the executable file extension (`"exe"` on Windows, `""`
    elsewhere). Synchronous (compile-time).

    See: https://v2.tauri.app/reference/javascript/os/#exeextension
*/
let exeExtension: unit => string

/** Returns the BCP-47 locale tag, or `Nullable.null` if unavailable.

    See: https://v2.tauri.app/reference/javascript/os/#locale
*/
let locale: unit => promise<Nullable.t<string>>

/** Returns the OS hostname, or `Nullable.null` if unavailable.

    See: https://v2.tauri.app/reference/javascript/os/#hostname
*/
let hostname: unit => promise<Nullable.t<string>>
