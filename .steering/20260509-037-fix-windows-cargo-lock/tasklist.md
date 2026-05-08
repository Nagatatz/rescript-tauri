# Tasklist: Fix Windows Cargo Lock

| 項目 | 内容 |
|---|---|
| 作業 ID | 20260509-037-fix-windows-cargo-lock |
| 関連 | [requirements.md](./requirements.md), [design.md](./design.md) |

## タスク

### Phase 1: 計画
- [x] requirements.md 作成
- [x] design.md 作成
- [x] tasklist.md 作成

### Phase 2: 実装
- [x] ルート `Cargo.toml` 作成（workspace 定義）
- [x] `.gitignore` 更新（ルート `target` と `Cargo.lock` 追加）

### Phase 3: 検証
- [ ] `cargo check` がルートから実行可能か確認（環境にあれば）
- [ ] `tauri.conf.json` の `frontendDist` が root `target` を含まないことをパス計算で確認

### Phase 4: コミット・マージ
- [ ] ブランチ作成 (`fix/windows-cargo-locking`)
- [ ] コミット (`🐛 Resolve Windows file locking conflict by using a Cargo workspace`)
- [ ] main へのマージ
- [ ] ブランチ削除
