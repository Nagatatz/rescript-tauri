# Design: sphinx-docs `locale/ja/` 翻訳更新

| 項目 | 内容 |
|---|---|
| ステアリング番号 | 20260511-006 |
| 関連 | requirements.md / `sphinx-docs/Makefile` |

---

## 1. 影響ファイル

### 新規（5 ファイル）

```
sphinx-docs/locale/ja/LC_MESSAGES/user/plugin-shell.po
sphinx-docs/locale/ja/LC_MESSAGES/user/plugin-notification.po
sphinx-docs/locale/ja/LC_MESSAGES/user/plugin-log.po
sphinx-docs/locale/ja/LC_MESSAGES/user/plugin-os.po
sphinx-docs/locale/ja/LC_MESSAGES/user/plugin-clipboard-manager.po
```

`.mo` は `make build-ja` が生成する。既存 `.mo` が tracked なので、新規 `.mo` も commit に含める（リポジトリの既存規約に合わせる）。

### 更新（2 ファイル）

```
sphinx-docs/locale/ja/LC_MESSAGES/user/index.po
sphinx-docs/locale/ja/LC_MESSAGES/user/installation.po
```

それぞれ `make update-po` の出力で新規 msgid（"six add-on packages" / "seven add-on packages" / 新規テーブル行 / 新規 cross-ref リンク / follow-up 注記から除外された項目）を取り込む。

### 自動更新が走り得るその他

```
sphinx-docs/locale/ja/LC_MESSAGES/user/{changelog,configuration,quickstart,schema,plugin-fs,plugin-dialog}.po
```

これらは原文 (.md) に変更が無いはずなので、`make update-po` は POT-Creation-Date のみ更新する。それ以外の差分が出た場合は当該ファイルへの誤った修正なので、調査する。

## 2. 生成手順

```bash
cd sphinx-docs
make update-po
```

`sphinx-docs/Makefile` の `update-po` target は内部で:

1. `make gettext` — `sphinx-build -b gettext` で `.pot` を生成
2. `sphinx-intl update -p _build/gettext -l ja` — 既存 `.po` を merge / 新規 `.po` を生成

を実行する。`.venv/bin/sphinx-build` と `.venv/bin/sphinx-intl` が既に存在するので追加 install は不要。

## 3. 翻訳作業

`make update-po` 直後の `.po` は新規 msgid が `msgstr ""` で並ぶ。以下の方針で msgstr を埋める:

### 3.1 訳出対象（5 新規 .po で共通）

各 `.po` で訳出する msgid:

| カテゴリ | 例 |
|---|---|
| 章タイトル (H2) | `Install` → `インストール` |
| 章タイトル (H2) | `Capabilities` → `Capability 設定` |
| 章タイトル (H2) | `Minimal example` → `最小サンプル` |
| 章タイトル (H2) | `Public API` → `公開 API` |
| 章タイトル (H2) | `Pitfalls` → `注意点` |
| 章タイトル (H2) | `Compatibility` → `互換性` |
| 章タイトル (H2) | `See also` → `関連リンク` |
| 章タイトル (H3) | パッケージ固有のサブセクション（後述） |
| テーブルヘッダ | `Function` / `Returns` / `Notes` → `関数` / `戻り値` / `備考` |
| テーブルヘッダ | `Symbol` / `Purpose` / `Sync?` → `シンボル` / `用途` / `同期?` |
| 互換性 Component | `Upstream <pkg>` → `上流 <pkg>` |
| 互換性 Component | `Rust <crate>` → `Rust <crate>`（変更なし） |
| 互換性 Component | `OS` → `対応 OS` |

### 3.2 ページ固有 H3 翻訳辞書

