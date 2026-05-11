# Requirements: Phase 2 pre-release note を MyST substitution で一元化

| 項目 | 内容 |
|---|---|
| ステアリング番号 | 20260511-011 |
| 種別 | リファクタリング (sphinx-docs ドキュメント / 設定) |
| 作成日 | 2026-05-11 |
| 関連 | steering 001-007 (新規 user guide 追加群) / steering 006 (ja translation) |

---

## 1. 背景

`sphinx-docs/user/plugin-*.md` 配下の 8 つの plugin ユーザーガイドそれぞれに、Phase 2 pre-release ステータスを案内する `{note}` ブロックが含まれている:

```
```{note}
The Phase 2 implementation is feature-complete in `main`. The
first npm publish (`plugin-<NAME>-v0.1.0`) is scheduled alongside
the other Phase 2 packages. Until then, consume
`@rescript-tauri/plugin-<NAME>` via the source repository or a
workspace link.
```
```

文面は完全に同じで、`<NAME>` 部分（plugin-fs / plugin-dialog / plugin-shell / plugin-notification / plugin-log / plugin-os / plugin-clipboard-manager / plugin-http）のみ変化する。今後 plugin が増えるたびに同じ boilerplate を 2 箇所（v0.1.0 タグ名と `@rescript-tauri/plugin-X` パッケージ名）でコピペする必要があり、Phase 2 npm publish 後はすべて削除しなければならない。

本ステアリングは MyST substitution を用いて 8 つの note ブロックを 1 つの定義から再利用できるようにする。

## 2. ゴール

1. `sphinx-docs/conf.py` の `myst_enable_extensions` に `substitution` を追加する。
2. `sphinx-docs/conf.py` に `myst_substitutions` を追加し、`phase_2_note` キーで pre-release 案内文を一元定義する。
3. 8 つの plugin ユーザーガイドの boilerplate `{note}` ブロックを substitution 参照 (`{{ phase_2_note }}`) に置き換える。
4. `make html` および `make build-ja` が clean に通り、`<https://...>/user/plugin-fs.html` 等の生成 HTML に従来と同等の note 表示が現れることを確認する。
5. 既存日本語訳 (`plugin-fs.po` / `plugin-dialog.po` の note 部分) は壊さない、または同等の Japanese msgstr を新 msgid に再登録する。

## 3. 非ゴール

- 8 ページの note 以外のセクションには手を入れない。
- 既存翻訳 (.po) の品質向上は対象外（既訳テキストの転写のみ）。
- substitution の汎用化 (RFC / .pot 出力フォーマット変更等) は対象外。
- 他のドキュメント (CLAUDE.md / docs/) は対象外。
- substitution 文中で package 名を埋め込む parameterised 機構（Jinja マクロ等）は導入しない。文面を一般化して package 名への参照を消す方針。

## 4. 設計方針

### 4.1 substitution 文面（package 名を含まない一般化版）

```
The Phase 2 implementation of this package is feature-complete in
`main`. Its first npm publish is scheduled alongside the other
Phase 2 packages. Until then, consume it via the source repository
or a workspace link.
```

- 旧文の「`plugin-X-v0.1.0`」と「`@rescript-tauri/plugin-X`」を「this package」「it」で受ける
- 読者は当該ガイド本文の H1 でパッケージを既に認識しているため意味は通る
- Phase 2 npm publish 後は `conf.py` から 1 行削除 + 8 ページの参照削除で完了する

### 4.2 各ガイドでの利用

```
```{note}
{{ phase_2_note }}
```
```

`{note}` directive 自体は残し、その本文だけを substitution に置き換える。これにより既存の admonition スタイルを保持したまま、本文の単一ソース化を実現する。

### 4.3 plugin-clipboard-manager.md の 2 つ目の `{note}` は対象外

`plugin-clipboard-manager.md:186` の 2 つ目の `{note}`（Android / iOS の `writeImage` / `readImage` 非対応に関する内容固有の注意）は置換対象**外**。

## 5. 受け入れ基準

- `sphinx-docs/conf.py` の `myst_enable_extensions` に `"substitution"` が含まれている
- `sphinx-docs/conf.py` に `myst_substitutions = {"phase_2_note": "..."}` が定義されている
- 8 つの plugin ユーザーガイドが `{{ phase_2_note }}` を使用している
- 旧 boilerplate `{note}` ブロックの直接記述が 0 件
- `make html` が `error` なしで完了し、`_build/html/user/plugin-fs.html` 等で「The Phase 2 implementation ...」の文言が表示される
- `make build-ja` が `error` なしで完了し、`_build/html_ja/user/plugin-fs.html` 等でも同等の note が表示される
- 既存 ja 翻訳が保持される、または substitution で生成された新 msgid に対応する msgstr が ja で記述されている
- `plugin-clipboard-manager.md` の 2 つ目の `{note}`（Android/iOS Image 関連）は変更なし

## 6. リスク・補足

- **MyST substitution の gettext 抽出挙動**: Sphinx + MyST 環境で substitution が `gettext` 抽出時にどう扱われるかはバージョン依存。基本的には rendered 後の文字列が抽出されるはずだが、各 .po ファイルに同じ msgid が出るか、conf.py の substitution 値が単一の msgid として共有されるかは要検証。後者なら .po への影響は 1 箇所のみで望ましい。
- **plugin-fs.po / plugin-dialog.po の既訳保持**: 旧 msgid とは異なる文面 (`this package` / `it`) になるため、自動的には fuzzy 化されない（msgid 完全新規扱い）。旧訳は orphan として消える可能性があるため、`make update-po` 後に新 msgid へ Japanese msgstr を手動転写する。
- **並列セッション衝突**: 同日に 9 件以上の steering が走っている。マージ直前に最新 main を取り込んで衝突確認。
- **disk pressure (94%)**: sphinx build (gettext / html_ja / html) は計数 MB の出力で問題なし。
