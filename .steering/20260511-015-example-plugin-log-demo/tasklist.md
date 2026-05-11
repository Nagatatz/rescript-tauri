# Tasklist: examples/plugin-log-demo

| 項目 | 内容 |
|---|---|
| Steering 番号 | 20260511-015 |

---

## Phase 0: 準備

- [x] T0.1 main 鮮度確認、`EnterWorktree plugin-log-demo`、worktree 内 `git merge main`

## Phase 1: scaffolding

- [x] T1.1 9 ファイル + icons/ を `plugin-shell-demo` ベースで作成
- [x] T1.2 `pnpm install` + build 成功確認 (73 modules)
- [x] T1.3 **コミット**: `✨ Add examples/plugin-log-demo (steering 20260511-015)` (329695e)

## Phase 2: root Cargo workspace 登録

- [x] T2.1 `Cargo.toml` members に追加 (plugin-http-demo の隣)
- [x] T2.2 **コミット**: `🔧 Register plugin-log-demo in root Cargo workspace` (ded68c2)

## Phase 3: ドキュメント・CI・CHANGELOG

- [x] T3.1 `docs/repository-structure.md` §1 + §3 に追加
- [x] T3.2 `sphinx-docs/user/plugin-log.md` "See also" に live demo
- [x] T3.3 `packages/plugin-log/CHANGELOG.md` `Added` に追加、`Deferred` 削除
- [x] T3.4 `.github/workflows/examples-build.yml` に 2 step 追加 (plugin-clipboard-manager-demo の隣)
- [x] T3.5 **コミット**: `📝 Link plugin-log-demo from docs / CI / CHANGELOG` (7902aac)

## Phase 4: マージ

- [x] T4.1 tasklist `[x]` 化
- [ ] T4.2 **コミット**: `📝 Mark steering 20260511-015 tasklist complete`
- [ ] T4.3 `AskUserQuestion` で main マージ可否確認
- [ ] T4.4 承認後 cleanup
