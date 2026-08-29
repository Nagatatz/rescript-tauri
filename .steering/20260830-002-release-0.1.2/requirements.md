# Requirements: 全パッケージ 0.1.2 メンテナンスリリース

| 項目 | 内容 |
|---|---|
| ステアリング番号 | 20260830-002 |
| 作成日 | 2026-08-30 |
| 種別 | release（patch） |
| ブランチ | `worktree-release-0.1.2` |
| 前提 | steering 20260830-001（PR #56, merge commit `6ca919c`）が main に取り込み済み |

## 背景

`v0.1.1`（2026-06-10）以降、`packages/*` に入った変更は devDependencies の更新のみ（`git diff v0.1.1..main --stat -- packages/` で `package.json` と `CHANGELOG.md` の 20 ファイルのみ。`src/` `.resi` 変更なし）。npm 公開版は 10 パッケージすべて 0.1.1（`npm view` で確認）。ユーザー要望「npm を更新したい」に対し、0.1.1 と同じ手順で patch リリースを行う。

## 要求

- R1. `packages/*/package.json` 10 件の `version` を `0.1.1` → `0.1.2` にする。`peerDependencies` (`@rescript-tauri/core ^0.1.0` 等) は変更しない。
- R2. `packages/*/CHANGELOG.md` 10 件の `## Unreleased` を `## 0.1.2 (2026-08-30)` に確定し、本文を実際の devDependencies 最終バージョンに合わせて書き直す（vitest / @vitest/coverage-v8 4.1.11、happy-dom 20.11.13、@types/node 26.4.0、rescript / @rescript/runtime 12.3.1、core は @tauri-apps/api 2.11.1、plugin-dialog は @tauri-apps/plugin-dialog 2.7.2、plugin-log は @tauri-apps/plugin-log 2.9.0）。
- R3. `sphinx-docs/user/changelog.md` の冒頭 note（"First publishes are pending" — 0.1.0 公開済みのため陳腐化）を更新し、0.1.1 / 0.1.2 の maintenance release を追記する。`make update-po` で ja カタログを同期し新規 entry を翻訳する。
- R4. PR → CI green → self-merge 後、merge commit に 10 個の annotated tag（`v0.1.2` / `schema-v0.1.2` / `plugin-*-v0.1.2`）を push し `release.yml` を起動する（Trusted Publishing で npm publish + GitHub Release 作成）。
- R5. `npm view @rescript-tauri/<pkg> version` が 10 件とも `0.1.2` になることを確認する。

## 受け入れ基準

- [ ] `pnpm install --frozen-lockfile` / `pnpm --recursive build` / `pnpm --recursive test` / `pnpm run check` pass
- [ ] sphinx `make html` / `make build-ja` / `make test` pass、`.po` に fuzzy なし
- [ ] release.yml が 10 tag すべて success
- [ ] npm 上の 10 パッケージが 0.1.2

## Non-goals

- API / runtime の変更（なし）
- minor バージョン (0.2.0) — 公開物に変更が無いため patch とする