| ページ | msgid | msgstr |
|---|---|---|
| plugin-shell | `Permission flow` | `Permission フロー` |
| plugin-shell | `Spawn a child process` | `子プロセスの起動` |
| plugin-shell | `Open a URL or file` | `URL / ファイルを開く` |
| plugin-notification | `Permission flow` | `Permission フロー` |
| plugin-notification | `Schedule helpers` | `Schedule ヘルパー` |
| plugin-notification | `Split sendNotification overload` | `sendNotification overload の分割` |
| plugin-notification | `Numeric enum constants` | `数値 enum の定数` |
| plugin-notification | `Web API path, not IPC` | `IPC ではなく Web API 経由` |
| plugin-log | （後述：plugin-log.md の見出しに合わせる） | |
| plugin-os | `Sync getters` | `Sync ゲッター` |
| plugin-os | `Async getters` | `Async ゲッター` |
| plugin-os | `Capability requirement` | `Capability 要件` |
| plugin-os | `Polymorphic variants` | `Polymorphic variant` |
| plugin-os | `Pattern match example` | `パターンマッチ例` |
| plugin-os | `` `type()` renamed to `osType_()` `` | `` `type()` の `osType_()` へのリネーム `` |
| plugin-os | `Sync getters don't go through IPC` | `Sync ゲッターは IPC を通らない` |
| plugin-os | `` `#x86_64`, `#powerpc64`, etc. are valid as-is `` | `` `#x86_64`、`#powerpc64` 等はそのまま使える `` |
| plugin-clipboard-manager | （plugin-clipboard-manager.md の見出しに合わせる） | |

plugin-log と plugin-clipboard-manager の H3 は実装時に対象 `.md` を確認して埋める（並列セッションがマージ済みになっているため、main の最新版を参照）。

### 3.3 訳さない msgid

- パラグラフ全文（`msgstr ""` のまま → fallback で英語表示）
- コードブロック内の文字列
- URL を含む `[テキスト](URL)` 形式の link 本文（混在訳は読みづらいため）
- ファイルパス・コマンドライン

## 4. index.po / installation.po の差分対応

### 4.1 index.po

更新が必要な新規 msgid 候補:

- `Phase 2 introduces seven add-on packages that build on the Phase 1 core. ...`
- 新規テーブル行（plugin-shell / plugin-notification / plugin-os / plugin-clipboard-manager）
- 新規 toctree エントリ（`plugin-shell` / `plugin-notification` / `plugin-os` / `plugin-clipboard-manager`）

訳出方針:
- "seven add-on packages" → `7 個のアドオンパッケージ` のような形で訳す
- 各テーブル行の Purpose 列（短文）は訳す。Package 名・Guide 列は識別子なのでそのまま
- toctree エントリは識別子なのでそのまま (`msgstr ""` のまま許容)

### 4.2 installation.po

更新が必要な新規 msgid 候補:

- cross-ref 行: "See the [plugin-fs](plugin-fs.md), ..., and [schema](schema.md) guides ..."
- follow-up 注記: 残りプラグイン (plugin-shell / plugin-log / plugin-clipboard-manager) のみ言及するように変わったテキスト

訳出方針:
- cross-ref 行は短い文なので訳す
- follow-up 注記は段落なので `msgstr ""` のまま

## 5. ビルド検証

```bash
cd sphinx-docs
make build-ja 2>&1 | tail -20
```

期待: `build succeeded` または `build succeeded, X warnings.` で完了し、`error` を含まないこと。`_build/ja/html/user/plugin-os.html` 等が生成され、見出しが日本語化されていること。

## 6. コミット粒度

5 新規 .po は 5 commit に分けるとレビュー追跡しやすい。`.mo` は同じコミットに同梱:

```
✨ Add ja translation stub for plugin-shell
✨ Add ja translation stub for plugin-notification
✨ Add ja translation stub for plugin-log
✨ Add ja translation stub for plugin-os
✨ Add ja translation stub for plugin-clipboard-manager
📝 Refresh ja translations for index and installation
```

最終コミットで `tasklist.md` を [x] 化。

## 7. リスク

- **並列マージ中の衝突**: 他の steering が `index.md` / `installation.md` をさらに編集して main にマージしている場合、自分のマージ直前に `git fetch origin && git log` で確認し、必要なら `make update-po` を再走させて取り込む。
- **`.mo` バイナリ衝突**: 並列セッションが同じファイルに `.mo` を生成していた場合 `git merge` でバイナリ衝突する可能性。発生時は worktree 側を `theirs` で採用して `make build-ja` を再走。
