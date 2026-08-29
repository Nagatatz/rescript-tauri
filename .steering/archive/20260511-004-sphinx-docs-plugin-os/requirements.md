# Requirements: sphinx-docs `user/plugin-os.md` を追加

| 項目 | 内容 |
|---|---|
| ステアリング番号 | 20260511-004 |
| 種別 | ドキュメント追加（外部公開 sphinx-docs） |
| 作成日 | 2026-05-11 |
| 関連 | steering 056 (`@rescript-tauri/plugin-os` 本体実装) / `docs/repository-structure.md` §5 / steering 002 (plugin-notification user guide 先行例) |

---

## 1. 背景

`@rescript-tauri/plugin-os` は steering 056 で実装が完了している（9 関数 / 4 polymorphic variant、`packages/plugin-os/README.md` および `src/PluginOs.resi` に doc-comment あり）。外部公開向け Sphinx サイトには `user/plugin-os.md` がまだ存在しない。`sphinx-docs/user/installation.md` の "scheduled for follow-up sub-steerings" 注記にも plugin-os が含まれている。

本ステアリングはこのギャップを埋め、ユーザーが Sphinx サイトのみで OS 情報プラグインの導入から polymorphic variant の pattern match までを一通り学べる状態にする。

## 2. ゴール

1. `sphinx-docs/user/plugin-os.md` を新規追加し、Sphinx + Furo + MyST でビルドできる Markdown とする。
2. `sphinx-docs/user/index.md` の Phase 2 packages テーブルおよび `toctree` directive に `plugin-os` を含める。
3. `sphinx-docs/user/installation.md` の cross-ref 行に `[plugin-os](plugin-os.md)` を追加し、follow-up 注記から `@rescript-tauri/plugin-os` を除外する。
4. 既存の `plugin-fs.md` / `plugin-dialog.md` / `plugin-notification.md` と同じ章立て・トーンで書き、リーダーが他ページと違和感なく読めるようにする。

## 3. 非ゴール

- 日本語 `.po` ファイル (`sphinx-docs/locale/ja/LC_MESSAGES/user/plugin-os.po`) の生成・翻訳は対象外（後続 sub-steering）。
- `examples/plugin-os-demo/` の追加は対象外。
- `packages/plugin-os` 本体の API 追加・修正は対象外。
- iOS / Android 固有の挙動の網羅的な解説は対象外（リンクでの参照に留める）。

## 4. カバーすべき内容

### 4.1 公開 API (9 関数 + 4 polymorphic variants)

| カテゴリ | シンボル | 動作モデル |
|---|---|---|
| 終端文字 | `eol()` → `string` | sync (`window.__TAURI_OS_PLUGIN_INTERNALS__` を直接読む) |
| プラットフォーム | `platform()` → `platform` variant | sync |
| バージョン | `version()` → `string` | sync |
| ファミリ | `family()` → `family` variant | sync |
| OS タイプ | `osType_()` → `osType` variant | sync (upstream `type()` リネーム) |
| アーキテクチャ | `arch()` → `arch` variant | sync |
| 実行ファイル拡張子 | `exeExtension()` → `string` | sync |
| ロケール | `locale()` → `promise<Nullable.t<string>>` | async (IPC `plugin:os|locale`) |
| ホスト名 | `hostname()` → `promise<Nullable.t<string>>` | async (IPC `plugin:os|hostname`) |

4 polymorphic variants:
- `platform`: 10 variants (`#linux` / `#macos` / `#ios` / `#freebsd` / `#dragonfly` / `#netbsd` / `#openbsd` / `#solaris` / `#android` / `#windows`)
- `osType`: 5 variants (`#linux` / `#windows` / `#macos` / `#ios` / `#android`)
- `arch`: 11 variants (`#x86` / `#x86_64` / `#arm` / `#aarch64` / `#mips` / `#mips64` / `#powerpc` / `#powerpc64` / `#riscv64` / `#s390x` / `#sparc64`)
- `family`: 2 variants (`#unix` / `#windows`)

### 4.2 必須トピック

ユーザーが詰まる典型箇所を必ず説明する:

1. **`type()` → `osType_()` リネーム理由**: ReScript の予約語 `type` との衝突を避けるためサフィックス付き。冒頭の Pitfalls 節で明示。
2. **Sync 7 関数の動作モデル**: upstream で `window.__TAURI_OS_PLUGIN_INTERNALS__` を直接読むため IPC を経由しない。`Mocks.mockIPC` では interception できず、テストでは globals stub を用いる。
3. **Async 2 関数の動作モデル**: `locale` / `hostname` は IPC (`plugin:os|locale` / `plugin:os|hostname`) 経由。戻り値が `Nullable.t<string>` で `Nullable.null` が「不明」を表す。
4. **Polymorphic variant の pattern match 例**: `platform()` を `switch` で受けて OS 別に分岐する短い例。
5. **`#x86_64`** のような変則名前: ReScript の polymorphic variant タグはそのまま記述可能なことを示す（特別な escape は不要）。

## 5. 受け入れ基準

- `sphinx-docs/user/plugin-os.md` が存在し、上記 4 つの independent checkpoint 構成 (installation / sync getters / async getters + permission flow / variants + pattern match + troubleshoot) を満たす
- 文中で 9 関数すべて + 4 polymorphic variant すべてが少なくとも 1 回ずつ言及されている
- `sphinx-docs/user/index.md` の Phase 2 packages テーブルと `toctree` の両方に `plugin-os` が含まれている
- `sphinx-docs/user/installation.md` の cross-ref 行 (line 72 周辺) に `[plugin-os](plugin-os.md)` が追加されている
- `sphinx-docs/user/installation.md` の "scheduled for follow-up" 注記から `@rescript-tauri/plugin-os` の言及が削除されている
- 文中の API シンボルが `packages/plugin-os/src/PluginOs.resi` に実在する（grep で検証可能）
- `examples/plugin-os-demo` への言及がない
- ja `.po` の更新がない（後続 sub-steering 案件と明示）

## 6. リスク・補足

- **並列セッション**: 同日に steering `20260511-001` (plugin-shell user guide) と `20260511-003` (plugin-log user guide) が並行進行中。`sphinx-docs/user/index.md` および `sphinx-docs/user/installation.md` の編集が衝突しうる。
  - マージ直前に `git fetch origin && git log --oneline HEAD..origin/main` で main の最新差分を確認
  - 衝突発生時は plugin-os 関連の編集のみを残し、他のプラグイン関連編集は維持
- **未 push の steering commit**: T4 / T5 / T6 が並行で行われている場合、自分の steering commit をローカルに残したまま worktree を `HEAD` ベースで作成する必要がある（steering 002 と同じ手順）
- **disk pressure (93%)**: 大規模 `pnpm install` / build は控える。ReScript build / vitest は走らないドキュメントのみの変更なので影響なし。
