# Requirements: CI Follow-up — pnpm Version Conflict & Sphinx Pytest Empty-collection

| 項目 | 内容 |
|---|---|
| 作業 ID | 20260509-030-ci-pnpm-and-pytest-fix |
| 作成日 | 2026-05-09 |
| 起票理由 | steering 028 で SHA pin を適用後、CI ジョブが起動するようになった結果、別の 2 種のリグレッション/既存問題が顕在化した |

## 1. 背景

`worktree-ci-pin-action-shas` のマージ（commit `bd74908`）で SHA pin ポリシーは満たしたが、HEAD `7ebe4f5` の CI 実行で次の 2 件が顕在化:

### 問題 1: pnpm/action-setup v4.4.0 がバージョン重複指定で失敗

```
Error: Multiple versions of pnpm specified:
  - version 10 in the GitHub Action config with the key "version"
  - version pnpm@10.28.1 in the package.json with the key "packageManager"
```

`pnpm/action-setup@v4.4.0` 以降は `with.version` と `package.json#packageManager` の両方を指定するとエラーで終了する。これまで `@v4` がより古い minor を解決していたため見えていなかった挙動。

### 問題 2: docs ワークフローの pytest が「テスト 0 件」で exit code 5

`sphinx-docs/tests/` には `__init__.py` のみ存在しテスト本体が無いため、`uv run pytest` は exit code 5 (`no tests collected`) を返し、ジョブが失敗する。これは steering 026 のマージ（sphinx-docs 同期）で発生していた既存問題で、SHA pin と直接関係はないが、CI を緑にするために同梱で修正する。

## 2. 機能要件

- [REQ-1] 全ワークフロー上の `pnpm/action-setup` ステップから `with: version: <N>` を削除する。`package.json` の `packageManager` を SSOT として参照させる
- [REQ-2] `docs.yml` の `Pytest` ステップは、`sphinx-docs/tests/` 配下に `test_*.py` または `*_test.py` が **存在する場合のみ** 実行する。存在しない場合はスキップして緑とする
- [REQ-3] 上記以外のワークフローのオプション（`node-version`, `cache`, `enable-cache` 等）は変更しない

## 3. 影響対象

### 問題 1: `with.version: 10` を含むワークフロー（計 7 ファイル）

| ファイル | 行 |
|---|---|
| `.github/workflows/build-core.yml` | 28 |
| `.github/workflows/examples-build.yml` | 32 |
| `.github/workflows/tests-core-runtime.yml` | 26 |
| `.github/workflows/tests-core-types.yml` | 26 |
| `.github/workflows/compat-rescript-prerelease.yml` | 28 |
| `.github/workflows/compat-tauri-latest.yml` | 20 |
| `.github/workflows/release.yml` | 28 |

### 問題 2: pytest ステップを持つワークフロー

| ファイル | 行 |
|---|---|
| `.github/workflows/docs.yml` | 46-47 (Pytest step) |

## 4. 非機能要件

- [NFR-1] CI 全ジョブ（doc-link-lint / build-core / tests-core-runtime / tests-core-types / examples-build / Docs）が緑になる、または「実装上の理由で失敗」以外の理由で失敗しないこと
- [NFR-2] pnpm のバージョンが `package.json#packageManager` に一元管理される構造を保つ（SSOT）
- [NFR-3] 将来 `sphinx-docs/tests/` にテストファイルを追加した場合、追加の設定変更なしに pytest が走ること

## 5. スコープ外

- アクション SHA の更新（dependabot 設定）
- pnpm メジャー版アップグレード
- `sphinx-docs/tests/` への実テスト追加（テスト戦略は別途）
