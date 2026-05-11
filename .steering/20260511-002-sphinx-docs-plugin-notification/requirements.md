# Requirements: sphinx-docs `user/plugin-notification.md` を追加

| 項目 | 内容 |
|---|---|
| ステアリング番号 | 20260511-002 |
| 種別 | ドキュメント追加（外部公開 sphinx-docs） |
| 作成日 | 2026-05-11 |
| 関連 | steering 054 (`@rescript-tauri/plugin-notification` 本体実装) / `docs/repository-structure.md` §5 |

---

## 1. 背景

`@rescript-tauri/plugin-notification` は steering 054 で実装が完了し、`packages/plugin-notification/README.md` および `src/PluginNotification.resi` に doc-comment 付きで全 API がドキュメント化されている。一方、外部公開向け Sphinx サイト (`sphinx-docs/`) には `user/plugin-notification.md` がまだ存在せず、`docs/repository-structure.md` §5 でも未追加が明示されている:

> **未追加のユーザーガイド:** `user/plugin-shell.md`, `user/plugin-notification.md` は後続 sub-steering で追加予定（現状は各パッケージの `README.md` を参照）。

本ステアリングはそのうち plugin-notification 分を解消する。

## 2. ゴール

1. `sphinx-docs/user/plugin-notification.md` を新規追加し、Sphinx + Furo + MyST でビルドできる Markdown とする。
2. `sphinx-docs/user/index.md` の Phase 2 packages テーブルおよび `toctree` directive に `plugin-notification` を含める。
3. 既存の `plugin-fs.md` / `plugin-dialog.md` と同じ章立て・トーンで書き、リーダーが既知の他ページと違和感なく読めるようにする。

## 3. 非ゴール

- 日本語 `.po` ファイル (`sphinx-docs/locale/ja/LC_MESSAGES/user/plugin-notification.po`) の生成・翻訳は対象外。Sphinx + babel + sphinx-intl のビルドが必要で、ディスク / トークンコストが大きく、既存翻訳 (`plugin-fs.po` / `plugin-dialog.po`) も英語 `msgstr` のままの段階。後続 sub-steering で `plugin-shell.po` / `plugin-notification.po` / `plugin-log.po` 等をまとめて生成する。
- `examples/plugin-notification-demo/` の追加は対象外（別 steering）。
- `packages/plugin-notification` 本体の API 追加・修正は対象外。
- iOS / Android 固有の挙動の網羅的な解説は対象外。`Options` の各フィールド説明は upstream へのリンクで代替する。

## 4. 採用する内容方針

### 4.1 章構成（`plugin-fs.md` 準拠）

1. タイトル + 一段落のリード文（upstream リンク付き）
2. `{note}` ブロック: npm publish のステータスと暫定インストール手段
3. **Install**: npm install コマンド / `peerDependencies` の説明 / `rescript.json` への追加 / Rust 側のクレート登録
4. **Capabilities**: `notification:default` を含む最小 capability JSON
5. **Permission flow**: `isPermissionGranted` + `requestPermission` のミニマル例（plugin-fs にはないが本プラグイン固有）
6. **Minimal example**: `sendNotificationText` / `sendNotification` の最小コード
7. **Public API**: 15 関数 + `Schedule` factory + `Importance` / `Visibility` モジュール + 主要 record 型の表
8. **Schedule helpers**: `Schedule.at` / `Schedule.interval` / `Schedule.every` のショート例
9. **Pitfalls**:
   - upstream `sendNotification(options | string)` overload が 2 関数（`sendNotification` / `sendNotificationText`）に分割されている件
   - `Importance` / `Visibility` が `int` named constants として公開され、`default_` / `private_` / `public_` が JS 出力の `$$default` / `$$private` / `$$public` エスケープを避けるため suffix 付きである件
   - `requestPermission` / `sendNotification` / `sendNotificationText` は upstream で IPC ではなく `window.Notification` Web API 経由で動作する件（テスト時の挙動含む）
10. **Compatibility** テーブル
11. **See also** リスト

### 4.2 ドキュメント内リンク

- upstream API: `https://v2.tauri.app/plugin/notification/` および `https://v2.tauri.app/reference/javascript/notification/#<symbol>`
- npm: `https://www.npmjs.com/package/@tauri-apps/plugin-notification`
- 内部リンク: `packages/plugin-notification/README.md` ではなく GitHub の `https://github.com/Nagatatz/rescript-tauri/tree/main/packages/plugin-notification` を使う（既存 `plugin-fs.md` の慣習）
- `examples/plugin-notification-demo` は未存在なので **言及しない**（将来 sub-steering で追加された段階でリンクを追加）

### 4.3 トーン / 文体

- 英語のみ（日本語は `.po` 経由）
- 既存 `plugin-fs.md` の散文トーンに準拠（命令形と説明文の混合）
- 機能網羅性より「最小起動 + ハマりどころ」を優先

## 5. 受け入れ基準

- `sphinx-docs/user/plugin-notification.md` が存在し、上記章構成すべてを満たす
- `sphinx-docs/user/index.md` の Phase 2 packages テーブルに `plugin-notification` 行が追加されている
- `sphinx-docs/user/index.md` の `toctree` directive に `plugin-notification` が含まれている
- 文中のすべての upstream リンクが Tauri v2 公式 URL に向いている
- 文中で言及した API シンボル（`sendNotification` / `Schedule.every` 等）は実装側 `src/PluginNotification.resi` に存在する
- `examples/plugin-notification-demo` への言及がない
- ja `.po` の更新がない（後続 sub-steering 案件と明示）

## 6. リスク・補足

- **並列セッション**: 同日に steering `20260511-001` (plugin-shell user guide) が並行進行中。`sphinx-docs/user/index.md` の編集が衝突しうるため、マージ前に main の最新を取り込む手順を tasklist に含める。
- **`plugin-shell.md` の追加状況**: 本 steering は `index.md` の編集時、main にすでに plugin-shell が反映されていれば追従して toctree 末尾付近に並べる。未反映なら plugin-notification 行のみ追加する。マージ時点での main を正とする。
- **Future translation parity**: 上記の通り `.po` は別 steering に分離。
