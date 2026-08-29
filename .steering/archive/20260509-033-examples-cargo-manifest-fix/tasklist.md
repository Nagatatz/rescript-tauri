# Tasklist: Examples Cargo Manifest Fix

| 項目 | 内容 |
|---|---|
| 作業 ID | 20260509-033-examples-cargo-manifest-fix |
| 関連 | [requirements.md](./requirements.md), [design.md](./design.md) |

## タスク

### Phase 1: 計画
- [x] requirements.md 作成
- [x] design.md 作成
- [x] tasklist.md 作成
- [x] worktree 作成（`worktree-examples-cargo-manifest-fix`）

### Phase 2: 実装
- [x] `examples/hello-world/src-tauri/Cargo.toml` から `[lib]` ブロック削除
- [x] `examples/window-management/src-tauri/Cargo.toml` から `[lib]` ブロック削除
- [x] `examples/ipc-typed/src-tauri/Cargo.toml` から `[lib]` ブロック削除
- [x] `examples/streaming-ipc/src-tauri/Cargo.toml` から `[lib]` ブロック削除

### Phase 3: 検証
- [x] `grep -A1 '^\[lib\]' examples/*/src-tauri/Cargo.toml` の出力が空であることを確認
- [x] cargo がローカルに存在する場合、`cargo check` 4 example すべて成功

### テスト省略の理由
本作業は Cargo manifest の構造修正で、Rust コードの挙動を変えない（`main.rs` は変更しない）。`cargo check` 自体が manifest 検証を兼ねるため、CI 上の `cargo check --release` が事実上の統合テスト。ユニットテストレベルの追加は不要。

### Phase 4: コミット・マージ
- [x] ステアリングファイル + Cargo.toml 変更をコミット（`🐛 Drop phantom [lib] from example src-tauri Cargo.toml files`）
- [x] tasklist.md の全タスクを `[x]` に更新
- [x] AskUserQuestion で main マージ可否を確認
- [x] worktree マージ・クリーンアップ手順に従い実行
- [x] ブランチ・worktree 削除
- [x] ユーザーに push を依頼
