# 要求定義: Phase 1 着手 — pnpm workspace + packages/core スケルトン + Core.Raw.invoke

| 項目 | 内容 |
|---|---|
| 作業 ID | 20260508-009 |
| タイトル | phase1-core-raw-invoke |
| 起票日 | 2026-05-08 |
| 起票者 | ユーザー指示 |
| 影響範囲 | リポジトリルートのワークスペース設定 + `packages/core/` 新規 + `.gitignore` 軽微更新 |

## 1. 背景

steering 001〜008 でドキュメントとリポジトリ設定が整い、設計は確定。RFC §15 Decision checklist は `npm scope 予約 (steering 007)` 以外すべて達成。Phase 1 実装着手のための前提条件は揃っている。

ただし現状リポジトリには:
- ルート `package.json` が存在しない
- `pnpm-workspace.yaml` が存在しない
- `packages/` ディレクトリが存在しない
- どのソースコードもまだ存在しない

つまり Phase 1 の **第一歩を踏み出す** ことが本ステアリングの目的。

## 2. 動機

- **設計検証の最初の機会**: PRD / functional-design / RFC で定めた API 形を、実コードでビルド可能なところまで持っていき、設計通りに動くかを確認する。
- **後続モジュール実装の土台**: `Core.Event`, `Core.Window`, `Core.Channel` 等を後続ステアリングで追加する際、ビルド・テストの「型」が決まっていれば各モジュール追加コストが大きく下がる。
- **visibility 切替条件 #3 の前進**: README §Visibility の「`@rescript-tauri/core` の最初の npm publish」に向けた最初の一歩。
- **CI 整備の土台**: functional-design §6 で定めた `build-core.yml` / `tests-core-types.yml` / `tests-core-runtime.yml` を後続で実体化する際、対象がないと workflow を書けない。

## 3. スコープ

### 3.1 対象 (in-scope) — 最小スコープ

A. **ルートワークスペース整備**:
- `package.json` (workspace 親、共通 scripts、devDeps)
- `pnpm-workspace.yaml` (`packages/*`, `examples/*` を宣言)
- `.gitignore` 追加 (ReScript の `lib/` / `node_modules/` 等は既設、不足分のみ)

B. **packages/core スケルトン**:
- `packages/core/package.json` (`@rescript-tauri/core@0.0.0`、peerDeps、devDeps、scripts、files、publishConfig)
- `packages/core/rescript.json` (namespace + esmodule + `.res.mjs` + `in-source: true`)
- `packages/core/README.md` (短い「what this is」+ ルート README へリンク)
- `packages/core/src/` ディレクトリ

C. **`Core.Raw.invoke` バインディング 1 件のみ**:
- `packages/core/src/Core.res` + `Core.resi` で `module Raw: { let invoke: ... }` を実装
- doc comment: Tauri 公式 URL リンク + 1 行サマリ + 例 (`.claude/rules/code-comments.md` 準拠)
- `convertFileSrc` は **本ステアリング外** (Raw module 内の別 binding として後続で追加)

D. **テスト 2 種**:
- 型レベル: `packages/core/tests/core_raw_signature.res` で `Raw.invoke` を型注釈付きで参照
- runtime: `packages/core/tests/runtime/core_raw.test.mjs` で vitest + happy-dom + `globalThis.window.__TAURI_INTERNALS__.invoke` mock 経由の round-trip 検証

E. **ビルド・テスト動作確認**:
- `pnpm install` 成功
- `pnpm --filter @rescript-tauri/core build` 成功
- `pnpm --filter @rescript-tauri/core test` (型レベル + vitest) 成功

### 3.2 対象外 (out-of-scope) — 別ステアリング

| 項目 | 担当ステアリング |
|---|---|
| `Core.Raw.convertFileSrc` | Phase 1 後続 |
| `Core.Command` (typed Command, `make` / `invoke` / `invokeExn`, `invokeError`) | Phase 1 後続 (Story 1-2) |
| `Core.Channel` | Phase 1 後続 (Story 2-3) |
| `Event` モジュール | Phase 1 後続 |
| `Window`, `Webview`, `WebviewWindow` モジュール | Phase 1 後続 |
| `Path`, `App`, `Dpi`, `Menu`, `Tray`, `Image`, `Mocks` モジュール | Phase 1 後続 |
| `Tauri.res` re-export | 全モジュール出揃った後に決定（PRD §10 行 1）|
| `examples/hello-world` 以降 | Phase 1 中盤以降 |
| CI workflow 実体化 (`build-core.yml`, `tests-core-types.yml`, `tests-core-runtime.yml`, `examples-build.yml`, `doc-link-lint.yml`, `compat-*.yml`, `release.yml`) | コアが動いてから |
| `Mocks` モジュール本体 | Phase 1 後続。今回はテスト内ヘルパで mock |

## 4. 設計上の派生決定（要承認）

### 4.1 ReScript / @rescript/core / @tauri-apps/api のバージョン pin

| Layer | 推奨 |
|---|---|
| `peerDependencies.rescript` | `>=12.0.0` (PRD §5.1 / steering 002 確定) |
| `peerDependencies.@rescript/core` | `>=1.6.0` (PRD §5.1 / steering 002 確定) |
| `peerDependencies.@tauri-apps/api` | `^2.0.0` (PRD §5.1) |
| `devDependencies.rescript` | `^12.2.0` (現在の latest stable) |
| `devDependencies.@rescript/core` | `^1.6.0` |
| `devDependencies.@tauri-apps/api` | `^2.11.0` (現在の latest) |
| `devDependencies.vitest` | `^3.0.0` 系最新 (functional-design §1.3 で `vitest` 指定) |
| `devDependencies.happy-dom` | `^15.0.0` 系最新 |
| `devDependencies.@types/node` | `^22.0.0` 系最新 |

