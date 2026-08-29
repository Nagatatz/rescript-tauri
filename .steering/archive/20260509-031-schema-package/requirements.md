# Steering 031: @rescript-tauri/schema パッケージ実装

| 項目 | 内容 |
|---|---|
| 作成日 | 2026-05-09 |
| 関連 | RFC-0002, .steering/20260509-030-phase2-planning, PRD §3 Story 1-3, architecture §10 |
| ブランチ | `worktree-phase2-schema-package` |

## 背景

Phase 2 計画 (steering 030) で「最初に着手するサブ steering」として確定した
`@rescript-tauri/schema` パッケージの bootstrap + `Command.fromSchemas` 実装。

RFC-0002 (本 steering で同時に作成) で確定した API:

```rescript
let toDecoder: S.t<'value> => Core.decoder<'value>
let fromSchemas: (
  ~name: string,
  ~args: S.t<'args>,
  ~result: S.t<'result>,
) => Core.Command.t<'args, 'result>
let channelFromSchema: (~message: S.t<'message>) => Core.Channel.t<'message>
let eventFromSchema: (~name: string, ~payload: S.t<'payload>) => Core.Event.t<'payload>
```

## 要求

### A. RFC-0002 の確定

`docs/ideas/RFC-0002-schema-integration.md` を新規作成し、本 steering と一緒にコミットする。RFC は本 steering で **Accepted** ステータスにする（先行レビュー / コメントは別途、Phase 1 リリース前にメンテナが確認）。

### B. パッケージ bootstrap

`packages/schema/` を新規作成する:

- `package.json` — `@rescript-tauri/schema`、private なし、`peerDependencies` 確定
- `rescript.json` — core と同等の build 設定
- `src/Schema.res` / `Schema.resi` — RFC-0002 §2.3 の API を実装
- `tests/schema_signature.res` — 型レベル網羅
- `tests/runtime/schema.test.mjs` — vitest + Mocks 経由
- `README.md` — 利用例 + 互換マトリクス

### C. ワークスペース統合

`pnpm-workspace.yaml` は既に `packages/*` を拾うので追加変更なし。`docs/repository-structure.md` の `packages/schema/` 記述を Phase 2 完成形に更新する。

### D. CI 拡張

`.github/workflows/` に以下を追加:

- 既存 `build-core.yml` のパスフィルタに `packages/schema/**` を追加するか、新規 `build-schema.yml` を切るかは design.md で確定
- 同様に `tests-schema-types.yml` / `tests-schema-runtime.yml` を新規追加（または既存ジョブの matrix に統合）

### E. テスト

- 型レベル: `tests/schema_signature.res` で公開シンボルすべてを参照
- runtime: 以下シナリオを vitest で検証
  - `fromSchemas` で `string -> string` コマンドを宣言、`Mocks.mockIPC` で round-trip 成功
  - decoder 失敗（schema 不一致 JSON）が `Error(DecodeError(msg))` に
  - encoder（`reverseConvertToJsonOrThrow`）が JSON 化する
  - `channelFromSchema` で Channel が動く（既存 core_channel.test.mjs と同形のテスト）

## Non-goals

- examples (`examples/ipc-typed-with-schema/`) の作成は本 steering に含めるが optional。CI 緑が崩れない範囲で進める
- npm publish は Phase 1 完了後に別途 release-checklist で実施（本 steering ではタグ未付与）
- `Schema.invokeOrThrowSchema` 等の追加ヘルパ（RFC-0002 #2 で当面提供しない確定）

## 受け入れ条件

- [x] `docs/ideas/RFC-0002-schema-integration.md` 作成
- [x] `packages/schema/` 雛形 + 全ファイル
- [x] `pnpm --filter @rescript-tauri/schema build` 緑
- [x] `pnpm --filter @rescript-tauri/schema test` 緑
- [x] 公開シンボルカバレッジ 100%（schema 専用カウント）
- [x] core 側の build / test に regression なし
- [x] `docs/repository-structure.md` 更新
