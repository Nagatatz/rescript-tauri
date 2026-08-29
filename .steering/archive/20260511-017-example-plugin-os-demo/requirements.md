# Requirements: examples/plugin-os-demo

| 項目 | 内容 |
|---|---|
| Steering 番号 | 20260511-017 |
| 作業タイトル | examples/plugin-os-demo |
| 作成日 | 2026-05-11 |
| 関連 steering | 004 (user guide), 056 (本体実装) |

---

## 1. 背景

`@rescript-tauri/plugin-os` は本体実装・user guide・CHANGELOG・CI 完備、`examples/plugin-os-demo/` のみ未存在。残り 4 つの plugin demo の最後。

## 2. 目的

plugin-os の全公開 API を Tauri 2.x デスクトップアプリ上から呼び出せる demo を提供する。

## 3. スコープ

### 3.1 含めるもの

3 ボタン構成（API がシンプルなため）:

| ボタン | 関数 |
|---|---|
| **Show all OS info (sync)** | `eol` / `platform` / `version` / `family` / `osType_` / `arch` / `exeExtension` の 7 sync getters をすべて呼び出して result pane に表示 |
| **Get locale** | `locale()` (async, `Nullable.t<string>`) |
| **Get hostname** | `hostname()` (async, `Nullable.t<string>`) |

polymorphic variants (`platform` / `osType` / `arch` / `family`) は文字列にデコードする helper を提供。

共有ファイル更新:
- root `Cargo.toml`
- `docs/repository-structure.md`
- `sphinx-docs/user/plugin-os.md` "See also"
- `packages/plugin-os/CHANGELOG.md`
- `.github/workflows/examples-build.yml`

### 3.2 含めないもの

- npm publish 実行
- 翻訳 .po 更新

## 4. 受け入れ基準

- [ ] `examples/plugin-os-demo/` が plugin-shell-demo 雛形と同じファイル構成
- [ ] `src/App.res` に全 9 関数 + 4 polymorphic variant decoder helper を実装
- [ ] `capabilities/default.json` に `os:default` permission
- [ ] root Cargo / docs / CI / CHANGELOG / user guide cross-link 確立
- [ ] build 成功
- [ ] tasklist 全タスク `[x]` で main merge 完了
