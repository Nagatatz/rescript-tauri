# Tasklist: plugin-{log,notification,os} 翻訳 .po refresh

## Phase 0: 準備

- [ ] `EnterWorktree` で worktree `po-refresh-suffix-removal` を作成
- [ ] ローカル main を merge して steering 022 を取り込み
- [ ] ディスク空き確認（uv install 用に最低 500MB）

## Phase 1: gettext 抽出 + .po update

- [ ] `cd sphinx-docs && make install`（uv 依存セットアップ確認）
- [ ] `make update-po` 実行（gettext → sphinx-intl update -l ja）
- [ ] `git diff sphinx-docs/locale/ja/LC_MESSAGES/user/plugin-{log,notification,os}.po` で変更内容を確認

## Phase 2: 翻訳付与

- [ ] `plugin-log.po`: fuzzy / untranslated を解消（LogLevel.t variant / attachLogger 内コード / 旧セクション削除分）
- [ ] `plugin-notification.po`: fuzzy / untranslated を解消（Importance / Visibility variants / Default / Private 表記）
- [ ] `plugin-os.po`: fuzzy / untranslated を解消（OsType.get() / 旧 osType_ 表記）

## Phase 3: 検証

- [ ] `make build-ja` 実行、warnings: 0 を確認
- [ ] `uv run sphinx-intl stat -l ja` で plugin-{log,notification,os} に untranslated が残らないこと
- [ ] 既存翻訳の意図しない上書きが無いこと（git diff レビュー）

## Phase 4: コミット

- [ ] `.po` 3 ファイル更新を 1 コミット:
  - 📝 Refresh plugin-{log,notification,os} .po files after suffix removal

## Phase 5: マージ

- [ ] tasklist 全 [x] にしてコミット
- [ ] AskUserQuestion で main マージ可否を確認
- [ ] 承認後、main マージ → worktree 削除 → ブランチ削除 を一括実行
- [ ] クリーンアップ完了の検証
