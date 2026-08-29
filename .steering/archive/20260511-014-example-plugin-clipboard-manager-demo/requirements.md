# Requirements: examples/plugin-clipboard-manager-demo

| 項目 | 内容 |
|---|---|
| Steering 番号 | 20260511-014 |
| 作業タイトル | examples/plugin-clipboard-manager-demo |
| 作成日 | 2026-05-11 |
| 関連 steering | 20260511-005 (user guide), 20260511-057 (本体実装), 20260511-008 (plugin-shell-demo 雛形) |

---

## 1. 背景

`@rescript-tauri/plugin-clipboard-manager` は本体実装・user guide・CHANGELOG・CI が完備済みだが、`examples/plugin-clipboard-manager-demo/` は未存在。リリース前に PRD §5.4 を満たすために demo を追加する。

## 2. 目的

clipboard-manager の全 6 関数を Tauri 2.x アプリ上で実行できる minimum-viable demo を提供する。

## 3. スコープ

### 3.1 含めるもの

`examples/plugin-clipboard-manager-demo/` の新規追加（`plugin-shell-demo` 雛形に準拠）:

| 関数 | demo ボタン |
|---|---|
| `writeText` | 固定文字列を書き込み |
| `readText` | 読み出して result pane に表示 |
| `writeImage` | 直前 `readImage` で取得した `Image.t` を round-trip 書き戻し |
| `readImage` | clipboard の画像を `Image.t` で取得、bytes 長を表示 |
| `writeHtml` | 固定 HTML を書き込み（`~altText` 付き） |
| `clear` | clipboard をクリア |

共有ファイル変更:
- `Cargo.toml` (root) members に登録
- `docs/repository-structure.md` の examples 一覧に追加
- `sphinx-docs/user/plugin-clipboard-manager.md` の "See also" に live demo リンク追加
- `packages/plugin-clipboard-manager/CHANGELOG.md` の `Added` に live example app 行追加（`Deferred` セクションがある場合は更新／削除）
- `.github/workflows/examples-build.yml` に 2 step 追加

### 3.2 含めないもの

- 他 plugin の demo
- npm publish 実行
- 翻訳 .po 更新

## 4. 受け入れ基準

- [ ] `examples/plugin-clipboard-manager-demo/` が plugin-shell-demo と同じファイル構成
- [ ] 全 6 関数への呼び出しが `src/App.res` に存在
- [ ] `capabilities/default.json` に `clipboard-manager:default` 含む permission set
- [ ] root `Cargo.toml` に登録
- [ ] `pnpm --filter plugin-clipboard-manager-demo build` 成功
- [ ] CI / docs / CHANGELOG / user guide の cross-link が確立
- [ ] tasklist 全タスク `[x]` で main merge 完了
