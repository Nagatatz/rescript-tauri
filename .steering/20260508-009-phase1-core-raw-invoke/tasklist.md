# タスクリスト: Phase 1 着手 — pnpm workspace + packages/core スケルトン + Core.Raw.invoke

| 項目 | 内容 |
|---|---|
| 関連 | `requirements.md` / `design.md` |
| 作成日 | 2026-05-08 |

## Phase 0: 事前承認

- [x] requirements.md レビュー・承認
- [x] design.md レビュー・承認（特に §1 の派生決定 5 つ + §2 の各ファイル内容）
- [x] tasklist.md レビュー・承認

## Phase 1: ステアリング配置 + worktree 起動

- [x] **commit 1 (main)**: ステアリング 3 ファイルを main に配置 → コミット `📝 Add steering for 20260508-009 (phase1-core-raw-invoke)`
- [ ] `EnterWorktree` で `phase1-core-raw-invoke` worktree を作成

## Phase 2: 実装（worktree 内、コミットは順次）

### 2.1 ルートワークスペース

- [x] **commit 2**: `package.json` + `pnpm-workspace.yaml` + `pnpm install` で生成された `pnpm-lock.yaml` をまとめて → コミット `✨ Add pnpm workspace root for monorepo`（.gitignore 追記は既設の `*.log` `.pnpm-store/` 等で全カバー、追加不要）
- [x] 検証: `pnpm install` 完了（@types/node 22.19.18 install）

### 2.2 packages/core スケルトン

- [x] **commit 3**: `packages/core/{package.json, rescript.json, README.md, vitest.config.mjs}` + 空 `src/` `tests/runtime/` ディレクトリ + `pnpm-lock.yaml` 更新 → コミット `✨ Add packages/core scaffolding`（空ディレクトリは git が追跡しないが、後続 commit 4/5/6 で `.res` `.res.mjs` ファイルが入るため `.gitkeep` は不要）
- [x] 検証: `pnpm install` 完了（vitest / happy-dom / rescript 等 60+ パッケージ）、`pnpm --filter @rescript-tauri/core exec rescript --version` → `rescript 12.2.0`

### 2.3 Core.Raw.invoke 実装

- [x] **commit 4**: `packages/core/src/Core.res` + `packages/core/src/Core.resi`（design §2.5 / §2.6）+ `rescript.json` の ReScript 12 deprecation 警告 3 件解消（`bs-dependencies` → `dependencies`、`bs-dev-dependencies` → `dev-dependencies`、`version` フィールド削除）→ コミット `✨ Implement Core.Raw.invoke binding (+ adopt ReScript 12 rescript.json schema)`
- [x] 検証: clean rebuild で警告ゼロ + `Compiled 58 modules` + `packages/core/src/Core.res.mjs` 生成（458B）

### 2.4 型レベルテスト

- [x] **commit 5**: `packages/core/tests/core_raw_signature.res`（design §2.7）→ コミット `✅ Add type-level signature test for Core.Raw`
- [x] 検証: `pnpm --filter @rescript-tauri/core build` で 1 source / 1 module コンパイル成功（tests も `.gitignore`'d な `.res.mjs` を生成）

### 2.5 ランタイムテスト（vitest）

- [x] **commit 6**: `packages/core/tests/runtime/core_raw.test.mjs`（design §2.8）+ `@rescript/runtime ^12.2.0` を `packages/core/devDependencies` に追加（pnpm strict hoisting で `Core.res.mjs` の `import "@rescript/runtime/lib/es6/Primitive_option.js"` が解決できなかったため）→ コミット `✅ Add vitest runtime test for Core.Raw.invoke (+ explicit @rescript/runtime devDep)`
- [x] 検証: `pnpm --filter @rescript-tauri/core test` → `tests/runtime/core_raw.test.mjs (2 tests) 75ms` / `Test Files 1 passed (1) / Tests 2 passed (2)`

## Phase 3: 統合検証（worktree 内、コミット前）

- [ ] `pnpm --recursive build` 全 workspace ビルド成功
- [ ] `pnpm --recursive test` 全テスト pass
- [ ] `grep` で `Core.Raw.invoke` の `.resi` doc comment に Tauri 公式 URL (`v2.tauri.app/`) が含まれることを確認（PRD §7 KPI / functional-design §6 doc-link-lint 準拠）
- [ ] `node_modules/` / `lib/` / `pnpm-lock.yaml` 等の git status を確認し、`pnpm-lock.yaml` のみ追跡対象、他は ignore されていることを確認

## Phase 4: マージ準備

- [ ] **commit 7**: tasklist.md を全 `[x]` 化 + 適用結果（build / test 出力の要点）を本書末尾に記録 → コミット `📝 Mark steering 20260508-009 complete (verify build/test)`
- [ ] `AskUserQuestion` で main へのマージ可否を確認

## Phase 5: マージ・クリーンアップ

`.claude/rules/steering-workflow.md` の「worktree マージ・クリーンアップ手順」に従う:

- [ ] CWD をメインリポジトリに移動
- [ ] worktree のブランチを `--no-ff` で main にマージ
- [ ] worktree 削除 (`git worktree remove`)
- [ ] ブランチ削除 (`git branch -d`)
- [ ] クリーンアップ検証: `git worktree list` / `git branch --list 'worktree-*'` / `ls .claude/worktrees/`
- [ ] `git push origin main`

---

## 適用結果記録（commit 7 で更新）

### Build / Test 結果

```
pnpm --filter @rescript-tauri/core build:
<fill>

pnpm --filter @rescript-tauri/core test:
<fill>

pnpm-lock.yaml diff サマリ:
<fill>
```

### Generated artifacts

```
packages/core/src/Core.res.mjs: <size>
packages/core/lib/.../*.cmt: <count>
```
