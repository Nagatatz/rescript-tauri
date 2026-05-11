# Requirements: sphinx-docs plugin-shell user guide

| 項目 | 内容 |
|---|---|
| Steering 番号 | 20260511-001 |
| 作業タイトル | sphinx-docs plugin-shell user guide |
| 作成日 | 2026-05-11 |
| 関連 steering | 051 (`@rescript-tauri/plugin-shell` 本体実装) |
| 関連ドキュメント | `docs/repository-structure.md` §5（`user/plugin-shell.md` 未追加と明示） |

---

## 1. 背景

- `@rescript-tauri/plugin-shell` パッケージ本体は steering 051 (2026-05-09) で完成済み。`README.md` と `src/PluginShell.resi` に doc comment / 互換マトリクスが揃っている。
- ただし `sphinx-docs/user/plugin-shell.md` は **未作成**。`docs/repository-structure.md` §5 末尾に「後続 sub-steering で追加予定（現状は各パッケージの `README.md` を参照）」と明記されており、本ステアリングがその後続作業に該当する。
- 既に `sphinx-docs/user/index.md` の toctree / 「Phase 2 packages」テーブルにも plugin-shell エントリが無く、新規ページ追加と同時に index も更新する必要がある。

## 2. 目的

`@rescript-tauri/plugin-shell` の **公開 API すべて** をエンドユーザー視点でカバーする sphinx-docs ユーザーガイドを追加し、`sphinx-docs/user/index.md` の Phase 2 packages テーブル・toctree に登録する。

## 3. スコープ

### 3.1 含めるもの (in-scope)

1. `sphinx-docs/user/plugin-shell.md` 新規追加（既存 `plugin-fs.md` / `plugin-dialog.md` のスタイルに準拠）
   - 概要 + Phase 2 npm publish status note
   - Install（pnpm add コマンド + `rescript.json` の dependencies）
   - Rust 側のセットアップ（`Cargo.toml` + `tauri::Builder` の plugin 登録）
   - Capabilities セクション（`shell:default` + scope / open regex の最小例）
   - Minimal example（`openPath` の単純呼び出し）
   - Public API 表（README に合わせる）
   - 詳細セクション:
     - `openPath` のリネーム理由（ReScript 予約語 `open` 衝突）
     - `Command.create` / `createRaw` / `sidecar` / `sidecarRaw` の 4 分岐理由（upstream の conditional return type を静的化）
     - `Command.execute` vs `Command.spawn` の使い分けと例
     - イベント購読（`onClose` / `onError` / `onStdoutData` / `onStderrData`）の chaining 例
     - `Child.write` / `Child.kill` / `Child.pid` の使用例
   - Pitfalls（`Uint8Array.t` の length が `TypedArray.length` 経由である等、plugin-fs と共通の落とし穴で plugin-shell の `createRaw` 利用時に該当するもの）
   - Compatibility テーブル（README と一致させる）
   - See also（source へのリンク + upstream Tauri docs。`examples/plugin-shell-demo` は未存在のため live demo リンクは含めない）

2. `sphinx-docs/user/index.md` の更新
   - 「Phase 2 packages」テーブルに `@rescript-tauri/plugin-shell` 行を追加
   - 末尾の toctree に `plugin-shell` を追加（`plugin-fs` / `plugin-dialog` の隣）

3. `docs/repository-structure.md` §5 「未追加のユーザーガイド」一覧から `user/plugin-shell.md` を削除

### 3.2 含めないもの (out-of-scope)

- **`examples/plugin-shell-demo/` の新規作成**（別 steering に分離。本ガイドからは現状リンクしない）
- **`sphinx-docs/locale/ja/` の `.po` 翻訳更新**（後続 sub-steering で `make update-po` 実行）
- 上流 Tauri docs の翻訳・転載（リンクのみ）
- `packages/plugin-shell/README.md` の改訂（既存内容と矛盾しない範囲で本ガイドを作成）
- `CHANGELOG.md` への記載（ドキュメント追加は CHANGELOG 対象外）

## 4. 受け入れ基準

- [ ] `sphinx-docs/user/plugin-shell.md` が公開 API（`openPath`、`Command` 全関数、`Child` 全関数、`EventEmitter` 概観、`spawnOptions` / `childProcess` / `terminatedPayload`）を網羅している
- [ ] 各セクションが既存 `plugin-fs.md` / `plugin-dialog.md` と同じ Markdown / MyST 構造（`{note}` ディレクティブ、`{toctree}`、テーブル形式）に従っている
- [ ] `sphinx-docs/user/index.md` の Phase 2 packages テーブルと toctree に `plugin-shell` が追加されている
- [ ] `docs/repository-structure.md` §5 の「未追加のユーザーガイド」記述が更新されている（`user/plugin-shell.md` を削除、`user/plugin-notification.md` は残す）
- [ ] `pnpm run check` が green（`.md` は Biome 対象外だが他に副作用がないこと）
- [ ] doc-link-lint（CI ジョブ `doc-link-lint.yml`）の対象となる相対リンクが壊れていない
- [ ] tasklist.md の全タスクが `[x]` でコミットされ、main へマージ完了

## 5. 非機能要件

- スタイル: 既存 `plugin-fs.md` / `plugin-dialog.md` と一致させ、章立て・テーブル列順・コード fence の言語識別子（`rescript` / `bash` / `toml` / `rust` / `json`）を統一する。
- 言語: 英語（ja 翻訳は別 steering）。
- リンク: Tauri 公式 URL は `https://v2.tauri.app/...` 形式。GitHub リンクは `https://github.com/Nagatatz/rescript-tauri/tree/main/...` 形式（既存ガイドと統一）。

## 6. リスク・前提

- **前提**: `packages/plugin-shell` の API は steering 051 で確定しており、本ステアリング中の変更は想定しない。
- **リスク**: scope / open regex / capability 名は upstream の最新 `2.3.x` 仕様に依存。doc-link-lint で URL fragment が誤っていれば CI で検知される。
- **回避策**: 公開後に upstream URL の fragment が変わった場合は別 steering で対応（履歴に残す）。
