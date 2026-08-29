# Design: examples/ipc-typed-with-schema

## 1. ディレクトリ構成

```
examples/ipc-typed-with-schema/
├── README.md
├── index.html
├── package.json
├── rescript.json
├── src/
│   ├── App.res
│   └── main.mjs
└── src-tauri/
    ├── Cargo.toml
    ├── build.rs
    ├── capabilities/
    │   └── default.json
    ├── icons/                       # hello-world から流用
    ├── src/
    │   └── main.rs
    └── tauri.conf.json
```

## 2. ReScript 側 (`src/App.res`)

設計方針:

- `RescriptTauriSchema.Schema` を主役に据える（`Schema.S` が
  rescript-schema の DSL を再エクスポート）。
- `Core.Command.invoke`, `Core.Channel.onMessage` は引き続き使用。
- DOM はバニラ JS 直叩き（既存 examples と同じ）。

### 2.1 schema 値の宣言

```rescript
open RescriptTauriCore.Tauri
open RescriptTauriSchema

type greetArgs = {name: string}
type addArgs = {a: int, b: int}
type summarizeArgs = {title: string, items: array<string>}
type summary = {count: int, joined: string}

let greetArgsSchema: Schema.S.t<greetArgs> =
  Schema.S.object(s => {name: s->Schema.S.field("name", Schema.S.string)})

let addArgsSchema: Schema.S.t<addArgs> =
  Schema.S.object(s => {
    a: s->Schema.S.field("a", Schema.S.int),
    b: s->Schema.S.field("b", Schema.S.int),
  })

let summarizeArgsSchema: Schema.S.t<summarizeArgs> =
  Schema.S.object(s => {
    title: s->Schema.S.field("title", Schema.S.string),
    items: s->Schema.S.field("items", Schema.S.array(Schema.S.string)),
  })

let summarySchema: Schema.S.t<summary> =
  Schema.S.object(s => {
    count: s->Schema.S.field("count", Schema.S.int),
    joined: s->Schema.S.field("joined", Schema.S.string),
  })
```

### 2.2 typed commands

```rescript
let greet = Schema.fromSchemas(
  ~name="greet",
  ~args=greetArgsSchema,
  ~result=Schema.S.string,
)

let add = Schema.fromSchemas(
  ~name="add",
  ~args=addArgsSchema,
  ~result=Schema.S.int,
)

let summarize = Schema.fromSchemas(
  ~name="summarize",
  ~args=summarizeArgsSchema,
  ~result=summarySchema,
)
```

### 2.3 channel

`channelFromSchema` は受信値の schema を取り、`Core.Channel.t<int>`
を返す。command の引数 (`{channel, target}`) は schema 化できない
（`Channel.t` は不透明型のため）ので、handler 用の Channel 引数は
`Core.Command.make` を使う形にする。

```rescript
type countArgs = {channel: Core.Channel.t<int>, target: int}

let countChannel = Schema.channelFromSchema(~message=Schema.S.int)

let countTo = Core.Command.make(
  ~name="count_to",
  ~encodeArgs=({channel, target}: countArgs) =>
    JSON.Encode.object(
      Dict.fromArray([
        ("channel", Obj.magic(channel)),
        ("target", JSON.Encode.float(Int.toFloat(target))),
      ]),
    ),
  ~decodeResult=_json => Ok(),
)
```

### 2.4 typed events (型レベル参照のみ)

```rescript
// 受け入れ条件 §3 を満たすため `eventFromSchema` への参照を残す。
// このイベント自体は Rust 側からは emit されないため Demo 中は
// 待ち受けるだけになる。
type appStatus = {state: string, uptimeMs: int}
let appStatusSchema = Schema.S.object(s => {
  state: s->Schema.S.field("state", Schema.S.string),
  uptimeMs: s->Schema.S.field("uptime_ms", Schema.S.int),
})

let appStatusEvent: Event.t<appStatus> =
  Schema.eventFromSchema(~name="app://status", ~payload=appStatusSchema)
```

`Schema.toDecoder` も同様に型レベル参照する:

