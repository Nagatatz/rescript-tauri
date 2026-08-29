# Tasklist: examples/plugin-notification-demo

| 項目 | 内容 |
|---|---|
| Steering 番号 | 20260511-016 |

---

## Phase 0: 準備

- [x] T0.1 main 鮮度確認、`EnterWorktree plugin-notification-demo`、worktree 内 `git merge main` (f5280c3)

## Phase 1: scaffolding

- [x] T1.1 9 ファイル + icons/ を作成
- [x] T1.2 build 成功確認 (73 modules)
- [x] T1.3 **コミット**: `✨ Add examples/plugin-notification-demo (steering 20260511-016)` (60d3f5d)

## Phase 2: root Cargo workspace 登録

- [x] T2.1 `Cargo.toml` members に追加 (plugin-log-demo の隣)
- [x] T2.2 **コミット**: `🔧 Register plugin-notification-demo in root Cargo workspace` (6fdc6e9)

## Phase 3: ドキュメント・CI・CHANGELOG

- [x] T3.1 `docs/repository-structure.md` §1 + §2.3 plugin-notification 記述 + §3 一覧
- [x] T3.2 `sphinx-docs/user/plugin-notification.md` "See also" に live demo
- [x] T3.3 `packages/plugin-notification/CHANGELOG.md` `Added` 追加、`Deferred` 削除
- [x] T3.4 `.github/workflows/examples-build.yml` に 2 step (plugin-log-demo の隣)
- [x] T3.5 **コミット**: `📝 Link plugin-notification-demo from docs / CI / CHANGELOG` (31eff1f)

## Phase 4: マージ

- [x] T4.1 tasklist `[x]` 化
- [ ] T4.2 **コミット**: `📝 Mark steering 20260511-016 tasklist complete`
- [ ] T4.3 `AskUserQuestion` で main マージ可否確認
- [ ] T4.4 承認後 cleanup
