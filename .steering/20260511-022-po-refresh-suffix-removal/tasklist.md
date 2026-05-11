# Tasklist: plugin-{log,notification,os} 翻訳 .po refresh

## Phase 0: 準備

- [x] `EnterWorktree` で worktree `po-refresh-suffix-removal` を作成
- [x] ローカル main を merge して steering 022 を取り込み
- [x] ディスク空き確認（uv install 用に 16GB 利用可能）

## Phase 1: gettext 抽出 + .po update

- [x] `cd sphinx-docs && make install`（uv 依存セットアップ確認）
- [x] `make update-po` 実行（gettext → sphinx-intl update -l ja）
- [x] スコープ外の .po update を revert し、`plugin-{log,notification,os}.po` の 3 ファイルに限定

## Phase 2: 翻訳付与

- [x] `plugin-log.po`: 95 entries 全翻訳完了（0 fuzzy / 0 untranslated）。LogLevel.t variant / pattern match 例 / 旧セクション削除分を反映
- [x] `plugin-notification.po`: 86 entries 全翻訳完了（0 fuzzy / 0 untranslated）。Importance / Visibility variants / Default / Private 表記を反映
- [x] `plugin-os.po`: 87 entries 全翻訳完了（0 fuzzy / 0 untranslated）。OsType.get() submodule / 旧 osType_ の説明置換を反映

## Phase 3: 検証

- [x] `make build-ja` 実行 → `build succeeded, 1 warning` (warning は `plugin-os.md:71` の pre-existing `#sync-getters` cross-reference issue で .po とは無関係。本 steering 適用前にも同じ warning が出ることを確認)
- [x] `uv run sphinx-intl stat -l ja` で plugin-{log,notification,os} すべて `0 fuzzy, 0 untranslated`
- [x] 既存翻訳の意図しない上書きなし（既存セクションタイトル「インストール / Capability 設定 / 最小サンプル / 公開 API / レベル別関数 / 注意点 / 互換性 / 関連リンク」等の用語を踏襲）

## Phase 4: コミット

- [x] `.po` 3 ファイル更新を 1 コミット:
  - 📝 Refresh plugin-{log,notification,os} .po files after suffix removal

## Phase 5: マージ

- [x] tasklist 全 [x] にしてコミット
- [x] AskUserQuestion で main マージ可否を確認 (承認取得)
- [x] 承認後、main マージ → worktree 削除 → ブランチ削除 を一括実行 (worktree は uv の untracked `.venv` / `__pycache__` のため `--force` 削除)
- [x] クリーンアップ完了の検証 (`git worktree list` = main / `git branch --list 'worktree-*'` = 空 / `.claude/worktrees/` = 空)
