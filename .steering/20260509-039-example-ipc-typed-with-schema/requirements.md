# Requirements: examples/ipc-typed-with-schema

| 項目 | 内容 |
|---|---|
| ステアリング ID | 20260509-039 |
| 親プラン | `.steering/20260509-030-phase2-planning/` §I (Phase 2 完了条件) — examples 追加 |
| 関連パッケージ | `@rescript-tauri/schema` (steering 031 で実装済み) |
| 作成日 | 2026-05-09 |

> 番号 038 は `chore/bump-happy-dom-security` 系で並行進行中の
> `add-biome-format-lint` に割り当て済み。本 steering は 039 として
> 採番する。

---

## 1. 背景

Phase 2 で `@rescript-tauri/schema` の実装が完了した (steering 031)。
A 軸 (examples 追加) のうち plugin-dialog (036) / plugin-fs (037)
完了済み。残り 1 件として schema パッケージを使った例題を追加する。

既存 `examples/ipc-typed/` は Layer 2 (Core.Command.make + 手書き
encoder/decoder) を示しているが、本例題ではそれを Layer 3
(Schema.fromSchemas + rescript-schema スキーマ宣言) に置き換える
ことで、ボイラープレート削減を体感できる対比デモを提供する。

## 2. 目的

- `@rescript-tauri/schema` の **公開 4 関数すべて**
  (`toDecoder`, `fromSchemas`, `channelFromSchema`, `eventFromSchema`)
  を Tauri 2.x アプリ内で実演する。
- `ipc-typed/` と同じ題材 (`greet` / `add`) を Schema ベースで書き
  直し、行数 / 可読性の対比を README で明示する。
- record 型の往復 (`summarize`) と Channel (`count_to`) を加えて
  Schema が実用ペイロードでも十分機能することを示す。
- `pnpm --filter ipc-typed-with-schema build` がローカルで成功する。

## 3. スコープ

### Must（本 steering で対応）

- `examples/ipc-typed-with-schema/` ディレクトリの新規作成
- ReScript フロント (`src/App.res`)
  - `Schema.fromSchemas` で 3 つの Layer 3 typed command を宣言
    - `greet`: `{name: string}` → `string`
    - `add`: `{a: int, b: int}` → `int`
    - `summarize`: `{title: string, items: array<string>}` → `{count: int, joined: string}`
  - `Schema.channelFromSchema` で 1 つの Channel を宣言
    - `count_to`: Channel<int>
  - `Schema.eventFromSchema` を **型レベル** で参照（イベント発火は
    Rust 側補助が必要なため runtime 利用は省略、`let _: Event.t<...> = ...`
    で API 表面を明示）
  - `Schema.toDecoder` も型レベル参照（`fromSchemas` 内部で利用される
    関数だが demo 上で呼び出すケースを明示するために `let _ = ...` で
    保持）
- Rust 側 (`src-tauri/`)
  - `greet` / `add` / `summarize` / `count_to` の 4 ハンドラを実装
  - `summarize` は struct 入出力で serde derive を使う
  - `count_to` は streaming-ipc を踏襲した Channel 利用
- `index.html`（4 操作分の入力フォーム + 結果表示）
- `package.json` / `rescript.json`
  - `dependencies` に `@rescript-tauri/schema` と `rescript-schema` を加える
- `README.md`
  - `ipc-typed/` との対比を含める

### Should（余裕があれば）

- `docs/repository-structure.md` §3 の examples リストに追記
- README に schema vs Core.Command 行数比較表

### 非対象（Out of scope）

- `pnpm tauri dev` の実機実行確認（CI 委譲）
- CI ワークフロー（B 軸で対応）
- 既存 `examples/ipc-typed/` の置き換えや削除（並列で残し、対比できる
  ようにする）
- `eventFromSchema` の Rust emit 側実装（型表面参照のみ）

## 4. 受け入れ条件

1. `examples/ipc-typed-with-schema/` が新規ディレクトリとして作成され、
   `package.json` に `name: "ipc-typed-with-schema"` が含まれる。
2. ローカルで `pnpm install && pnpm --filter ipc-typed-with-schema build`
   が **エラーなく完了** する。
3. `src/App.res` から `Schema.fromSchemas` を 3 回、
   `Schema.channelFromSchema` を 1 回、`Schema.eventFromSchema` および
   `Schema.toDecoder` を最低 1 回ずつ参照する。
4. `pnpm --recursive build` が他パッケージに regression を起こさず
   全件成功し、`pnpm --recursive test` も全件パスする。
5. `tasklist.md` の全タスク（マージタスクを含む）が `[x]` の状態で
   main マージされる。

## 5. 依存・前提

- steering 031 で `@rescript-tauri/schema` が実装済み
  (`Schema.fromSchemas` / `channelFromSchema` / `eventFromSchema` /
  `toDecoder` が API 表面に存在)。
- `rescript-schema ^9.0.0` が peerDep として宣言済み。
- 直近 main (`2759a3e` 以降) には Biome (steering 038) と
  `examples-build.yml` (Node 24 へのバンプ) が含まれる。

## 6. リスク

- **rescript-schema の API 仕様**: `S.object(s => ...)` の field 構文や
  `S.string` / `S.int` などの基本 schema 名がバージョンで揺れる可能性。
  既存 `packages/schema/tests/runtime/schema.test.mjs` が JS 経由で
  rescript-schema を使っているため、その記法を ReScript 側に移植する。
- **Channel 用 Schema**: `channelFromSchema` は decode のみ schema 化し、
  encode 側 (channel handle のシリアライズ) は依然として手書きが必要
  (Channel 経由で送られてくる値を decode するためのもの)。実装上は
  `Schema.channelFromSchema(~message=S.int)` で Channel<int> が得られる
  ため、フロント側はチャンネル受信のみ schema 化される。Rust 側の
  invoke 引数 (`{channel, target}`) は別途 `Schema.fromSchemas` で
  ラップする。
- **Tauri toolchain なし環境での Rust ビルド**: ReScript ビルドのみで
  完了とし、Rust ビルドは CI に委譲する。

## 7. 影響範囲

- 追加: `examples/ipc-typed-with-schema/**`、ステアリング一式
- 更新（任意）: `docs/repository-structure.md`
- 既存パッケージ・他の examples への破壊的変更なし
