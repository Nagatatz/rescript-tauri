# RFC-0002: rescript-tauri Schema Integration

| 項目 | 内容 |
|---|---|
| ステータス | Accepted (2026-05-09) |
| 関連 | [RFC-0001](./RFC-0001-core-api-design.md), [PRD §10 #5](../product-requirements.md), [architecture §10](../architecture.md) |
| 想定実装パッケージ | `@rescript-tauri/schema` |
| 着手 steering | `.steering/archive/20260509-031-schema-package/` |

## 1. Motivation

`@rescript-tauri/core` Phase 1 の `Core.Command.make` は明示的な
`encodeArgs` / `decodeResult` を要求する:

```rescript
let greet = Core.Command.make(
  ~name="greet",
  ~encodeArgs=({name}) => JSON.Encode.object(Dict.fromArray([
    ("name", JSON.Encode.string(name))
  ])),
  ~decodeResult=json =>
    switch json->JSON.Decode.string {
    | Some(s) => Ok(s)
    | None => Error("expected string")
    },
)
```

これは Phase 1 の方針（core を decoder ライブラリ非依存に保つ）として正しい設計だが、ユーザー視点では **同じ shape を args / result の両方で 2 度書く** 必要があり、3〜4 フィールドを越えると現実的にボイラープレートが厳しい。

Phase 2 では、ReScript エコシステムで広く使われている [`rescript-schema`](https://github.com/DZakh/rescript-schema) (旧 `rescript-struct`、deprecated) を活用し、**1 つの `S.t<'value>` から encoder と decoder の両方を導出**できる Layer 3 ヘルパを別パッケージで提供する。

## 2. Decision

### 2.1 採用するスキーマライブラリ

**`rescript-schema`** のみを採用。`rescript-struct` は upstream で deprecated 済み（2026-05-09 確認）なので対象外。

### 2.2 パッケージ構造

`@rescript-tauri/schema` を独立 npm パッケージとして公開する:

```
packages/schema/
├── src/
│   └── Schema.res / .resi
├── tests/
│   ├── schema_signature.res          # 型レベル網羅
│   └── runtime/
│       └── schema.test.mjs           # vitest + Mocks 経由
├── rescript.json
├── package.json                      # @rescript-tauri/schema
└── README.md
```

### 2.3 公開 API

```rescript
// packages/schema/src/Schema.resi

/** rescript-schema の S.t<'value> を Core の decoder<'value> に変換する。
    parseJsonOrThrow が S.Raised(error) を投げた場合、Error(message) に
    包んで返す。decode 失敗をユーザー側で握り潰したいときも、明示的な
    `result` パターンマッチで意図を出せる。
*/
let toDecoder: S.t<'value> => Core.decoder<'value>

/** rescript-schema 駆動でコマンドを宣言する。args は reverseConvertToJson、
    result は parseJsonOrThrow で内部処理される。 */
let fromSchemas: (
  ~name: string,
  ~args: S.t<'args>,
  ~result: S.t<'result>,
) => Core.Command.t<'args, 'result>

/** rescript-schema 駆動でチャネルを作る。 */
let channelFromSchema: (~message: S.t<'message>) => Core.Channel.t<'message>

/** rescript-schema 駆動でイベントを宣言する。 */
let eventFromSchema: (~name: string, ~payload: S.t<'payload>) => Core.Event.t<'payload>
```

### 2.4 内部実装の核

```rescript
let toDecoder = (schema: S.t<'value>): Core.decoder<'value> =>
  json =>
    try Ok(json->S.parseJsonOrThrow(schema)) catch {
    | S.Raised(error) => Error(S.Error.message(error))
    }

let fromSchemas = (~name, ~args: S.t<'args>, ~result: S.t<'result>) =>
  Core.Command.make(
    ~name,
    ~encodeArgs=value => value->S.reverseConvertToJsonOrThrow(args),
    ~decodeResult=toDecoder(result),
  )
```

### 2.5 依存関係

```json
{
  "name": "@rescript-tauri/schema",
  "peerDependencies": {
    "@rescript-tauri/core": "^0.1.0",
    "rescript-schema": "^9.0.0",
    "rescript": ">=12.0.0",
    "@rescript/core": ">=1.6.0"
  }
}
```

`@rescript-tauri/core` への peerDep は `^0.1.0` 始まり。core が `v1.0.0` に到達後は `^1.0.0` を許容する形に上げる。

### 2.6 利用例

```rescript
open RescriptSchema  // S.* を提供
open RescriptTauriCore.Tauri
module Schema = RescriptTauriSchema.Schema

let greet = Schema.fromSchemas(
  ~name="greet",
  ~args=S.object(s => {name: s->S.field("name", S.string)}),
  ~result=S.string,
)

switch await greet->Core.Command.invoke({name: "ReScript"}) {
| Ok(message) => Console.log(message)
| Error(DecodeError(msg)) => Console.error("decode failed: " ++ msg)
| Error(RustError(json)) => Console.error2("rust error:", json)
}
```

`@rescript-schema` の compile-time 推論により、`args` / `result` の `S.t` を変えるだけで `Core.Command.invoke` 側の引数・戻り値の型が変わる。

## 3. Alternatives considered

### 3.1 core に schema 統合を内蔵

却下。core 単独利用ユーザー（schema を採用しない選択肢を保持したいユーザー）に重い依存を強制する。Phase 1 の「core は decoder ライブラリ非依存」原則を維持する。

### 3.2 `rescript-schema` と `rescript-struct` の両方サポート

却下。`rescript-struct` は deprecated。両対応すると API 重複で保守負荷が倍になる。

### 3.3 `rescript-schema` の `S.parseOrThrow` を使う

却下。`parseOrThrow` は **任意の JS 値**（'unknown'）を取るので、`Core.decoder<'value> = JSON.t => result<...>` の入力型と完全一致しない。`parseJsonOrThrow` は `Js.Json.t` を取るので意味的にも正しい。

### 3.4 ラッパ関数 `Schema.toDecoder` を公開しない

却下。`fromSchemas` 内部で使うだけでなく、ユーザーが `Core.Channel.make` / `Core.Event.make` を直接使いつつ decoder だけ schema 駆動にしたいケースもある。

## 4. Open questions

| # | 論点 | 暫定方針 | 確定タイミング |
|---|---|---|---|
| 1 | `S.Error.message` のメッセージ形式が `rescript-schema` minor で変わる可能性 | そのまま透過（変換しない） | upstream major 時に再評価 |
| 2 | `@rescript-tauri/schema` 自体の `Command.invoke` ラッパ（`Schema.invokeOrThrowSchema` 等）の追加 | 当面提供しない（core の `invoke` / `invokeExn` で十分） | Phase 2 リリース後に再評価 |
| 3 | `rescript-schema` v10+ への追従 | 既知の v9 との互換性を `peerDependencies` で示す（`^9.0.0`）、v10 出たら互換 CI で先行検知 | upstream リリース時 |

## 5. Acceptance criteria

- [x] `rescript-schema` を採用、`rescript-struct` は不採用と確定
- [x] `Schema.toDecoder` / `fromSchemas` / `channelFromSchema` / `eventFromSchema` の API 表面確定
- [x] `peerDependencies` 範囲確定 (`@rescript-tauri/core ^0.1.0`, `rescript-schema ^9.0.0`)
- [ ] 実装と試験は steering 031 で実施（RFC ではここまで決定）

---

## 6. References

- [rescript-schema npm](https://www.npmjs.com/package/rescript-schema)
- [rescript-schema GitHub](https://github.com/DZakh/rescript-schema)
- [Phase 2 Planning Steering](../../.steering/archive/20260509-030-phase2-planning/)
- [Schema Package Bootstrap Steering](../../.steering/archive/20260509-031-schema-package/)
