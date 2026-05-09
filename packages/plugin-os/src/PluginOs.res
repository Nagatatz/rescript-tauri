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

type osType = [#linux | #windows | #macos | #ios | #android]

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

type family = [#unix | #windows]

@module("@tauri-apps/plugin-os") external eol: unit => string = "eol"
@module("@tauri-apps/plugin-os") external platform: unit => platform = "platform"
@module("@tauri-apps/plugin-os") external version: unit => string = "version"
@module("@tauri-apps/plugin-os") external family: unit => family = "family"

// Renamed from upstream `type` because `type` is reserved in ReScript.
@module("@tauri-apps/plugin-os") external osType_: unit => osType = "type"

@module("@tauri-apps/plugin-os") external arch: unit => arch = "arch"
@module("@tauri-apps/plugin-os") external exeExtension: unit => string = "exeExtension"

@module("@tauri-apps/plugin-os")
external locale: unit => promise<Nullable.t<string>> = "locale"

@module("@tauri-apps/plugin-os")
external hostname: unit => promise<Nullable.t<string>> = "hostname"
