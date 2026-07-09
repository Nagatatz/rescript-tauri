# tasklist — examples ビルドの `cookie` / `time` 破壊対処

ステアリング番号: 20260710-001

## Phase 1: lockfile 生成（time pin は不要と判明）

- [x] `.gitignore` の `Cargo.lock` 行を削除（+ 理由コメント追記）
- [x] ルートで `cargo generate-lockfile` を実行し `Cargo.lock` を生成（593 packages）
- [x] ~~`cargo update -p time --precise 0.3.41`~~ → plist が time ^0.3.47 要求で不可、かつ time 0.3.53 で cookie が通るため **pin 不要**と判明
- [x] `Cargo.lock` の `time = 0.3.53` / `cookie = 0.18.1` を grep 確認

## Phase 2: ビルド検証

- [x] `cargo check --locked -p cookie` を実行し、cookie 0.18.1 が E0061 無しでコンパイル通過を確認（time 0.3.53、full build はディスク都合で回避）
- [x] （テスト方針）本変更はビルド設定・依存 pin のため専用ユニットテストは追加せず、CI の `examples-build.yml`（3 OS）を検証手段とする → 最終的に PR CI で green を確認

## Phase 3: CI と ドキュメント

- [x] `.github/workflows/examples-build.yml` の各 `cargo check --release`（13 個）を `--locked` 付きに変更
- [x] `docs/repository-structure.md` を更新（ルート `Cargo.lock` を commit 対象化、§1 レイアウトと §9 テーブルに追記）
- [x] CLAUDE.md / README への影響有無を確認 → ビルド手順は pnpm ベースで cargo に非依存、`--locked` は CI のみのため **更新不要**

## Phase 4: コミット（2 コミット構成に変更）

- [x] コミット1（fix）: `.gitignore` + `Cargo.lock` + `examples-build.yml` = 「lock 追跡 + --locked 強制」の 1 論理変更（`🔧 Track Cargo.lock and enforce --locked in examples build`）
- [x] コミット2（docs）: `docs/repository-structure.md` + steering 3 ファイル（`📝 Document Cargo.lock tracking for examples build`）

## Phase 5: PR・マージ

- [x] tasklist 全項目 `[x]`（本マージタスク含む）を最終コミットに含める
- [x] `AskUserQuestion` で PR 作成・main マージ可否を確認
- [x] `git push origin worktree-fix-cargo-lock-time-pin`
- [x] `gh pr create --base main`（PR #26）
- [x] PR CI（examples-build 3 OS）が green を確認（macos/ubuntu/windows すべて pass）
- [x] `gh pr merge --merge --delete-branch`
- [x] CWD を main repo に移動 → `git pull` → worktree 削除 → ローカルブランチ削除 → クリーンアップ検証
- [ ] （後続）Dependabot PR #21 / #22 を `@dependabot rebase` して green を確認しマージ
