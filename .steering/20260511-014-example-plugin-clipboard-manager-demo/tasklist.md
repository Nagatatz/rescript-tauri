# Tasklist: examples/plugin-clipboard-manager-demo

| 項目 | 内容 |
|---|---|
| Steering 番号 | 20260511-014 |

---

## Phase 0: 準備

- [x] T0.1 main 鮮度確認 (29 commit unpushed)、`EnterWorktree plugin-clipboard-manager-demo`、worktree 内 `git merge main` で plugin-http-demo 含む並列作業を取り込み

## Phase 1: scaffolding

- [x] T1.1 `examples/plugin-clipboard-manager-demo/` 配下 9 ファイル + icons/ を `plugin-shell-demo` ベースで作成
- [x] T1.2 `pnpm install` 成功、初回 build で `writeTextOptions` の型参照エラー発見 → `PluginClipboardManager.writeTextOptions` に修正後 73 modules compiled green
- [x] T1.3 **コミット**: `✨ Add examples/plugin-clipboard-manager-demo (steering 20260511-014)` (d7de15b)

## Phase 2: root Cargo workspace 登録

- [x] T2.1 `Cargo.toml` members に追加（plugin-dialog-demo の前、アルファベット順）
- [x] T2.2 **コミット**: `🔧 Register plugin-clipboard-manager-demo in root Cargo workspace` (2e3930c)

## Phase 3: ドキュメント・CI・CHANGELOG

- [x] T3.1 `docs/repository-structure.md` §1 + §3 に追加
- [x] T3.2 `sphinx-docs/user/plugin-clipboard-manager.md` の "See also" に live demo リンク
- [x] T3.3 `packages/plugin-clipboard-manager/CHANGELOG.md` の `Added` に live example、`Deferred` セクション削除
- [x] T3.4 `.github/workflows/examples-build.yml` の plugin-http-demo step 直後に 2 step 追加
- [x] T3.5 **コミット**: `📝 Link plugin-clipboard-manager-demo from docs / CI / CHANGELOG` (261b615)

## Phase 4: 検証

- [x] T4.1 `git diff main..HEAD --name-only` で範囲確認
- [x] T4.2 build 再実行で green (73 modules compiled)

## Phase 5: マージ

- [x] T5.1 tasklist `[x]` 化
- [ ] T5.2 **コミット**: `📝 Mark steering 20260511-014 tasklist complete`
- [ ] T5.3 `AskUserQuestion` で main マージ可否確認
- [ ] T5.4 承認後、main 側の未追跡 .steering 削除 → `git merge --no-ff` → cleanup
