# Requirements: Bulk Package Reservation & Trusted Publisher Setup Tooling

| 項目 | 内容 |
|---|---|
| 作成日 | 2026-05-12 |
| 関連 | `.steering/20260508-007-npm-scope-reservation/report.md`, `.steering/20260512-002-npm-trusted-publishing/` |

## 1. 背景

npm Trusted Publishing は **既存パッケージにのみ設定可能** という制約があり ([issue #8544](https://github.com/npm/cli/issues/8544))、未公開パッケージの初回 publish は OIDC 経由では実行できない。

`@rescript-tauri/core` は 2026-05-08 (steering 007) に `0.0.0-reserved` で名前予約済みかつ、Trusted Publisher も Web UI で設定済み (2026-05-12 確認)。残り 9 パッケージ:

- `@rescript-tauri/schema`
- `@rescript-tauri/plugin-fs`
- `@rescript-tauri/plugin-dialog`
- `@rescript-tauri/plugin-shell`
- `@rescript-tauri/plugin-notification`
- `@rescript-tauri/plugin-log`
- `@rescript-tauri/plugin-os`
- `@rescript-tauri/plugin-clipboard-manager`
- `@rescript-tauri/plugin-http`

これらは npm 未公開のため、Trusted Publisher 設定もできない状態。

## 2. ゴール

リリース前の準備作業を自動化する CLI ヘルパースクリプト 2 本を `tools/` 配下に commit する:

1. `tools/reserve-npm-packages.sh` — 9 パッケージを `0.0.0-reserved` で一括 publish
2. `tools/setup-trusted-publishers.sh` — `npm trust github` CLI で 10 パッケージの Trusted Publisher を一括設定（core 含む。core は既に設定済みなので skip ロジックを内包）

これにより:

- 同じ手順を再現可能な形でリポジトリに残す
- 新規パッケージ追加時にも流用可能
- ユーザーは `bash tools/reserve-npm-packages.sh` 一発で完了

## 3. 非ゴール

- 実際のスクリプト実行（npm publish はユーザーの npm auth + 2FA OTP が必要）
- `package.json` の version bump や CHANGELOG 確定（リリース時の別作業）
- Phase 3 6 プラグインのリリースチェックリスト整備（別ステアリング）

## 4. 受け入れ条件

- `tools/reserve-npm-packages.sh` が 9 パッケージ（core 以外）を予約する内容になっている
- `tools/setup-trusted-publishers.sh` が 10 パッケージ全部に対する trust 設定を行うが、core が既に設定済みであっても `--yes` で再確認するか、または skip するロジックを持つ
- 各スクリプトに usage / 前提条件のコメントヘッダが付いている
- スクリプトは `set -euo pipefail` でエラー時に即終了する
- `bash -n` で構文検証が pass する
- `.steering/20260508-007-npm-scope-reservation/report.md` §6 の関連節（Step 6）を「9 パッケージ予約に対応したヘルパースクリプト」を参照する形に更新
- `docs/repository-structure.md` の `tools/` セクションに新規 2 ファイルを追記

## 5. 制約

- スクリプトは bash で書く（CLAUDE.md の shell は zsh だが macOS / Linux 両対応のため bash shebang）
- `npm publish` の冪等性: 既に publish 済みパッケージに対する再 publish はエラーになる。スクリプトは「既存チェック」をしてから publish するか、エラーで止めるか明確にすること
- 2FA OTP は対話的入力が必須。スクリプトは非対話実行を強制しない
- ヘルパースクリプトは pre-release のため backward compat 不要
