# Design: @rescript-tauri/schema パッケージ実装

## 1. ファイル配置

```
docs/ideas/
└── RFC-0002-schema-integration.md          # 新規

docs/
└── repository-structure.md                 # 更新（packages/schema/ 完成形）

packages/schema/                            # 新規パッケージ
├── src/
│   ├── Schema.res                          # 実装本体
│   └── Schema.resi                         # 公開シグネチャ
├── tests/
│   ├── schema_signature.res                # 型レベル網羅
│   └── runtime/
│       └── schema.test.mjs                 # vitest + Mocks 経由
├── package.json
├── rescript.json
├── vitest.config.mjs
└── README.md
```

## 2. API 確定（RFC-0002 §2.3 に同期）

```rescript
module Core = RescriptTauriCore.Core
module Event = RescriptTauriCore.Event
module S = RescriptSchema.S

let toDecoder: S.t<'value> => Core.decoder<'value>
let fromSchemas: (
  ~name: string,
  ~args: S.t<'args>,
  ~result: S.t<'result>,
) => Core.Command.t<'args, 'result>
let channelFromSchema: (~message: S.t<'message>) => Core.Channel.t<'message>
let eventFromSchema: (~name: string, ~payload: S.t<'payload>) => Event.t<'payload>
```

## 3. 主要設計判断

### 3.1 namespace と module alias

`rescript-schema` は `namespace: true` + `public: ["S"]` で公開しており、外部からは `RescriptSchema.S` でアクセスする。本パッケージの `Schema.res` / `Schema.resi` 冒頭で:

```rescript
module Core = RescriptTauriCore.Core
module Event = RescriptTauriCore.Event
module S = RescriptSchema.S
```

と alias し、本体は短い名前で記述する。

### 3.2 例外 → result への変換

`rescript-schema` は parse 失敗を `S.Raised(error)` 例外で表現する。`toDecoder` で try/catch し、`S.Error.message(error)` で文字列化して `Error(string)` に変換:

```rescript
let toDecoder = (schema) =>
  json =>
    try Ok(json->S.parseJsonOrThrow(schema)) catch {
    | S.Raised(error) => Error(S.Error.message(error))
    }
```

### 3.3 encode 側の戦略

`fromSchemas` の `encodeArgs` では `S.reverseConvertToJsonOrThrow` を直接呼ぶ。encode 失敗（schema-violation な値を渡した場合）は ReScript の型で防止できる前提なので、変換後にユーザ側で握り潰す `result` 化はしない（型が通れば常に成功するというのが rescript-schema の前提）。

### 3.4 peerDependencies の範囲

| Peer | 範囲 | 理由 |
|---|---|---|
| `@rescript-tauri/core` | `^0.1.0` | core が `v1.0.0` に到達後 `^1.0.0` に上げる予定 |
| `rescript-schema` | `^9.0.0` | v9.5.1 で実装、v9 全 minor を想定 |
| `rescript` | `>=12.0.0` | core と一致 |
| `@rescript/core` | `>=1.6.0` | core と一致 |

### 3.5 vitest 環境

core と同じ `happy-dom` を使う。`vitest.config.mjs` を core からそのままコピー（`environment: "happy-dom"` + `include: tests/runtime/**/*.test.mjs`）。

## 4. CI 統合判断

本 steering ではパッケージ自体の CI（`.github/workflows/`）追加は **次の sub-steering に分離** する:

- `tests-schema-types.yml` / `tests-schema-runtime.yml` は schema 専用が望ましい（path filter `packages/schema/**` でトリガ）
- `examples-build.yml` への schema-driven example 追加も別 steering

理由: 本 steering はパッケージ単独の bootstrap + 実装にスコープを絞り、CI の path-filter / matrix 設計は単独テーマで議論する。当面 schema パッケージの build / test は **ローカルおよび `pnpm --recursive build / test` 経由でカバー** されるので、main へマージしても既存 CI は壊れない（既存 `examples-build.yml` などは `examples/**` / `packages/core/**` のみ拾う）。

## 5. テストカバレッジ

`tests/schema_signature.res`: 4 公開シンボル（`toDecoder` / `fromSchemas` / `channelFromSchema` / `eventFromSchema`）を `_check_*` で参照。`.resi` に登場する公開 `let` の数 = 4 と一致。

`tests/runtime/schema.test.mjs`: 5 ケース
- `fromSchemas` 成功 round-trip（mockIPC）
- `fromSchemas` decode mismatch → `Error(DecodeError(...))`
- `toDecoder` 成功 / 失敗
- `channelFromSchema` の Channel が schema 経由で decode する

## 6. リスク

| リスク | 兆候 | 対策 |
|---|---|---|
| `rescript-schema` v10 で API drift | npm view で v10 タグが出る | RFC-0002 #3 通り、互換 CI を別 steering で立ち上げる |
| `S.parseJsonOrThrow` の例外 type 変更 | minor で `S.Raised` の payload 形が変わる | `S.Error.message` API は安定（README 明記）、メッセージ整形のみ捕捉 |
| `@rescript-tauri/core` の Phase 2 中破壊変更 | core が v0.x 中 minor で API 変更 | Phase 1 リリース後 API freeze 方針（`v1.0.0` まで内部使用に注意） |

## 7. リリース戦略（本 steering 範囲外）

- `schema-v0.1.0` タグでの publish は Phase 2 全体の release-checklist で実施（Phase 1 release-checklist と同様の運用）
- 本 steering ではパッケージの version は `0.0.0` のまま（unpublished）
