# Requirements: 0.1.3 リリース（plugin-notification は 0.2.0）

| 項目 | 内容 |
|---|---|
| ステアリング番号 | 20261014-001 |
| 作成日 | 2026-10-14 |
| 種別 | release |
| ブランチ | `worktree-release-0.1.3` |
| 前提 | steering 20261013-001（PR #94, merge commit `88301c9`）が main に取り込み済み |

## 背景

`v0.1.2`（2026-08-30）以降、Tauri 2.12 追従（PR #94）で 4 パッケージの公開 API が変わった。npm 公開版は 10 パッケージすべて 0.1.2（`npm view` で確認、2026-10-14）。

| パッケージ | v0.1.2 以降の変更 | 種別 |
|---|---|---|
| core | `App.exit` / `Window.setFullscreenOnMonitor` / liquid glass effect / `noRedirectionBitmap` | 追加のみ |
| plugin-fs | `size` に `~options`、peer `@tauri-apps/plugin-fs ^2.6.0` | 追加 + peer 引き上げ |
| plugin-shell | `spawnOptions.processGroup`、peer `@tauri-apps/plugin-shell ^2.5.0` | 追加 + peer 引き上げ |
| plugin-notification | `onAction` のペイロードが `actionPerformed` に変更、peer `^2.6.0` | **破壊的変更** |
| 残り 6 パッケージ | devDependencies のみ（`src/` 差分なし） | メンテナンス |

## バージョン方針（ユーザー決定、2026-10-14）

- `plugin-notification` のみ **0.2.0**（0.x の破壊的変更は minor を上げる）。
- 他 9 パッケージは **0.1.3**。全 10 パッケージを公開する。
- core が 0.1.x に留まるため、各 plugin の peer `@rescript-tauri/core ^0.1.0` は変更しない。
- これ以降、パッケージ間でバージョンが揃わなくなる（CLAUDE.md「各パッケージは独立 semver」のとおり）。

## 要求

- R1. `packages/*/package.json` の `version` を上記方針どおりに更新する。
- R2. `packages/*/CHANGELOG.md` を確定する。`## Unreleased` を持つ 4 件は見出しを版数 + 日付に置換、残り 6 件は maintenance entry を追加する。
- R3. `sphinx-docs/user/changelog.md` の `## Unreleased` を確定し、6 パッケージの maintenance entry を追記する。「current release `0.1.2`」と書いている箇所（`README.md` / `CONTRIBUTING.md` / `sphinx-docs/index.md` / `sphinx-docs/user/changelog.md`）を更新する。`make update-po` で ja カタログを同期し翻訳する。
- R4. PR → CI green → self-merge 後、merge commit に 10 個の annotated tag を **1 本ずつ** push し `release.yml` を起動する。
- R5. npm 上のバージョンが方針どおりになったことを確認する。

## 受け入れ基準

- [ ] `pnpm install --frozen-lockfile` / `pnpm --recursive build` / `pnpm --recursive test` / `pnpm run check` pass
- [ ] sphinx `make html` / `make build-ja` / `make test` pass、`.po` に fuzzy / 未訳なし
- [ ] release.yml が 10 tag すべて success
- [ ] npm: plugin-notification 0.2.0、他 9 件 0.1.3

## Non-goals

- API / runtime の変更（PR #94 で完了済み）
- plugin ごとの「100% カバー」表記の再検証（別 steering）