```rescript
// `fromSchemas` 内部で実行されるロジックを直接呼びたい場合の入り口。
let _stringDecoder: Core.decoder<string> = Schema.toDecoder(Schema.S.string)
```

### 2.5 UI ハンドラ

各ボタンが対応する schema-based command を呼ぶ。エラーは
`Core.invokeError` を文字列化して表示。

| ボタン id | 内容 | 表示先 |
|---|---|---|
| `run-greet` | `greet` 呼び出し | `<span id="greet-out">` |
| `run-add` | `add` 呼び出し | `<span id="add-out">` |
| `run-summarize` | `summarize` 呼び出し | `<pre id="summarize-out">` |
| `run-count-to` | `count_to` 呼び出し + チャンネル購読 | `<pre id="channel-out">` |

`run-count-to` は `countChannel` を `Core.Channel.onMessage` で購読し、
受信値を `<pre>` に追記。完了時 `Promise` の `Ok(())` で完了メッセージ
を追記。

### 2.6 `invokeError` 文字列化

```rescript
let invokeErrorToString = (err: Core.invokeError): string =>
  switch err {
  | DecodeError(msg) => "decode error: " ++ msg
  | RustError(payload) => "rust error: " ++ JSON.stringify(payload)
  }
```

## 3. JS / HTML

### 3.1 `src/main.mjs`

```javascript
import "./App.res.mjs";
```

### 3.2 `index.html`

- `greet` セクション: name 入力 + ボタン + 出力
- `add` セクション: a / b 数値入力 + ボタン + 出力
- `summarize` セクション: title 入力 + 改行区切り items textarea + ボタン + 出力
- `count_to` セクション: target 数値入力 + start ボタン + 出力 + 最終値

`examples/ipc-typed/index.html` のスタイルを踏襲。

## 4. Rust 側

### 4.1 `Cargo.toml`

```toml
[package]
name = "ipc-typed-with-schema"
version = "0.0.0"
edition = "2021"

[build-dependencies]
tauri-build = { version = "2", features = [] }

[dependencies]
tauri = { version = "2", features = [] }
serde = { version = "1", features = ["derive"] }
serde_json = "1"
```

`tauri-plugin-*` は不要（schema パッケージは Tauri プラグインでは
ないため）。

### 4.2 `src/main.rs`

```rust
use serde::{Deserialize, Serialize};
use tauri::ipc::Channel;

#[tauri::command]
fn greet(name: &str) -> String {
    format!("Hello, {}! - from rescript-tauri ipc-typed-with-schema", name)
}

#[tauri::command]
fn add(a: i32, b: i32) -> i32 {
    a + b
}

#[derive(Deserialize)]
struct SummarizeArgs {
    title: String,
    items: Vec<String>,
}

#[derive(Serialize)]
struct Summary {
    count: i32,
    joined: String,
}

#[tauri::command]
fn summarize(args: SummarizeArgs) -> Summary {
    Summary {
        count: args.items.len() as i32,
        joined: format!("{}: {}", args.title, args.items.join(", ")),
    }
}

#[tauri::command]
fn count_to(channel: Channel<u32>, target: u32) -> Result<(), String> {
    for n in 1..=target {
        channel.send(n).map_err(|e| e.to_string())?;
    }
    Ok(())
}

fn main() {
    tauri::Builder::default()
        .invoke_handler(tauri::generate_handler![greet, add, summarize, count_to])
        .run(tauri::generate_context!())
        .expect("error while running ipc-typed-with-schema");
}
```

`summarize` の引数を `args: SummarizeArgs` 一括で受け取るため、
フロント側エンコードは `{args: {title, items}}` 形式になる。schema は
ネストを意識して `Schema.S.object` を二重にする…のではなく、Tauri が
自動でフラット化することを利用する: 実は Tauri の `tauri::command` は
`SummarizeArgs` の各フィールドを args オブジェクトのトップレベル
として受け取る挙動なので、フロント側はシンプルに
`{title: ..., items: ...}` を送れる。ただし v2.x の挙動を確認する
必要があり、そうでない場合 `summarize` 関数を `(title, items)` の
2 引数版に変更する。

