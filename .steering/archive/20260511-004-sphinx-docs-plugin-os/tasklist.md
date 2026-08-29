# Tasklist: sphinx-docs `user/plugin-os.md` 追加

## Phase 0: 計画

- [x] requirements.md 作成
- [x] design.md 作成
- [x] tasklist.md 作成

## Phase 1: ステアリングコミット (main)

- [x] main 上で `.steering/20260511-004-sphinx-docs-plugin-os/` を一括コミット
  - commit msg: `📝 Add steering 20260511-004 (sphinx-docs plugin-os user guide)`

## Phase 2: worktree 作成

- [x] `git log --oneline origin/main..HEAD` で未 push commit を確認（steering commit 1 件が出ること）
- [x] `git worktree add -b worktree-plugin-os-userguide .claude/worktrees/plugin-os-userguide HEAD` で steering commit を含む HEAD ベースで作成
- [x] `EnterWorktree path=.claude/worktrees/plugin-os-userguide` で session 切替

## Phase 3: 実装（worktree 内 / 4 independent checkpoints）

### 3.1 Checkpoint i — Install + Capabilities

- [x] `sphinx-docs/user/plugin-os.md` を新規作成し、以下まで書き込む:
  - タイトル + リード文（upstream `https://v2.tauri.app/plugin/os-info/`）
  - `{note}` ブロック (publish status)
  - Install 節 (`pnpm add`, peerDependencies, `rescript.json`, Rust 側 `tauri::Builder::default().plugin(tauri_plugin_os::init())`)
  - Capabilities 節 (`os:default`)
- [x] commit msg: `📝 Add plugin-os user guide: install and capabilities`

### 3.2 Checkpoint ii — Sync getters (7 関数)

- [x] Sync getters 節を追加:
  - 各 sync getter のコード例（`eol` / `platform` / `version` / `family` / `osType_` / `arch` / `exeExtension`）
  - 関数一覧表
  - 「`window.__TAURI_OS_PLUGIN_INTERNALS__` を直接読むため `Mocks.mockIPC` ではテスト不能」の旨を冒頭に注記
- [x] commit msg: `📝 Add plugin-os user guide: sync getters reference`

### 3.3 Checkpoint iii — Async getters (2 関数 + permission flow)

- [x] Async getters 節を追加:
  - `locale` / `hostname` のコード例
  - `promise<Nullable.t<string>>` と `Nullable.toOption` パターン
  - IPC 経由 (`plugin:os|locale` / `plugin:os|hostname`) であることの説明
  - capability `os:default` の関連性
- [x] commit msg: `📝 Add plugin-os user guide: async getters and capability flow`

### 3.4 Checkpoint iv — Polymorphic variants + pattern match + Pitfalls

- [x] Polymorphic variants 節を追加:
  - 4 variant の網羅表（`platform` 10 / `osType` 5 / `arch` 11 / `family` 2）
  - `platform()` を pattern match する OS 分岐サンプル
  - ReScript コンパイラの exhaustive check への 1 行コメント
- [x] Pitfalls 節を追加:
  - `type()` → `osType_()` リネーム理由
  - sync getters が IPC を通らないこと（テスト時 stub 対象）
  - `#x86_64` などタグの取り扱い
- [x] Compatibility 節 + See also 節
- [x] commit msg: `📝 Add plugin-os user guide: variants, pattern match, troubleshooting`

### 3.5 index.md 更新

- [x] `sphinx-docs/user/index.md` の Phase 2 packages テーブルに `plugin-os` 行を追加
- [x] `toctree` directive に `plugin-os` を追加
- [x] パッケージ数を最新マージ状況に合わせて更新（"five add-on packages"）
- [x] commit msg: `📝 Include plugin-os in sphinx user index`

### 3.6 installation.md 更新

- [x] cross-ref 行 (line 72 周辺) に `[plugin-os](plugin-os.md)` を追加 (併せて plugin-notification も）
- [x] follow-up 注記 (line 76-84) から `@rescript-tauri/plugin-os` の言及を削除（plugin-notification も併せて削除）
- [x] commit msg: `📝 Cross-link plugin-os user guide from installation`

## Phase 4: 自己検証

- [x] `grep -E '^let (eol|platform|version|family|osType_|arch|exeExtension|locale|hostname):' packages/plugin-os/src/PluginOs.resi` で 9 関数すべてが存在することを確認
- [x] `grep -E '^type (platform|osType|arch|family)' packages/plugin-os/src/PluginOs.resi` で 4 polymorphic variant すべてが存在することを確認
- [x] `grep -c 'plugin-os' sphinx-docs/user/index.md` で 2 件以上（テーブル + toctree）を確認
- [x] `grep -n 'plugin-os' sphinx-docs/user/installation.md` で cross-ref 行に追加され、follow-up 注記から削除されていることを目視確認
- [x] `grep -n 'plugin-os-demo' sphinx-docs/user/plugin-os.md` が空であることを確認

## Phase 5: マージ準備（worktree 内）

- [x] このタスクリスト自体を更新（Phase 1〜4 の全タスクを `[x]` に）
- [x] Phase 6 のマージタスク `[x]` 更新を含めた最終コミット
  - commit msg: `✅ Mark steering 20260511-004 tasklist complete`

## Phase 6: マージ（main へ）

- [x] CWD をメインリポジトリに移動 (`cd /Users/ngtz/Documents/repos/rescript-tauri`)
- [x] 並列セッションとの衝突確認: `git fetch origin && git log --oneline HEAD..origin/main`
- [x] AskUserQuestion でマージ可否確認
- [x] `git merge worktree-plugin-os-userguide --no-ff -m "Merge branch 'worktree-plugin-os-userguide' (steering 20260511-004: sphinx-docs plugin-os user guide)"`

## Phase 7: クリーンアップ

- [x] `git worktree remove .claude/worktrees/plugin-os-userguide`
- [x] `git branch -d worktree-plugin-os-userguide`
- [x] 検証:
  - `git worktree list` で main + 並列分のみ表示（plugin-os-userguide が削除されていること）
  - `git branch --list 'worktree-*'` から plugin-os-userguide が消えていること
  - `.claude/worktrees/` 配下に `plugin-os-userguide` ディレクトリが残っていない

## Phase 8: 完了報告

- [x] ユーザーに完了報告（追加ファイル / 編集ファイル / 後続 sub-steering 案件の整理）

## Non-goals（再掲）

- 日本語 `.po` 生成 (`sphinx-docs/locale/ja/LC_MESSAGES/user/plugin-os.po`)
- `examples/plugin-os-demo/` の追加
- `packages/plugin-os` 本体の API 変更
