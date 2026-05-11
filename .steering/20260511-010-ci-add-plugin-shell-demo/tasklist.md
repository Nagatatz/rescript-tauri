# Tasklist: examples-build CI に plugin-shell-demo を登録

| 項目 | 内容 |
|---|---|
| Steering 番号 | 20260511-010 |

---

## Phase 0: 準備

- [x] T0.1 `git fetch origin && git log origin/main..main` で main 鮮度確認（1 commit 進んでいることを確認）
- [x] T0.2 `EnterWorktree ci-add-plugin-shell-demo` で worktree 隔離
- [x] T0.3 worktree 内で `git merge main` 実行（steering 009 plan 含む未 push commit を取り込み）

## Phase 1: workflow 編集

- [x] T1.1 `.github/workflows/examples-build.yml` の `Cargo check on plugin-fs-demo Rust side` 直後に plugin-shell-demo の 2 step を挿入
- [x] T1.2 PyYAML 不在のため module parse は不可。代替で `grep` により既存 plugin-fs-demo step と key 構造・インデント完全一致を確認
- [ ] T1.3 **コミット**: `🔧 Add plugin-shell-demo to examples-build CI matrix`

## Phase 2: マージ

- [ ] T2.1 tasklist `[x]` 化
- [ ] T2.2 **コミット**: `📝 Mark steering 20260511-010 tasklist complete`
- [ ] T2.3 `AskUserQuestion` で main マージ可否確認
- [ ] T2.4 承認後、main 側の未追跡 `.steering/20260511-010-ci-add-plugin-shell-demo/` を削除
- [ ] T2.5 `cd <main-repo>` → `git merge worktree-ci-add-plugin-shell-demo --no-ff` → worktree / branch 削除
- [ ] T2.6 クリーンアップ検証