> 実装時にテスト: 単純引数 `(title: &str, items: Vec<String>)` の方が
> 安全 (各引数が args オブジェクトのトップレベルキーになる Tauri
> v2.x の標準挙動)。本 design では struct 引数ではなく 2 引数に
> 切り替える。

修正版:

```rust
#[tauri::command]
fn summarize(title: &str, items: Vec<String>) -> Summary {
    Summary {
        count: items.len() as i32,
        joined: format!("{}: {}", title, items.join(", ")),
    }
}
```

ReScript 側 schema は変更不要 (`{title, items}` を引数 JSON として
送るため)。

### 4.3 `tauri.conf.json`

`hello-world` ベース、

- `productName`: `"rescript-tauri-ipc-typed-with-schema"`
- `identifier`: `"com.rescript-tauri.example.ipc-typed-with-schema"`
- `app.windows[0].title`: `"ipc-typed (schema)"`

### 4.4 `capabilities/default.json`

invoke を呼ぶだけなので `core:default` のみで十分:

```json
{
  "$schema": "../gen/schemas/desktop-schema.json",
  "identifier": "default",
  "description": "Default capability for ipc-typed-with-schema demo",
  "windows": ["main"],
  "permissions": ["core:default"]
}
```

### 4.5 `build.rs` / `icons/`

hello-world から流用。

## 5. `package.json` / `rescript.json`

### 5.1 `package.json`

```json
{
  "name": "ipc-typed-with-schema",
  "version": "0.0.0",
  "private": true,
  "type": "module",
  "scripts": {
    "build": "rescript build",
    "clean": "rescript clean",
    "tauri": "tauri"
  },
  "dependencies": {
    "@rescript-tauri/core": "workspace:*",
    "@rescript-tauri/schema": "workspace:*",
    "@tauri-apps/api": "^2.11.0",
    "rescript-schema": "^9.0.0"
  },
  "devDependencies": {
    "@rescript/core": "^1.6.0",
    "@rescript/runtime": "^12.2.0",
    "@tauri-apps/cli": "^2.0.0",
    "rescript": "^12.2.0"
  }
}
```

### 5.2 `rescript.json`

```json
{
  "name": "ipc-typed-with-schema",
  "package-specs": [{ "module": "esmodule", "in-source": true }],
  "suffix": ".res.mjs",
  "sources": [{ "dir": "src", "subdirs": true }],
  "dependencies": [
    "@rescript/core",
    "@rescript-tauri/core",
    "@rescript-tauri/schema",
    "rescript-schema"
  ],
  "jsx": { "version": 4 }
}
```

## 6. README.md

- ステータス（Phase 2、schema package 実装後）
- 実行方法（`pnpm install && pnpm --filter ipc-typed-with-schema build`）
- 各操作の説明
- **`ipc-typed/` との対比**: 同じ `greet` / `add` を Schema 化した
  ときの行数比較（`ipc-typed/` の `Core.Command.make` ブロックと
  `Schema.fromSchemas` ブロックを並べる）
- ファイル構成
- Notes:
  - rescript-schema 9.x が peerDep
  - `Core.Channel.t` は不透明型のため、Channel 引数を持つ command は
    依然として `Core.Command.make` で encoder を手書きする必要がある
    こと

## 7. ビルド検証手順

1. `pnpm install`
2. `pnpm --filter ipc-typed-with-schema build`
3. `pnpm --recursive build`
4. `pnpm --recursive test`

## 8. リスクと対応

| リスク | 対応 |
|---|---|
| `Schema.S.int` の存在確認 | `packages/schema/tests/runtime/schema.test.mjs` で確認済 (S.string)。`S.int` は標準 |
| `Schema.S.array` の field 注釈 | `S.array(elementSchema)` 形式（rescript-schema 標準） |
| Tauri v2.x で multi-arg command の引数転送 | 既存 `examples/ipc-typed/` で動作確認済（add は 2 引数）。同じ流儀で実装 |
| `Channel` のフロント Encode | `Obj.magic` で JS 値として埋め込む既存パターンを踏襲（streaming-ipc と同じ） |
| `tasklist.md` 並行更新による merge conflict | merge 直前に main を取り込み、conflict は手動解消 |
