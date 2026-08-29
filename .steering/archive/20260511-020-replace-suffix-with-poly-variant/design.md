# Design: 予約語回避 suffix を polymorphic variant に置換

## 採用方針

既存の `PluginOs.platform` / `osType` / `arch` / `family` / `PluginNotification.notificationPermission` / `scheduleEvery` がすべて **polymorphic variant** で公開されているため、新規 enum も polymorphic variant + `@as(N)` で統一する。`@unboxed` regular variant ではなく polymorphic variant を選ぶ。

ReScript 12 で polymorphic variant タグに `@as(N)` を付けると、runtime 表現が数値整数になり upstream の数値 enum と wire-compatible。

## 1. PluginLog — `LogLevel` 廃止、`level` 変種を追加

### Before

```rescript
// PluginLog.res
module LogLevel = {
  let trace: int = 1
  let debug_: int = 2
  let info_: int = 3
  let warn_: int = 4
  let error_: int = 5
}
type recordPayload = {level: int, message: string}
```

### After

```rescript
// PluginLog.res / .resi
type level = [
  | @as(1) #trace
  | @as(2) #debug
  | @as(3) #info
  | @as(4) #warn
  | @as(5) #error
]

type recordPayload = {level: level, message: string}
```

トップレベル関数 `error()` / `warn()` / `info()` / `debug()` / `trace()` は **変更なし**（関数名は ReScript 識別子として有効。JS `$$` エスケープは関数定義側では発生せず、`external` 結合の戻り値型としてのみ問題になる）。

利用側:

```rescript
// Before:
let level = PluginLog.LogLevel.error_  // int = 5

// After:
let level: PluginLog.level = #error  // polymorphic variant, runtime = 5

// pattern match on received payload:
switch payload.level {
| #error => Js.log("ERROR")
| #warn => Js.log("WARN")
| #info | #debug | #trace => ()
}
```

### IPC 互換性

`@as(1) #trace` 等の polymorphic variant タグは JS runtime で **素の数値** として現れる。upstream の `recordPayload` も数値 `level` を返すため、wire-format 一致。

## 2. PluginNotification — `Importance` / `Visibility` 置換

### Before

```rescript
module Importance = {
  let none: int = 0
  let min: int = 1
  let low: int = 2
  let default_: int = 3
  let high: int = 4
}

module Visibility = {
  let secret: int = -1
  let private_: int = 0
  let public_: int = 1
}
```

### After

```rescript
type importance = [
  | @as(0) #none
  | @as(1) #min
  | @as(2) #low
  | @as(3) #default
  | @as(4) #high
]

type visibility = [
  | @as(-1) #secret
  | @as(0) #private
  | @as(1) #public
]

type options = {
  // ...
  visibility?: visibility,
  // ...
}

type channel = {
  // ...
  importance?: importance,
  visibility?: visibility,
  // ...
}
```

**確認事項（実装時に検証）**:
- `#private` / `#public` は ReScript 12 で polymorphic variant タグとして有効（`#` 接頭辞により reserved word 制約は外れる）。万一コンパイルエラーが出た場合は `#Private` / `#Public` に capitalize して逃げる（命名一貫性を多少犠牲にする）。
- `#default` は既存 `notificationPermission = [#default | #granted | #denied]` で既に有効。

## 3. PluginOs — `osType_` を `OsType.get()` に変更

### Before

```rescript
// PluginOs.res
@module("@tauri-apps/plugin-os") external osType_: unit => osType = "type"
```

### After

```rescript
// PluginOs.res
module OsType = {
  @module("@tauri-apps/plugin-os") external get: unit => osType = "type"
}
```

公開 `.resi`:

```rescript
module OsType: {
  /** Returns the OS type. Synchronous (compile-time).
      See: https://v2.tauri.app/reference/javascript/os/#type
  */
  let get: unit => osType
}
```

利用側:

```rescript
let t = PluginOs.OsType.get()  // 旧: PluginOs.osType_()
```

`type osType = [#linux | ...]` 自体は変更なし — 既に polymorphic variant で適切に定義されている。

## 4. テスト更新

### plugin_log.test.mjs

```js
// Before:
const levels = [
  ["error", PluginLog.LogLevel.error_],
  ["warn", PluginLog.LogLevel.warn_],
  ["info", PluginLog.LogLevel.info_],
  ["debug", PluginLog.LogLevel.debug_],
  ["trace", PluginLog.LogLevel.trace],
]

// After: 定数自体が消えるので数値直書き
const levels = [
  ["error", 5],
  ["warn", 4],
  ["info", 3],
  ["debug", 2],
  ["trace", 1],
]

// "LogLevel constants" describe block は削除
```

### plugin_notification.test.mjs

```js
// Before:
expect(PluginNotification.Importance.default_).toBe(3)
expect(PluginNotification.Visibility.private_).toBe(0)

// After: 定数が消えるため "Importance / Visibility constants" describe block を削除
```

### plugin_os.test.mjs

```js
// Before:
expect(PluginOs.osType_()).toBe("macos")

// After:
expect(PluginOs.OsType.get()).toBe("macos")
```

## 5. signature テスト更新

`_check_` ヘルパは公開シンボルごとに 1 つ。削除分を除き、新規 `level` / `importance` / `visibility` 型と `OsType.get` に対応する `_check_` を追加。

例:

```rescript
// PluginLog signature.res
let _check_level_trace: PluginLog.level = #trace
let _check_level_error: PluginLog.level = #error
let _check_recordPayload: PluginLog.recordPayload = {level: #error, message: "x"}
```

```rescript
// PluginOs signature.res
let _check_OsType_get: unit => PluginOs.osType = PluginOs.OsType.get
```

`_check_` 数の変動に伴い、`.github/workflows/tests-plugin-*-types.yml` の `PUBLIC_COUNT` カウンタ（`.resi` の公開 `let` 数）も自動的に追従するはず（手動更新不要）。

## 6. ドキュメント更新

- `packages/plugin-log/README.md` / `CHANGELOG.md` に breaking change 記載
- `packages/plugin-notification/README.md` / `CHANGELOG.md`
- `packages/plugin-os/README.md` / `CHANGELOG.md`
- `sphinx-docs/user/plugin-log.md` / `plugin-notification.md` / `plugin-os.md` の例コード差分
- `sphinx-docs/locale/ja/LC_MESSAGES/user/*.po` 対応箇所
- `docs/repository-structure.md` の plugin 説明欄（plugin-log / plugin-notification / plugin-os）

## 7. リスク

- **`#private` の tag 受理**: 実装時に最初に確認。ダメなら `#Private` に切り替え（要事前テスト）
- **タグ名衝突**: `#none` は ReScript で多用される汎用タグ。`importance` 型コンテキスト外で `#none` を使うと推論が混乱する可能性。実装中に発生したら適切な type annotation で対処
- **examples の追従漏れ**: `examples/plugin-log-demo` / `plugin-notification-demo` / `plugin-os-demo` の更新を忘れない
