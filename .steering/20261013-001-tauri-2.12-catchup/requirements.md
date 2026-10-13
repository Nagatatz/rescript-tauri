# 要求: Tauri 2.12 系への追従

## 背景
2026-10-13 時点で、リポジトリが参照する Tauri 上流はすべて 1 minor 以上遅れていた。

| パッケージ | main | 最新 |
|---|---|---|
| `@tauri-apps/api` | 2.11.1 | 2.12.3 |
| `@tauri-apps/cli` | 2.11.4 | 2.12.2 |
| `@tauri-apps/plugin-fs` | 2.5.1 | 2.7.0 |
| `@tauri-apps/plugin-dialog` | 2.7.2 | 2.8.2 |
| `@tauri-apps/plugin-shell` | 2.3.5 | 2.5.0 |
| `@tauri-apps/plugin-notification` | 2.3.3 | 2.6.0 |
| `@tauri-apps/plugin-log` | 2.9.0 | 2.10.1 |
| `@tauri-apps/plugin-os` | 2.3.2 | 2.4.0 |
| `@tauri-apps/plugin-clipboard-manager` | 2.3.2 | 2.4.2 |
| `@tauri-apps/plugin-http` | 2.5.9 | 2.8.2 |
| `tauri` (crate) | 2.11.5 | 2.12.3 |

Dependabot の bump PR は 2 本とも open のまま止まっていた。

- #85 (npm): `plugin-notification` の vitest が 1 件 failure。upstream 2.5.0 で IPC コマンド名が
  `listChannels` → `list_channels` に変わり、テスト期待値が古いまま。
- #93 (cargo): green だが未マージ。かつ作成後に出た plugin crate (notification 2.6.0 / shell 2.5.0 等) を含まない。

nightly の `compat-tauri-latest` は green だったが、`@tauri-apps/api` だけを latest に差し替えて core と
hello-world しか検証しないため、plugin 側の破壊を検知できていなかった。

## 要求
- npm / cargo の Tauri 依存をすべて最新 stable に揃える（lockfile を同一 PR で再生成）
- 新旧 `.d.ts` の差分から、公開 API の追加・変更をバインディングに反映する
- 追加・変更した API に型レベルテストと runtime テストを付ける
- `compat-tauri-latest` を `@tauri-apps/*` 全体（api / cli / 全 plugin）と全 workspace に広げる
- README / `docs/` / sphinx-docs（ja `.po` 含む）/ 各 CHANGELOG を同期する

## 非要求 (Non-goals)
- パッケージの version bump / リリース（`Unreleased` に記載するのみ）
- `Resource` の `Symbol.asyncDispose`（`await using`）対応: ReScript に対応構文がなく、`close` で代替できる
- `JsImage` 型 alias の導入: upstream の union を polymorphic 型変数で受けている既存設計と等価
- plugin 側の未バインド API（`FileHandle` / `watch` 等、既存 steering で後続に分離済みのもの）
- examples の `cargo check`（ローカルでは未実施。CI の `examples-build` 3 OS で検証する）
