# Tasklist: Bulk Package Reservation & Trusted Publisher Setup Tooling

## Phase 0: 計画とセットアップ

- [x] requirements.md / design.md / tasklist.md を作成
- [x] `EnterWorktree` で worktree-bulk-package-reservation-tooling を作成
- [x] ステアリングファイル 3 点を初回コミット

## Phase 1: ヘルパースクリプト作成

- [x] T1: `tools/reserve-npm-packages.sh` を作成（9 パッケージ予約、core 除外）
- [x] T2: `tools/setup-trusted-publishers.sh` を作成（10 パッケージ trust 設定、`SKIP_CORE` 環境変数オプション付き）
- [x] T3: 両スクリプトに実行権限を付与 (`chmod +x`)
- [x] T4: `bash -n` 構文検証 OK / `shellcheck` も pass
- [x] T5: T1-T4 を 1 commit にまとめてコミット

## Phase 2: ドキュメント更新

- [ ] T6: `docs/repository-structure.md` §10 の `tools/` 表に 2 行追加
- [ ] T7: `.steering/20260508-007-npm-scope-reservation/report.md` §6 Step 6 を更新
- [ ] T8: T6-T7 を 1 commit にまとめてコミット

## Phase 3: 完了検証

- [ ] V1: `bash -n tools/reserve-npm-packages.sh` が pass
- [ ] V2: `bash -n tools/setup-trusted-publishers.sh` が pass
- [ ] V3: スクリプトが実行可能ファイルになっている (`ls -l` で `x` ビット確認)
- [ ] V4: tasklist.md を全 `[x]` に更新して最終コミット

## Phase 4: マージ・クリーンアップ

- [ ] M1: ユーザーに main へのマージ可否を確認
- [ ] M2: `ExitWorktree` で main repo に戻る
- [ ] M3: main にマージ（`git merge worktree-bulk-package-reservation-tooling --no-ff`）
- [ ] M4: worktree 削除 + ブランチ削除
- [ ] M5: クリーンアップ完了検証
