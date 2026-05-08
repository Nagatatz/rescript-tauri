# 設計: @rescript-tauri/core リファクタリング (steering 027)

## 1. 全体像

P2 (Obj.magic 除去) → P1 (decoder 共通化) → P0 (callback で result) → P3 (ドキュメント) の順で実装。各ステップは独立してビルド・テスト可能（ただし Step 2 と Step 3 は型変更が連動するため近接コミット）。

## 2. ファイル別変更点

### 2.1 `packages/core/src/Core.res` / `Core.resi`

#### 追加: `decoder` 型エイリアスと `_applyDecoder` ヘルパ

トップレベル（`module Raw` の上）に追加:

```rescript
type decoder<'value> = JSON.t => result<'value, string>

/** Internal: decode a raw JSON payload and forward the result to a
    user callback. Used by Channel.onMessage and Event._wrap to share
    the decode-then-dispatch pattern. */
let _applyDecoder = (
  decoder: decoder<'a>,
  raw: JSON.t,
  callback: result<'a, string> => unit,
): unit => callback(decoder(raw))
```

`.resi` での公開:

```rescript
/** Maps a raw IPC JSON payload to a typed value. Used by Command,
    Channel, and Event for decoder definitions. */
type decoder<'value> = JSON.t => result<'value, string>
```

`_applyDecoder` は `.resi` に出さない（実装内部のみ）。

#### 追加: `_exnToJson` ヘルパ

```rescript
/** Internal: convert a caught JS exception to a JSON value for
    RustError. Falls back to a string form for non-JS exns. */
let _exnToJson = (exn: exn): JSON.t =>
  switch exn->Exn.asJsExn {
  | Some(jsExn) =>
    Dict.fromArray([
      ("name", JSON.Encode.string(jsExn->Exn.name->Option.getOr("Error"))),
      ("message", JSON.Encode.string(jsExn->Exn.message->Option.getOr(""))),
    ])->JSON.Encode.object
  | None => JSON.Encode.string(Exn.toString(exn))
  }
```

`Command.invoke` 内:

```rescript
| exn => Error(RustError(_exnToJson(exn)))
```

#### `Command.t` / `Channel.t` の型統一

```rescript
module Command = {
  type t<'args, 'result> = {
    name: string,
    encodeArgs: 'args => JSON.t,
    decodeResult: decoder<'result>,
  }
  ...
}

module Channel = {
  type t<'message> = {
    instance: internal,
    decode: decoder<'message>,
  }
  ...
}
```

#### `Channel.onMessage` のシグネチャ変更

```rescript
let onMessage = (chan, callback) =>
  chan.instance->_setOnmessage(raw =>
    _applyDecoder(chan.decode, raw, callback)
  )
```

`.resi`:

```rescript
/** Registers (or replaces) the message handler. The callback receives
    `Ok(message)` when the decoder succeeds and `Error(msg)` when it
    fails. To preserve the prior silent-drop behavior, ignore the
    `Error` branch:

    ```rescript
    chan->Core.Channel.onMessage(result =>
      switch result {
      | Ok(msg) => Console.log(msg)
      | Error(_) => () // ignore decode failures
      }
    )
    ```
*/
let onMessage: (t<'message>, result<'message, string> => unit) => unit
```

#### `make` の型シグネチャは `decoder<_>` で書き換える

```rescript
let make: (~decode: decoder<'message>) => t<'message>
let make: (
  ~name: string,
  ~encodeArgs: 'args => JSON.t,
  ~decodeResult: decoder<'result>,
) => t<'args, 'result>
```

### 2.2 `packages/core/src/Event.res` / `Event.resi`

#### `targetJs` typed record の追加と `_targetToJs` の置換

```rescript
type targetJs = {kind: string, label?: string}

let _targetToJs = (target): targetJs =>
  switch target {
  | Any => {kind: "Any"}
  | AnyLabel(label) => {kind: "AnyLabel", label}
  | App => {kind: "App"}
  | Window(label) => {kind: "Window", label}
  | Webview(label) => {kind: "Webview", label}
  | WebviewWindow(label) => {kind: "WebviewWindow", label}
  }

@module("@tauri-apps/api/event")
external _emitTo: (targetJs, string, 'payload) => promise<unit> = "emitTo"
```

#### `Event.t.decode` を `Core.decoder<_>` に統一

```rescript
type t<'payload> = {
  name: string,
  decode: Core.decoder<'payload>,
}
```

#### `_wrap` を `Core._applyDecoder` 経由に

```rescript
/** Internal: decode a raw event payload and dispatch to the user
    handler with `Ok(event)` or `Error(msg)`. */
let _wrap = (
  event: t<'payload>,
  handler: result<event<'payload>, string> => unit,
  raw: rawEvent,
): unit =>
  Core._applyDecoder(event.decode, raw.payload, decoded =>
    handler(
      switch decoded {
      | Ok(p) => Ok({event: raw.event, id: raw.id, payload: p})
      | Error(msg) => Error(msg)
      },
    )
  )
```

#### `listen` / `once` のシグネチャ変更

```rescript
let listen = (event, handler) =>
  _listen(event.name, raw => _wrap(event, handler, raw))

let once = (event, handler) =>
  _once(event.name, raw => _wrap(event, handler, raw))
```

`.resi`:

