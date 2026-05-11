# Tasklist: sphinx-docs/user/plugin-http.md

| 項目 | 内容 |
|---|---|
| ステアリング番号 | 20260511-007 |
| 関連 | requirements.md / design.md |

## Phase 1: 計画

- [x] requirements.md 作成
- [x] design.md 作成
- [x] tasklist.md 作成
- [ ] ユーザー承認
- [ ] steering 3 点セットを main 上で `📝 Add steering 20260511-007 plan: sphinx-docs plugin-http user guide` で commit
- [ ] EnterWorktree（`git worktree add HEAD` 経由で head ref を取り込み、main の最新 44+ ahead を反映）

## Phase 2: 実装

各 checkpoint は単独で commit 可能。順序は固定。

### Checkpoint 1: 骨格 + Install + Capabilities + Minimal example

- [ ] `sphinx-docs/user/plugin-http.md` 新規作成
  - Title + intro 段落 + `{note}` ステータスブロック
  - `## Install` セクション（JS pnpm add / peerDeps / rescript.json deps / Rust Cargo.toml / Rust Builder + capability への前振り）
  - `## Capabilities` セクション（`http:default` + scoped allow JSON）
  - `## Minimal example` セクション（polymorphic `'response` 型注釈 + Obj.magic で `.json()` アクセスの最小コード）
- [ ] `pnpm run check` — md 対象外なので影響なし
- [ ] commit: `📝 Add sphinx-docs/user/plugin-http.md skeleton (install + capabilities + minimal example)`

### Checkpoint 2: Public API リファレンス

- [ ] `## Public API` セクション追加
  - 1 関数 + 5 型の表
  - `### fetch signature` サブセクション + polymorphic `'input` / `'init` / `'response` の解説
  - `### clientOptions fields` サブセクション + 4 フィールド表
  - `### proxy / proxyConfig / basicAuth` サブセクション + URL only / 完全 config の 2 パターンコード例
  - `### dangerousSettings` サブセクション + 用途と warning
- [ ] `pnpm run check` 警告なし（md 対象外）
- [ ] commit: `📝 Document plugin-http public API in sphinx-docs user guide`

### Checkpoint 3: Pitfalls + Compatibility + See also

- [ ] `## Pitfalls` セクション
  - `### DOM Web Fetch types are intentionally unbound` (3 種の対応パターン: 型注釈 / Obj.magic / inline object type)
  - `### proxy<'proxyValue> takes a single type parameter` (HTTPS だけ proxyConfig で HTTP は string の mixed が型エラーになる件)
  - `### dangerousSettings ships disabled` (default secure を強調)
- [ ] `## Compatibility` 表
- [ ] `## See also` リスト（source / package README / upstream / upstream JS reference、demo は CHANGELOG の deferred 通りリンクしない）
- [ ] `pnpm run check` 警告なし（md 対象外）
- [ ] commit: `📝 Add plugin-http pitfalls, compatibility and see-also sections`

### Checkpoint 4: 周辺ドキュメント更新

- [ ] `sphinx-docs/user/index.md` の "Phase 2 packages" ヘッダ: "eight" → "nine"
- [ ] `sphinx-docs/user/index.md` の Phase 2 packages 表に plugin-http 行を clipboard-manager の後 / schema の前に追加
- [ ] `sphinx-docs/user/index.md` toctree に `plugin-http` を追加（順序: `plugin-clipboard-manager` の後、`schema` の前）
- [ ] `sphinx-docs/user/installation.md` の "See the ... guides" cross-ref に plugin-http を schema の直前に追加
- [ ] `sphinx-docs/user/installation.md` の follow-up note を **全削除**（plugin-http が最後の対象だったため）
- [ ] `pnpm run check` 警告なし
- [ ] `grep -n "plugin-http" sphinx-docs/user/installation.md sphinx-docs/user/index.md` で cross-ref 確認、follow-up note の `{note}` ブロックが存在しないことを `grep -n "follow-up" sphinx-docs/user/installation.md` で確認
- [ ] commit: `📝 Cross-link plugin-http user guide and clear installation follow-up note`

## Phase 3: マージ前検証

- [ ] `pnpm --recursive --workspace-concurrency=1 build` 成功（doc-only だが念のため）
- [ ] `pnpm run check` 全件パス
- [ ] `grep -rn "plugin-http" sphinx-docs/user/` で意図した箇所すべてに反映されていること
- [ ] `grep -n "follow-up" sphinx-docs/user/installation.md` で出力が空であること（note 削除確認）
- [ ] tasklist.md の全タスク `[x]` 化
- [ ] commit: `✅ Mark steering 20260511-007 tasklist complete`

## Phase 4: マージ

- [ ] `AskUserQuestion` で main へのマージ可否確認
- [ ] 承認後、CWD を main へ移動
- [ ] 並列セッションによる main 更新を取り込み: `git fetch origin && git merge origin/main`（conflict は `installation.md` / `index.md` で手動解消）
- [ ] `git merge worktree-plugin-http-userguide --no-ff -m "Merge branch 'worktree-plugin-http-userguide' (steering 20260511-007: sphinx-docs plugin-http user guide)"`
- [ ] worktree remove: `git worktree remove .claude/worktrees/plugin-http-userguide`
- [ ] branch delete: `git branch -d worktree-plugin-http-userguide`
- [ ] 検証:
  - `git worktree list` で main + 他並列 worktree のみ
  - `git branch --list 'worktree-*'` で `worktree-plugin-http-userguide` が削除されている
  - `.claude/worktrees/plugin-http-userguide/` が存在しない

## ロールバック条件

- 各 checkpoint commit 後、`pnpm run check` 失敗 → 直前コミットを `git revert`
- マージ時 conflict 解決が困難 → ユーザーに相談して manual resolution
- 並列セッションが index.md / installation.md を大幅に変更した場合 → 個別に再 resolve
