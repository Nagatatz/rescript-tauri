# 設計: `@rescript-tauri/plugin-os`

## 1. 型

```rescript
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
```

## 2. 関数

```rescript
@module("@tauri-apps/plugin-os") external eol: unit => string = "eol"
@module("@tauri-apps/plugin-os") external platform: unit => platform = "platform"
@module("@tauri-apps/plugin-os") external version: unit => string = "version"
@module("@tauri-apps/plugin-os") external family: unit => family = "family"

// `type` は ReScript 予約語のため osType_ にリネーム
@module("@tauri-apps/plugin-os") external osType_: unit => osType = "type"

@module("@tauri-apps/plugin-os") external arch: unit => arch = "arch"
@module("@tauri-apps/plugin-os") external exeExtension: unit => string = "exeExtension"
@module("@tauri-apps/plugin-os") external locale: unit => promise<Nullable.t<string>> = "locale"
@module("@tauri-apps/plugin-os") external hostname: unit => promise<Nullable.t<string>> = "hostname"
```

## 3. テスト

- 型レベル: 全 13 export を `_check_` で参照
- ランタイム:
  - sync 7 関数: `globalThis.window.__TAURI_OS_PLUGIN_INTERNALS__` を stub して期待値を返すか確認
  - async 2 関数: `Mocks.mockIPC` で `plugin:os|locale` / `plugin:os|hostname` を検証