```rescript
/** Subscribes to every emission of the event. The callback receives:
    - `Ok(event)` when the JSON payload decodes successfully
    - `Error(msg)` with the decoder error message on failure

    Callers must handle both cases explicitly. To preserve the prior
    silent-drop behavior, ignore the `Error` branch.

    See: https://v2.tauri.app/reference/javascript/api/namespaceevent/#listen
*/
let listen: (
  t<'payload>,
  result<event<'payload>, string> => unit,
) => promise<unlisten>

let once: (
  t<'payload>,
  result<event<'payload>, string> => unit,
) => promise<unlisten>
```

### 2.3 テスト変更

#### `packages/core/tests/runtime/event.test.mjs`

- "listen captures a callback" → callback が `{TAG: "Ok", _0: event}` を受ける
- "listen drops messages whose decode fails" → "callback receives Error on decode failure"; `Error("not a string")` が来ること
- "emit / emitTo" は変更不要（callback 関連なし）
- 新規: 連続デリバー（成功 → 失敗 → 成功）で Ok/Error/Ok の順で受けること

#### `packages/core/tests/runtime/core_channel.test.mjs`

- "onMessage forwards decoded messages" → callback が `Ok(...)` を受ける
- "decode failures are silently dropped" → callback が `Error(...)` を受ける
- 連続デリバー統合テストを追加

#### `packages/core/tests/event_signature.res` / `core_channel_signature.res`

callback シグネチャを `result<_, string> => unit` に書き換え。

#### `packages/core/tests/core_command_signature.res`

`decoder<_>` エイリアス使用に追従（structural equality で通る想定）。

#### `packages/core/tests/runtime/core_command.test.mjs`

`RustError` ペイロード形が `{name, message}` JSON object に変わる場合、assertion を更新。

### 2.4 ドキュメント更新

#### `docs/functional-design.md`

line 216 周辺・523 周辺の `console.error` 記述を以下に書き換え:

> Event/Channel のデコード失敗は callback に `Error(msg)` として渡される。callback 側で Ok/Error を明示的に handle する責務を持つ。

#### `docs/repository-structure.md` §3

```diff
-examples/hello-world/                     # 最小構成。invoke + Window
-examples/window-management/               # Window / WebviewWindow 操作
-examples/ipc-typed/                       # Command.make の典型例
-examples/streaming-ipc/                   # Channel デモ
+examples/hello-world/                     # 最小構成。invoke + Window
+examples/window-management/               # Window / WebviewWindow 操作 (Phase 2+ planned, 未作成)
+examples/ipc-typed/                       # Command.make の典型例 (Phase 2+ planned, 未作成)
+examples/streaming-ipc/                   # Channel デモ (Phase 2+ planned, 未作成)
```

#### `docs/architecture.md`

新セクション「Decode failure policy」を追加（300〜500 字程度）:

> `@rescript-tauri/core` のデコード失敗は一貫して `result<_, string>` で surface する:
> - `Command.invoke`: `result<_, invokeError>` の `Error(DecodeError(msg))`
> - `Channel.onMessage`: callback に `Error(msg)` を渡す
> - `Event.listen` / `once`: callback に `Error(msg)` を渡す
>
> いずれもサイレントドロップは行わない。silent-drop が望ましい呼び出し側はパターンマッチで `Error` ブランチを `_` で破棄する。

## 3. 設計判断

### 3.1 `Decoder.res` 新設は不採用

Phase 1 はモジュール最小化が望ましい。`Core.decoder<_>` で十分。Phase 2 の Schema パッケージは `Core.decoder<_>` を import するか、自身の `decoder` を `=` で alias する。

### 3.2 `@unboxed` variant は不採用

`targetJs` の JS shape は常に object なので unboxed は適合しない。

### 3.3 `~onDecodeError` callback 案は不採用

silent-drop を温存する妥協案だった。pre-1.0 では「callback に result を渡す」一貫した形に統一する方が API として正しい。

### 3.4 Step 順序

P2 → P1 → P0 → P3:
- P2 (Obj.magic 除去) は最も isolated。生成 JS 等価性の baseline を確認しやすい。
- P1 (decoder alias) は型エイリアス追加のみで behavior 変化なし。
- P0 (callback シグネチャ) で破壊変更を入れる。
- P3 (docs) は最後に整合させる。

### 3.5 Step 2 と Step 3 の境界

Step 2 は `decoder<_>` 型エイリアス追加と `_applyDecoder` 追加だが、`Channel.onMessage` / `Event._wrap` の callback 形は **Step 2 では変更しない**（既存の switch 内で silent drop を維持）。Step 3 で callback シグネチャを変更する際に `_applyDecoder` の callback 引数を `result<_, _> => unit` 化する。これにより Step 2 単独でビルド・テストが通る。

## 4. 検証

- 各 Step ごとに `pnpm --filter @rescript-tauri/core build && pnpm --filter @rescript-tauri/core test`
- Step 1 完了時: `git diff packages/core/src/Event.res.mjs` で本質差分確認（emitTo の引数構造が等価）
- Step 5 完了時: `pnpm --filter hello-world build` で examples が壊れていないこと確認
- 最終: `grep -r Obj.magic packages/core/src/` が 0 件

## 5. ロールバック戦略

worktree で隔離実装するため、worktree 削除のみで rollback 可能。コミット粒度を細かく分けるため、問題が出た Step 単位で `git revert` も可能。

## 6. 参照

- `docs/functional-design.md` §1.2
- `docs/architecture.md` （Decode failure policy セクション追加先）
- ReScript Core: `Exn.asJsExn`, `Exn.message`, `Exn.name`, `Exn.toString`
