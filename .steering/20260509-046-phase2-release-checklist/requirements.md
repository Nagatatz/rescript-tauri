# Requirements: Phase 2 release checklist

| 項目 | 内容 |
|---|---|
| ステアリング ID | 20260509-046 |
| 親プラン | `.steering/20260509-030-phase2-planning/` §I (Phase 2 完了条件) — 「必須スコープがすべて publish + CI 緑」の publish 当日運用 |
| 関連先行 | `.steering/20260509-029-phase1-release-followups/release-checklist.md` (core 用 Phase 1 チェックリスト) |
| 作成日 | 2026-05-09 |

---

## 1. 背景

Phase 2 の必須スコープ (`@rescript-tauri/schema` /
`@rescript-tauri/plugin-fs` / `@rescript-tauri/plugin-dialog`) は
コード・テスト・examples・CI・README・CHANGELOG・sphinx-docs まで
すべて整備済 (steering 031〜045)。残るは実 publish のみで、その
作業は git tag push + 1Password unlock + npm provenance 発行を
伴うため、本セッション (Claude Code 内) では実行できない。

Phase 1 については `steering 029/release-checklist.md` が tag push
ベースの publish 手順を 1 ページにまとめている。Phase 2 用の同等
ドキュメントを作成し、メンテナがコピペで実行できる runbook を
提供する。

## 2. 目的

- 3 Phase 2 パッケージをそれぞれ独立タグで publish するための
  事前確認 / 実行手順 / 事後検証を、1 ページの runbook として
  整備する。
- メンテナが「上から順にチェックを入れていく」だけで Phase 2
  リリースが完了する状態にする。
- 既存 `release.yml` (steering 041 で 4 タグ prefix 対応済) の
  挙動を runbook に反映する (タグ → パッケージ判定 → publish の
  自動化)。

## 3. スコープ

### Must

#### `release-checklist.md` の新規作成

- 場所: `.steering/20260509-046-phase2-release-checklist/release-checklist.md`
- 構成 (Phase 1 の checklist を踏襲):
  1. リリース前確認 (パッケージ別の preflight)
  2. リポジトリ visibility / secrets (Phase 1 で完了済みかの確認)
  3. リリース実行 (3 パッケージそれぞれ tag push)
  4. リリース後検証 (npm view + GitHub Release + sphinx-docs)
  5. 告知 (任意)
  6. Phase 3 起点準備 (フォローアップ)
- 各パッケージのバージョン番号 (`schema-v0.1.0` / `plugin-fs-v0.1.0`
  / `plugin-dialog-v0.1.0`) と publish 順序の推奨を明示
- 各 `package.json` の `version` を `0.0.0` → `0.1.0` に bump する
  作業を含める
- 各 `CHANGELOG.md` の `## Unreleased` を `## 0.1.0 (YYYY-MM-DD)`
  に変えるコミット手順を含める
- `sphinx-docs/user/changelog.md` の各 Phase 2 セクションも対応
  リリース日時に更新する手順を含める

### Should（余裕があれば）

- 3 パッケージの publish 順序の依存性を明示
  - schema / plugin-fs / plugin-dialog はすべて core にだけ依存
    するため、互いに独立に publish 可能。core が npm 上に存在
    することが前提 (Phase 1 release が先行済み前提)。
- Dry-run 手順 (`workflow_dispatch + dry_run=true`) を 3 パッケージ
  それぞれに対して例示

### 非対象（Out of scope）

- 実 publish の実行 (本 steering ではドキュメント整備のみ)
- core (Phase 1) の release-checklist 改訂
- Phase 3 以降のパッケージ (plugin-opener / plugin-process / ...)
  の release 手順 — 別 steering で対応
- `release.yml` の追加機能 (release notes 自動投稿 / pre-release
  サポート等) — 別 steering で対応

## 4. 受け入れ条件

1. `.steering/20260509-046-phase2-release-checklist/release-checklist.md`
   が新規追加される。
2. 3 パッケージそれぞれの publish 手順がコピペで実行可能な
   bash ブロックとして記載される。
3. 各セクションがチェックボックス付きで、メンテナが進捗を
   markdown で trackable な形式になっている。
4. `pnpm --recursive build` / `pnpm --recursive test` が引き続き
   全件パスする (ドキュメントのみ変更)。
5. tasklist の全タスクが `[x]` の状態で main マージされる。

## 5. 依存・前提

- Phase 1 (`v0.1.0`) が **既に publish 済** であること、もしくは
  少なくとも npm `@rescript-tauri/core@0.1.0` が公開されていること
  (Phase 2 パッケージは peerDep 上 core を要求する)。
  - 現状 Phase 1 release は別 session の運用判断待ち。本 checklist
    では「Phase 1 release が完了していること」を前提条件に明記する。
- `release.yml` がすでに `schema-v*` / `plugin-fs-v*` /
  `plugin-dialog-v*` タグ prefix を解釈する (steering 041 で完了済)。
- `NPM_TOKEN` リポジトリシークレットが設定済み (Phase 1 release で
  対応済 — 029 §2 の項目)。

## 6. リスク

- **Phase 1 が未 publish の状態で Phase 2 を publish しようとする**:
  peerDep `@rescript-tauri/core ^0.1.0` が npm 上に存在しないと
  ユーザー側 install で resolution 失敗。チェックリスト先頭で
  「Phase 1 を先行 publish せよ」と明示。
- **タグ prefix の typo**: `plugin-fs-v0.1.0` を `pluginfs-v0.1.0`
  と誤入力するなど。release.yml の case 文は未マッチで `exit 1`
  するため、failure はクラッシュで気付ける。runbook では各 tag
  名を箇条書きで列挙し、コマンド例にも明示。
- **CHANGELOG / package.json バージョン不整合**: tag は `v0.1.0`
  なのに `package.json` の version が `0.0.0` のまま、など。
  チェックリストの "Cut release" セクションに必ず両方の bump を
  含める。

## 7. 影響範囲

- 追加: `.steering/20260509-046-phase2-release-checklist/release-checklist.md`
- 既存パッケージ・コード・テスト・CI には影響なし
