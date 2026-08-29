# 要求定義: Core.Raw.convertFileSrc 追加

| 項目 | 内容 |
|---|---|
| 作業 ID | 20260508-010 |
| タイトル | core-raw-convertfilesrc |
| 起票日 | 2026-05-08 |
| 影響範囲 | `packages/core/src/Core.{res,resi}` への 1 binding 追加 + 対応テスト |

## 動機

steering 009 (Phase 1 着手) で `Core.Raw.invoke` を実装した際、設計上は `Core.Raw` モジュールに含まれるべき `convertFileSrc` を意図的にスコープ外として後続に回した。本ステアリングで Raw モジュールを「functional-design §2.1.2 / RFC §2.2 で定義された Layer 1 全 binding」に揃える。

## スコープ

### 対象

- `packages/core/src/Core.res`: `Raw.convertFileSrc` の `@module` external 追加
- `packages/core/src/Core.resi`: 対応する let 宣言 + Tauri 公式 URL 付き doc comment
- `packages/core/tests/core_raw_signature.res`: `convertFileSrc` シグネチャ参照を追加
- `packages/core/tests/runtime/core_raw_convert.test.mjs` (新規): vitest 1〜2 ケース

### 対象外

- `Core.Command` 以降のモジュール (別ステアリング 011+)

## 派生決定

| 論点 | 採用 |
|---|---|
| Tauri docs URL | `https://v2.tauri.app/reference/javascript/api/namespacecore/#convertfilesrc` |
| シグネチャ | functional-design §2.1.2 / RFC §2.2: `(string, ~protocol: string=?) => string` |
| テスト方法 | `globalThis.window.__TAURI_INTERNALS__.convertFileSrc` を mock するか、または `@tauri-apps/api/core` の `convertFileSrc` が同期関数で URL 文字列を組み立てるだけならば mock 不要。実装で動作確認 |
| worktree 名 | `core-raw-convertfilesrc` |

## 受け入れ条件

- [ ] `Core.Raw.convertFileSrc` がドキュメント付きで実装され、`pnpm --filter @rescript-tauri/core build` が警告なく成功
- [ ] 型レベルテストが拡張され `convertFileSrc` シグネチャを参照
- [ ] vitest テストが pass
- [ ] doc comment に Tauri 公式 URL を含む
