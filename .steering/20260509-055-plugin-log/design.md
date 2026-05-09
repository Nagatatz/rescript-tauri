# 設計: `@rescript-tauri/plugin-log`

## 1. モジュール構造

```rescript
// PluginLog.res
type unlisten = unit => unit

type logOptions = {
  file?: string,
  line?: int,
  keyValues?: Dict.t<string>,
}

module LogLevel = {
  let trace: int = 1
  let debug_: int = 2  // suffix to avoid $$debug if necessary
  let info_: int = 3
  let warn_: int = 4
  let error_: int = 5
}

type recordPayload = {
  level: int,
  message: string,
}

@module("@tauri-apps/plugin-log")
external error: (string, ~options: logOptions=?) => promise<unit> = "error"
// ... debug, info, warn, trace 同様

@module("@tauri-apps/plugin-log")
external attachLogger: (recordPayload => unit) => promise<unlisten> = "attachLogger"

@module("@tauri-apps/plugin-log")
external attachConsole: unit => promise<unlisten> = "attachConsole"
```

## 2. 名前衝突への対応

ReScript は `error` / `warn` / `info` / `debug` / `trace` を bind 名としてそのまま使える（識別子）が、生成される JS では `$$error` などにエスケープされうる。実装後に build 結果を確認し、エスケープが入る場合は `let warn_ = warn` 等のリネームを検討。`@module` で external 名を文字列で固定するため、ReScript 側の名前は自由に決められる。

`LogLevel.debug_` / `info_` / `warn_` / `error_` は予約語回避の suffix 付きで公開する（`PluginNotification.Visibility.{private_, public_}` と同じ規約）。

## 3. テスト

- 型レベル: 全 export を `_check_` で参照（10 シンボル + 3 型）
- ランタイム: `Mocks.mockIPC` で `plugin:log|log` の `level` / `message` / `options` 引数を検証。`attachLogger` / `attachConsole` は Tauri Event 経由のため event リスナー追加検証で代替。
