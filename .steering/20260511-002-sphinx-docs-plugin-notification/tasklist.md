# Tasklist: sphinx-docs `user/plugin-notification.md` 追加

## Phase 0: 計画

- [x] requirements.md 作成
- [x] design.md 作成
- [x] tasklist.md 作成

## Phase 1: ステアリングコミット

- [ ] main ブランチ上で `.steering/20260511-002-sphinx-docs-plugin-notification/` を一括コミット
  - commit msg: `📝 Add steering 20260511-002 (sphinx-docs plugin-notification user guide)`

## Phase 2: worktree 作成

- [ ] `git fetch origin && git log --oneline origin/main..HEAD` で main の鮮度を確認（出力空 = origin と同期済み）
- [ ] `EnterWorktree` で `plugin-notification-userguide` worktree を作成

## Phase 3: 実装（worktree 内）

各タスクは単独で commit 可能な checkpoint。

- [ ] **3.1** `sphinx-docs/user/plugin-notification.md` を新規作成
  - design.md §2 のセクション順に従う（リード / note / Install / Capabilities / Permission flow / Minimal example / Public API / Schedule helpers / Pitfalls / Compatibility / See also）
  - upstream リンクは `https://v2.tauri.app/plugin/notification/` および `https://v2.tauri.app/reference/javascript/notification/#<symbol>` の形
  - `examples/plugin-notification-demo` への言及なし
  - commit msg: `📝 Add sphinx-docs plugin-notification user guide`

- [ ] **3.2** `sphinx-docs/user/index.md` に plugin-notification を追加
  - Phase 2 packages テーブルに 1 行追加（`plugin-dialog` の直後 / `schema` の前）
  - `toctree` directive に `plugin-notification` を追加（同じ並び順）
  - main に plugin-shell が先にマージされていれば、その直後 / `schema` の前に配置
  - commit msg: `📝 Include plugin-notification in sphinx user index`

## Phase 4: 自己検証

- [ ] 文中で言及する API シンボル（`isPermissionGranted` / `requestPermission` / `sendNotification` / `sendNotificationText` / `registerActionTypes` / `pending` / `cancel` / `cancelAll` / `active` / `removeActive` / `removeAllActive` / `createChannel` / `removeChannel` / `channels` / `onNotificationReceived` / `onAction` / `Schedule.at` / `Schedule.interval` / `Schedule.every` / `Importance.{none,min,low,default_,high}` / `Visibility.{secret,private_,public_}`）が `packages/plugin-notification/src/PluginNotification.resi` に実在することを grep で検証
- [ ] `sphinx-docs/user/index.md` の Phase 2 packages テーブルと toctree の両方に `plugin-notification` が含まれていることを目視確認
- [ ] `examples/plugin-notification-demo` への言及が無いことを `grep -n 'plugin-notification-demo' sphinx-docs/user/plugin-notification.md` で確認（出力空であること）

## Phase 5: マージ準備（worktree 内）

- [ ] このタスクリスト自体を更新（Phase 1〜4 の全タスクを `[x]` に）
- [ ] Phase 6 のマージタスク `[x]` 更新を含めた最終コミット
  - commit msg: `📝 Mark steering 20260511-002 tasklist complete`

## Phase 6: マージ（main へ）

- [ ] CWD をメインリポジトリに移動 (`cd /Users/ngtz/Documents/repos/rescript-tauri`)
- [ ] 並列セッションとの衝突確認: `git fetch origin && git log --oneline HEAD..origin/main`（出力なし or マージ可能な差分のみであること）
- [ ] `git merge worktree-plugin-notification-userguide --no-ff -m "Merge branch 'worktree-plugin-notification-userguide' (steering 20260511-002)"`
- [ ] AskUserQuestion でマージ可否確認した上で実行

## Phase 7: クリーンアップ

- [ ] `git worktree remove .claude/worktrees/plugin-notification-userguide`（または `git worktree prune`）
- [ ] `git branch -d worktree-plugin-notification-userguide`
- [ ] 検証:
  - `git worktree list` で main のみ表示
  - `git branch --list 'worktree-*'` 出力が空
  - `.claude/worktrees/` 配下に `plugin-notification-userguide` ディレクトリが残っていない

## Phase 8: 完了報告

- [ ] ユーザーに完了報告（追加ファイル / 編集ファイル / .po は後続 sub-steering である旨）

## Non-goals（再掲・本ステアリングでは扱わない）

- 日本語 `.po` 生成（`sphinx-docs/locale/ja/LC_MESSAGES/user/plugin-notification.po`）
- `examples/plugin-notification-demo/` の追加
- `packages/plugin-notification` 本体の API 変更
