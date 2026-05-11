# Requirements: examples/plugin-shell-demo

| 項目 | 内容 |
|---|---|
| Steering 番号 | 20260511-006 |
| 作業タイトル | examples/plugin-shell-demo |
| 作成日 | 2026-05-11 |
| 関連 steering | 051 (`@rescript-tauri/plugin-shell` 本体), 20260511-001 (sphinx-docs plugin-shell user guide) |
| 関連ドキュメント | `docs/repository-structure.md` §3 (examples 一覧), `sphinx-docs/user/plugin-shell.md` |

---

## 1. 背景

- `@rescript-tauri/plugin-shell` は steering 051 で実装済み、sphinx-docs user guide は steering 20260511-001 で追加済み。
- ただし PRD §5.4 が要求する **CI ビルド可能な使用例** (`examples/<name>-demo/`) は **未追加**。
- 既に `plugin-fs-demo` / `plugin-dialog-demo` は同等の demo が存在しており、本作業はその plugin-shell 版に相当。
- 本ステアリング完了後、`sphinx-docs/user/plugin-shell.md` の "See also" に live demo リンクを追記できる（steering 001 では「example 未存在のため live demo 行を入れない」として保留した）。

## 2. 目的

`examples/plugin-shell-demo/` を新規追加し、`@rescript-tauri/plugin-shell` の **公開 API すべて** を Tauri 2.x デスクトップアプリ上から呼び出せる minimum-viable demo を提供する。

## 3. スコープ

### 3.1 含めるもの (in-scope)

1. `examples/plugin-shell-demo/` の新規追加（既存 `plugin-dialog-demo` / `plugin-fs-demo` の構造に準拠）
   - `package.json` / `rescript.json` / `index.html` / `README.md`
   - `src/App.res` — UI ロジック（全公開 API を 1 button = 1 関数 にひも付け）
   - `src/main.mjs` — エントリ
   - `src-tauri/` — Tauri バックエンド
     - `Cargo.toml` (依存に `tauri-plugin-shell = "2"`)
     - `build.rs` (`tauri-build`)
     - `src/main.rs` (`.plugin(tauri_plugin_shell::init())` 登録)
     - `tauri.conf.json` (windows / bundle / app metadata)
     - `capabilities/default.json` (`shell:default` + 必要な `shell:allow-execute` / `shell:allow-open` permission)
     - `icons/` (既存 demo からコピー)

2. デモ対象 API — `PluginShell` モジュールから公開されている全関数を網羅:
   - `openPath` (URL を default browser で開く / `~openWith` 指定)
   - `Command.create` + `Command.execute` (1-shot UTF-8 コマンド)
   - `Command.createRaw` + `Command.execute` (Uint8Array 出力)
   - `Command.create` + `Command.spawn` + `Child.write` + `Child.kill` + `Child.pid` (背景プロセス制御)
   - `Command.create` + イベント chaining (`onStdoutData` / `onStderrData` / `onClose` / `onError`) を `Command.spawn` 後にストリーミング表示
   - `Command.removeAllListeners`
   - `Command.sidecar` / `Command.sidecarRaw` — 型レベル参照のみ（実際の sidecar binary を bundle すると CI で複雑化するため）

3. 共有ファイル更新（最小限）:
   - `Cargo.toml` (root): `members` に `examples/plugin-shell-demo/src-tauri` を追加
   - `docs/repository-structure.md` §3: `examples/` 一覧に `plugin-shell-demo/` 行を追加
   - `sphinx-docs/user/plugin-shell.md`: "See also" に live demo リンクを 1 行追加

### 3.2 含めないもの (out-of-scope)

- `pnpm-workspace.yaml` の編集（`examples/*` glob で既に自動カバー）
- 上流 `@tauri-apps/plugin-shell` の機能拡張（バインディングは既存のものを使用）
- 実際の sidecar binary のバンドル（CI を複雑化）
- スタイリング・UX ポリッシュ（既存 demo と同等の "全 button + result pane" でよい）
- E2E / 自動テスト（既存 demo もテスト無し。CI build matrix が build 成功のみ検証）
- ja `.po` 翻訳（demo は翻訳対象外）

## 4. 受け入れ基準

- [ ] `examples/plugin-shell-demo/` が `plugin-dialog-demo` と同じ 8 ファイル + icons/ ディレクトリを持つ
- [ ] `src/App.res` から `PluginShell` の全公開 API へ実呼び出しがある（型レベル参照のみは Command.sidecar / Command.sidecarRaw のみ許可）
- [ ] `capabilities/default.json` が `shell:allow-execute` / `shell:allow-open` の minimum 設定を含む
- [ ] root `Cargo.toml` の `members` に新メンバーが登録されている
- [ ] `pnpm install` 後に `pnpm --filter plugin-shell-demo build`（= `rescript build`）が成功する
- [ ] `cargo check --manifest-path examples/plugin-shell-demo/src-tauri/Cargo.toml` が成功する（CI で実際に build される）
- [ ] `docs/repository-structure.md` §3 が更新されている
- [ ] `sphinx-docs/user/plugin-shell.md` の "See also" に live demo リンクが追加されている
- [ ] tasklist.md の全タスクが `[x]` でコミットされ、main へマージ完了

## 5. 非機能要件

- スタイル: `plugin-dialog-demo` と同じ「全 button + result pane (<pre id="result">)」の MVP。
- HTML/CSS: 既存 demo の最小デザインを踏襲し、追加の CSS フレームワークは導入しない。
- Rust: edition = "2021"、`tauri = { version = "2", features = [] }` で minimum。

## 6. リスク・前提

- **前提**: `@rescript-tauri/plugin-shell` および上流 `@tauri-apps/plugin-shell ^2.3.0` の API が現状確定（steering 051 で固定）。
- **リスク**: 並列セッションが他 demo 作業を進めると root `Cargo.toml` で merge conflict が発生する可能性。worktree マージ前に最新 main を取り込む。
- **リスク**: `tauri::Builder` の plugin 登録順序や capability スキーマが上流バージョンで変わると CI 失敗する。既存 demo (`plugin-dialog-demo` / `plugin-fs-demo`) と同じ pattern に揃えれば緩和可能。
- **ディスク**: 現在 93% 使用率。`pnpm install` で `examples/plugin-shell-demo/node_modules/` が追加されるが、`@tauri-apps/plugin-shell` は既に lockfile にあるため大きく増えないはず。