### 4.2 出力フォーマット (rescript.json)

| 項目 | 推奨 | 根拠 |
|---|---|---|
| `namespace` | `true` | RFC §1.2 |
| `package-specs` | `[{ "module": "esmodule", "in-source": true }]` | RFC §1.2 |
| `suffix` | `.res.mjs` | RFC §1.2 |
| `name` | `@rescript-tauri/core` | RFC §1.2 |

`in-source: true` で `.res` の隣に `.res.mjs` が出力される。`lib/` ディレクトリには bs 系の中間ファイルが残るため `.gitignore` に追加 (既設)。

### 4.3 `package.json` の `type` と `files`

| 項目 | 推奨 |
|---|---|
| `type` | `"module"` (ESM のみ) |
| `main` | `./src/Tauri.res.mjs` (Phase 1 末で `Tauri.res` 整備時に正式設定。今回は `./src/Core.res.mjs` で暫定) |
| `files` | `["src/**/*.res", "src/**/*.resi", "src/**/*.res.mjs", "lib/", "README.md"]` |
| `publishConfig.access` | `"public"` |
| `engines.node` | `">=18"` (ReScript 12 + vitest 動作要件) |

`main` は今回 `Core.res.mjs` を指す暫定設定。`Tauri.res` (top-level re-export) を後続ステアリングで作る際に切り替え。

### 4.4 テストフレームワークと配置

| 項目 | 推奨 |
|---|---|
| 型レベル | `packages/core/tests/*.res` をビルド対象に含め、コンパイル成功 = pass。`tests/` を `rescript.json` の `sources` に `{ "dir": "tests", "type": "dev" }` で追加 |
| ランタイム | `packages/core/tests/runtime/*.test.mjs`、vitest + happy-dom env |
| vitest 設定 | `packages/core/vitest.config.mjs` (per-package 配置、ルート集約は workspace が大きくなったら検討) |
| Mock | `globalThis.window.__TAURI_INTERNALS__.invoke = vi.fn(...)` を test setup で行う。`Mocks` モジュール本体は Phase 1 後続で実装 |

### 4.5 worktree

steering-workflow.md の「ステアリングを伴うコード実装は **必ず worktree**」に従い、`EnterWorktree(name="phase1-core-raw-invoke")` で隔離。

## 5. 受け入れ条件

- [ ] ルート `package.json` + `pnpm-workspace.yaml` が存在し `pnpm install` が成功する
- [ ] `packages/core/package.json` の name が `@rescript-tauri/core`、peerDeps が PRD §5.1 と一致
- [ ] `packages/core/src/Core.resi` に `module Raw: { let invoke: ... }` が宣言されており、doc comment が Tauri 公式 URL を含む
- [ ] `packages/core/src/Core.res` で `@module("@tauri-apps/api/core") external invoke = ...` が実装されている
- [ ] `pnpm --filter @rescript-tauri/core build` が成功し `src/Core.res.mjs` が生成される
- [ ] 型レベルテストがコンパイル成功（`Raw.invoke` を型注釈付きで参照、未定義シンボルがあれば fail）
- [ ] vitest テストが pass（`mockIPC` 相当の差し替えで `Raw.invoke` の round-trip が検証される）
- [ ] §4.1 / §4.2 / §4.3 / §4.4 の派生決定が反映されている

## 6. 影響を受けないこと

- 既存 `docs/` / `README.md` / `CLAUDE.md` / `LICENSE` / `CONTRIBUTING.md` / `SECURITY.md` / `CODE_OF_CONDUCT.md`
- `sphinx-docs/` および `.steering/` の他ディレクトリ
- `.github/workflows/` 既存ファイル

## 7. リスク

| リスク | 影響度 | 対応 |
|---|---|---|
| ReScript 12.2.0 + namespace + esmodule 構成で `.res.mjs` 出力周りに罠がある | 中 | 公式ドキュメント (`https://rescript-lang.org/docs/manual/v12.0.0/build-overview`) を確認しつつ、ビルド失敗時は最小再現で切り分け |
| pnpm workspace でルート `node_modules` と packages/core/node_modules の hoisting | 中 | デフォルト hoisting で進め、問題が出たら `.npmrc` で `node-linker=hoisted` 設定を検討 |
| vitest + happy-dom で `globalThis.window` の差し替えが per-test で漏れる | 中 | `beforeEach` / `afterEach` で確実にリセット、`Mocks.clearMocks` 相当のヘルパを test 内で定義 |
| ReScript の binary native package が CI で install できない | 低 (ローカル確認は容易) | macOS では成功確認、Linux/Windows は CI 整備時に確認 (本 steering 外) |
| `tests/` を `rescript.json` の sources に dev type で追加した際の build 出力位置 | 低 | ReScript 12 では dev sources も in-source 出力 |

## 8. 後続タスクへの引き継ぎ

本ステアリング完了後の TODO（別ステアリング）:

- `Core.Raw.convertFileSrc` 追加
- `Core.Command` 実装 (typed Command, encodeArgs/decodeResult, invokeError, invoke, invokeExn)
- `Core.Channel` 実装
- `Event` 実装
- `Window` 実装 (オプジェクトメソッドのバインディング数が多い、独立 steering)
- `Mocks` モジュール本体 (vitest test の mock を整理)
- `examples/hello-world` 整備
- CI workflow 実体化
