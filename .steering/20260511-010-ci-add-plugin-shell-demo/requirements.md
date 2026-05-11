# Requirements: examples-build CI に plugin-shell-demo を登録

| 項目 | 内容 |
|---|---|
| Steering 番号 | 20260511-010 |
| 作業タイトル | examples-build CI に plugin-shell-demo を登録 |
| 作成日 | 2026-05-11 |
| 関連 steering | 20260511-008 (examples/plugin-shell-demo 追加) |

---

## 1. 背景

steering 008 で `examples/plugin-shell-demo/` が追加されたが、`.github/workflows/examples-build.yml` には対応する build step が登録されていない。同 workflow は 7 example (`hello-world` / `window-management` / `ipc-typed` / `streaming-ipc` / `plugin-dialog-demo` / `plugin-fs-demo` / `ipc-typed-with-schema`) を **直書きで** matrix 化しているため、新規 example は手動で追加する必要がある。

## 2. 目的

PRD §5.4「CI ビルド可能な使用例」要件を満たすため、`examples-build.yml` に plugin-shell-demo の frontend build + Rust cargo check の 2 step を追加する。

## 3. スコープ

### 3.1 含めるもの

- `.github/workflows/examples-build.yml` への 2 step 追加:
  - `Build plugin-shell-demo frontend` (= `pnpm --filter plugin-shell-demo build`)
  - `Cargo check on plugin-shell-demo Rust side` (= `cargo check --release` in `examples/plugin-shell-demo/src-tauri`)
- 挿入位置: `Cargo check on plugin-fs-demo Rust side` の直後（既存配列順序: dialog → fs → ipc-typed-with-schema の間）

### 3.2 含めないもの

- 他 example の追加（plugin-http-demo は steering 009 で別途登録予定）
- workflow 全体の matrix 化リファクタ
- `paths:` trigger の調整（`examples/**` で既にカバー）

## 4. 受け入れ基準

- [ ] `.github/workflows/examples-build.yml` に plugin-shell-demo の 2 step が登録されている
- [ ] step 名・コマンドは既存 7 example と同一 pattern
- [ ] YAML 構文として valid（CI が起動できる）
- [ ] tasklist 全タスク `[x]` で main マージ完了

## 5. リスク

- **並列衝突**: steering 009 (plugin-http-demo) が同 workflow を編集する可能性 → worktree マージ前に必ず最新 main を取り込み、conflict 解消する
- **CI 失敗**: ローカル `cargo` 不在のため、実 build 検証は CI に委ねる。失敗した場合は別 steering でフォローアップ
