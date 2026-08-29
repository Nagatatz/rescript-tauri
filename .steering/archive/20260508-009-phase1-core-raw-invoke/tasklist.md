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

- [x] `pnpm --recursive build` 全 workspace ビルド成功（インクリメンタル、0 modules を compile = 既に最新）
- [x] `pnpm --recursive test` 全テスト pass（`Test Files 1 passed (1) / Tests 2 passed (2)` / Duration 3.48s）
- [x] `grep "v2.tauri.app" packages/core/src/Core.resi` → line 17 に `https://v2.tauri.app/develop/calling-rust/` 存在（PRD §7 KPI / functional-design §6 doc-link-lint 準拠）
- [x] `git status --short` → 出力空 = working tree clean（`node_modules/`, `lib/`, `**/*.res.mjs` は `.gitignore` で除外、`pnpm-lock.yaml` は追跡済み）

## Phase 4: マージ準備

- [x] **commit 7**: tasklist.md を全 `[x]` 化 + 適用結果（build / test 出力の要点）を本書末尾に記録 → コミット `📝 Mark steering 20260508-009 complete (verify build/test)`
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

## 適用結果記録

### Build / Test 結果

```
pnpm --filter @rescript-tauri/core build:
  Cleaned 0/83
  Parsed 1 source files (型テスト追加時) / 0 source files (incremental)
  Compiled 1 modules / 0 modules (no warnings, no errors)

pnpm --filter @rescript-tauri/core test:
  rescript build && vitest run
  ✓ tests/runtime/core_raw.test.mjs (2 tests) 75-83ms
  Test Files  1 passed (1)
  Tests       2 passed (2)
  Duration    3.00-3.48s

pnpm --recursive build / pnpm --recursive test:
  両方 OK (上記と同じ出力)
```

### Generated artifacts (git ignored)

```
packages/core/src/Core.res.mjs        458 B
packages/core/tests/core_raw_signature.res.mjs  (型テスト build 出力)
packages/core/lib/                     ReScript intermediate (cmt/cmi/etc)
node_modules/                          pnpm hoisted
```

### コミット履歴 (commits 1-7)

```
3e5f11e  📝 Add steering for 20260508-009 (phase1-core-raw-invoke)  [main 上]
8e1e6c4  ✨ Add pnpm workspace root for monorepo
676b68a  ✨ Add packages/core scaffolding
c2c853f  ✨ Implement Core.Raw.invoke binding (+ adopt ReScript 12 rescript.json schema)
a7dfad4  ✅ Add type-level signature test for Core.Raw
7679d12  ✅ Add vitest runtime test for Core.Raw.invoke (+ explicit @rescript/runtime devDep)
<this>   📝 Mark steering 20260508-009 complete (verify build/test)
```

### 設計時に予見していなかった発見

| # | 発見 | 対処 |
|---|---|---|
| 1 | `bs-dependencies` / `bs-dev-dependencies` / `version` フィールドは ReScript 12 で deprecated 警告（design.md §2.3 末尾の Note で「実装時に再確認」と flag していた） | commit 4 で rescript.json を `dependencies` / `dev-dependencies` 形式に切り替え、`version` 削除 |
| 2 | ビルド成果物 `Core.res.mjs` が untracked で `git status` を汚す | commit 4 で `.gitignore` に `**/*.res.mjs` 追加（npm publish には `package.json` の `files` allowlist で含まれる） |
| 3 | `Core.res.mjs` が `import "@rescript/runtime/lib/es6/Primitive_option.js"` を発するが、pnpm 10 strict hoisting で `node_modules/@rescript/runtime` が `@rescript-tauri/core` の解決スコープに入らない | commit 6 で `@rescript/runtime ^12.2.0` を `packages/core/devDependencies` に明示追加（peerDep 昇格は consumer からの報告待ち） |
