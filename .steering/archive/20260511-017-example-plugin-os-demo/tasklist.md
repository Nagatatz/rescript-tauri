# Tasklist: examples/plugin-os-demo

| 項目 | 内容 |
|---|---|
| Steering 番号 | 20260511-017 |

---

## Phase 0: 準備

- [x] T0.1 main 鮮度確認、`EnterWorktree plugin-os-demo`、worktree 内 `git merge main`

## Phase 1: scaffolding

- [x] T1.1 9 ファイル + icons/ を作成
- [x] T1.2 build 成功確認 (73 modules)
- [x] T1.3 **コミット**: `✨ Add examples/plugin-os-demo (steering 20260511-017)` (7ec2424)

## Phase 2: root Cargo workspace 登録

- [x] T2.1 `Cargo.toml` members に追加 (plugin-notification-demo の隣)
- [x] T2.2 **コミット**: `🔧 Register plugin-os-demo in root Cargo workspace` (8ceccf2)

## Phase 3: ドキュメント・CI・CHANGELOG

- [x] T3.1 `docs/repository-structure.md` §1 + §2.x 記述 + §3 一覧
- [x] T3.2 `sphinx-docs/user/plugin-os.md` "See also" に live demo
- [x] T3.3 `packages/plugin-os/CHANGELOG.md` `Added` 追加、`Deferred` 削除
- [x] T3.4 `.github/workflows/examples-build.yml` に 2 step
- [x] T3.5 **コミット**: `📝 Link plugin-os-demo from docs / CI / CHANGELOG` (e489d54)

## Phase 4: マージ

- [x] T4.1 tasklist `[x]` 化
- [ ] T4.2 **コミット**: `📝 Mark steering 20260511-017 tasklist complete`
- [ ] T4.3 `AskUserQuestion` で main マージ可否確認
- [ ] T4.4 承認後 cleanup
