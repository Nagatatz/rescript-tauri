# 設計: `@rescript-tauri/plugin-clipboard-manager`

```rescript
type writeTextOptions = {label?: string}

@module("@tauri-apps/plugin-clipboard-manager")
external writeText: (string, ~opts: writeTextOptions=?) => promise<unit> = "writeText"

@module("@tauri-apps/plugin-clipboard-manager")
external readText: unit => promise<string> = "readText"

@module("@tauri-apps/plugin-clipboard-manager")
external writeImage: 'image => promise<unit> = "writeImage"

@module("@tauri-apps/plugin-clipboard-manager")
external readImage: unit => promise<RescriptTauriCore.Image.t> = "readImage"

@module("@tauri-apps/plugin-clipboard-manager")
external writeHtml: (string, ~altText: string=?) => promise<unit> = "writeHtml"

@module("@tauri-apps/plugin-clipboard-manager")
external clear: unit => promise<unit> = "clear"
```

`writeImage` は upstream で `string | Image | Uint8Array | ArrayBuffer | number[]` を受け取るが、ReScript 側で union を表現する必要はなく、polymorphic `'image` で十分（呼び出し側の責任）。

## テスト
- 型レベル: 6 関数 + writeTextOptions 型を `_check_` で参照
- ランタイム: `Mocks.mockIPC` で IPC コマンド名 (`plugin:clipboard-manager|*`) を検証
