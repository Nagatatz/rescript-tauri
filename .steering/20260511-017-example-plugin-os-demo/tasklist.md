# Tasklist: examples/plugin-os-demo

| 項目 | 内容 |
|---|---|
| Steering 番号 | 20260511-017 |

---

## Phase 0: 準備

- [ ] T0.1 main 鮮度確認、`EnterWorktree plugin-os-demo`、worktree 内 `git merge main`

## Phase 1: scaffolding

- [ ] T1.1 9 ファイル + icons/ を作成
- [ ] T1.2 build 成功確認
- [ ] T1.3 **コミット**: `✨ Add examples/plugin-os-demo (steering 20260511-017)`

## Phase 2: root Cargo workspace 登録

- [ ] T2.1 `Cargo.toml` members に追加
- [ ] T2.2 **コミット**: `🔧 Register plugin-os-demo in root Cargo workspace`

## Phase 3: ドキュメント・CI・CHANGELOG

- [ ] T3.1 `docs/repository-structure.md` §1 + §3
- [ ] T3.2 `sphinx-docs/user/plugin-os.md` "See also" に live demo
- [ ] T3.3 `packages/plugin-os/CHANGELOG.md`
- [ ] T3.4 `.github/workflows/examples-build.yml` に 2 step
- [ ] T3.5 **コミット**: `📝 Link plugin-os-demo from docs / CI / CHANGELOG`

## Phase 4: マージ

- [ ] T4.1 tasklist `[x]` 化
- [ ] T4.2 **コミット**: `📝 Mark steering 20260511-017 tasklist complete`
- [ ] T4.3 `AskUserQuestion` で main マージ可否確認
- [ ] T4.4 承認後 cleanup
