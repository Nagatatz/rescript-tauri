# Tasklist: plugin-shell CHANGELOG cleanup

| 項目 | 内容 |
|---|---|
| Steering 番号 | 20260511-012 |

---

## Phase 0: 準備

- [x] T0.1 `git fetch origin && git log origin/main..main` で main 鮮度確認 (3 commit 進んでいた)
- [x] T0.2 `EnterWorktree changelog-plugin-shell-cleanup` で worktree 隔離
- [x] T0.3 worktree 内で `git merge main` 実行（steering 010 / 011 plan 含む未 push commit を取り込み）

## Phase 1: CHANGELOG 編集

- [x] T1.1 `packages/plugin-shell/CHANGELOG.md` の `peerDependencies:` 直前に live example 言及を追加（plugin-fs と同スタイル）
- [x] T1.2 `Deferred to follow-up sub-steerings` セクション (5 行) を削除
- [x] T1.3 検証: `grep 'Deferred'` が空、`grep 'examples/plugin-shell-demo'` が hit
- [x] T1.4 **コミット**: `📝 Mark plugin-shell example app as released in CHANGELOG` (14aaeae)

## Phase 2: マージ

- [x] T2.1 tasklist `[x]` 化
- [ ] T2.2 **コミット**: `📝 Mark steering 20260511-012 tasklist complete`
- [ ] T2.3 `AskUserQuestion` で main マージ可否確認
- [ ] T2.4 承認後、main 側の未追跡 `.steering/20260511-012-changelog-plugin-shell-cleanup/` を削除
- [ ] T2.5 `cd <main-repo>` → `git merge --no-ff` → worktree / branch 削除
- [ ] T2.6 クリーンアップ検証
