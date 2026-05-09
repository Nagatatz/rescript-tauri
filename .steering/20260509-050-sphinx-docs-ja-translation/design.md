# Design: sphinx-docs Japanese translation

## 1. 全体方針

`sphinx-intl` ベースの既存ワークフローに乗る。すなわち:

```
make gettext        # ソース .md → _build/gettext/*.pot
make update-po      # .pot を locale/ja/LC_MESSAGES/*.po にマージ（新規 .po はここで生成される）
（手動で .po の msgstr を翻訳）
make build-ja       # language=ja で HTML を生成。.mo は build 時に自動コンパイル
```

`.mo` バイナリは現状リポジトリにコミットされているが、本作業では **触らない**（Sphinx の `build_mo` 相当の処理がビルド時に再生成するため）。

## 2. 翻訳対象セクション抽出戦略

`.po` 内の翻訳エントリは MyST が抽出した段落 / 見出し / リスト項目単位。各エントリに対して:

1. `msgid` を読み、内容を理解。
2. コード片・URL・API 名・絵文字はそのまま保持。
3. 自然な日本語に翻訳して `msgstr` に書く。
4. msgid が複数行（`""` 連結）の場合、`msgstr` も同じ規約で書く。

### 2.1 用語統一

| 英語 | 日本語訳 | 備考 |
|---|---|---|
| Quick Start | クイックスタート | |
| Installation | インストール | |
| Configuration | 設定 | |
| Changelog | 変更履歴 | |
| User Guide | ユーザーガイド | |
| Developer Guide | 開発者ガイド | |
| Setup | セットアップ | |
| Building | ビルド | |
| Architecture | アーキテクチャ | |
| Contributing | コントリビュート | |
| Project Structure | プロジェクト構成 | |
| Schema | Schema | パッケージ名のため非翻訳 |
| binding(s) | バインディング | |
| package | パッケージ | |
| workspace | ワークスペース | |
| monorepo | モノレポ | |
| Tauri command | Tauri コマンド | |
| event | イベント | |
| listener | リスナー | |
| channel | Channel | API 名のため非翻訳 |
| invoke | invoke | API 名のため非翻訳 |
| menu | メニュー | |
| tray | トレイ | |
| webview | WebView | |
| window | ウィンドウ | |

### 2.2 文体

- ユーザーガイド (`user/`) は読みやすさ重視で「です・ます」調。
- 開発者ガイド (`dev/`) は技術文書として簡潔さ重視。「です・ます」を基本に必要に応じて短縮。

## 3. 手順詳細

### 3.1 worktree 作成

`EnterWorktree(name="sphinx-ja-translation")` で `.claude/worktrees/sphinx-ja-translation/` を作成し作業を隔離する。`.steering/` ファイルは作成済みなのでメイン側でコミットしてから（または worktree 内で同梱して）コミットする。

### 3.2 .pot / .po 更新

```
cd sphinx-docs
make gettext      # _build/gettext/ に .pot 生成
make update-po    # locale/ja/LC_MESSAGES/ の .po を更新・新規生成
```

これで `user/plugin-fs.po`, `user/plugin-dialog.po`, `user/schema.po` が生成される。

### 3.3 翻訳作業

`.po` ごとに `Edit` で `msgstr ""` を一つずつ翻訳して埋める。長文はファイル単位で `Read` → `Edit` を繰り返す。複数 `msgstr` が同じファイル内に連続する場合は `Edit` の `replace_all=False` を活用し、文脈で一意になるよう msgid を含めて差し替える。

### 3.4 ビルド検証

```
cd sphinx-docs
make build-ja
```

stderr の `WARNING` を確認し、未翻訳メッセージや MyST 構文エラーが無いことを確認する。

### 3.5 コミット粒度

- `🔧 Regenerate .po files for sphinx-docs Japanese locale` — `make update-po` で生成された `.po` のスケルトンを 1 コミット。
- `📝 Translate sphinx-docs index/user pages to Japanese` — index, user/* の翻訳。
- `📝 Translate sphinx-docs dev pages to Japanese` — dev/* の翻訳。
- `📝 Mark steering 050 tasks complete pre-merge` — マージ前最終コミット。

ファイル数が多い場合は user / dev を更に分割してもよいが、論理的な単位で機能する範囲に留める。

### 3.6 マージ

worktree → main への `--no-ff` マージ。`steering-workflow.md` の手順に従い、CWD 移動 → マージ → worktree 削除 → ブランチ削除を一括実行する。

## 4. 未翻訳メッセージの扱い

- MyST の admonition タイトル (`note`, `warning` 等) や Furo テーマの組み込み文言は Sphinx が i18n を提供している。`.po` で `msgstr` を埋めれば反映される。
- 翻訳が困難な技術用語はそのまま英語を残す（例: "loader", "hot reload"）。
- API 関数名・モジュール名は翻訳せず英語のまま。

## 5. 検証項目

- `git grep '^msgstr ""' sphinx-docs/locale/ja` の結果がヘッダ行（`""` 直後の `msgstr ""`）以外で 0 件であること。
- `make build-ja` の終了コードが 0、`WARNING` を最小化（既存の `toc.excluded` 抑制を超えるものが無いこと）。
- `_build/html_ja/index.html` の主要セクションが日本語化されていることを Read で目視確認。
