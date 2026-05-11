# Sphinx-docs に ReScript の Pygments lexer を追加 — Requirements

| 項目 | 内容 |
|---|---|
| 採番 | 20260511-021 |
| 作成日 | 2026-05-11 |
| 関連 | `sphinx-docs/`, `docs/repository-structure.md` §5, `.claude/rules/documentation.md` |

## 1. 背景

`sphinx-docs/user/*.md` のコードブロックは `` ```rescript `` と記述されているが、Pygments
は `rescript` lexer を標準で持たないため、Furo テーマで描画される際にハイライトが
かからず単一色で表示されている。ReScript ユーザー向けの公開ドキュメントとして
可読性が著しく低下しているため、構文ハイライトを有効化したい。

`/Users/ngtz/Documents/repos/rescript-intellij-plugin` には JFlex ベースの完全な
ReScript lexer (`Rescript.flex`) と SyntaxHighlighter (`RescriptSyntaxHighlighter.kt`)
が存在しており、キーワード集合・演算子・JSX・annotation・poly variant 等の分類が
正本として利用できる。

## 2. ゴール

1. sphinx-docs のビルド出力で `` ```rescript `` / `` ```res `` コードブロックが
   キーワード・文字列・コメント・型引数・annotation などのカテゴリで色分けされる。
2. IntelliJ プラグインのキーワード集合・トークン分類と整合する（取りこぼし無し）。
3. 既存ページ（`quickstart.md` / `plugin-*.md` / `schema.md`）の表示が破綻しない。
4. sphinx-docs/tests/ に lexer の単体テストを追加する。
5. 既存の Pygments 同梱 lexer / 外部パッケージへの追加依存は発生させない（**追加
   インストールなし**で実装する。lexer 本体は sphinx-docs 内に Python ファイルとして
   置く）。

## 3. Non-goals

- Tree-sitter / LSP ベースのセマンティックハイライト（出力 HTML 内の `<span>` 単位の
  Pygments 標準ハイライトに留める）。
- ReScript の文法を 100% 完璧にパースする lexer（簡易 RegexLexer で実用品質を目指す）。
- IDE / エディタ側のハイライト改善（本作業はドキュメントサイトのみ）。
- `.res` / `.resi` ソースファイルそのもののドキュメントへの直接埋め込み（autodoc 連携）。
- 既存の en/ja 翻訳 `.po` への追記（コードブロックは翻訳対象外）。

## 4. ステークホルダ

- ReScript-tauri ドキュメント閲覧者（外部ユーザー）。
- メンテナ（コードブロック追加時に新しい construct がカバーされていることを確認したい）。

## 5. 受け入れ基準

- [ ] `sphinx-docs` を `make build` / `make build-ja` でビルドして警告なく完了する。
- [ ] 生成された HTML を `_build/html` で確認し、`<span class="k">let</span>` などの
      Pygments クラスが ReScript 構文に対して付与されている。
- [ ] `pytest sphinx-docs/tests/` がすべて pass する（lexer トークン分類の単体テスト含む）。
- [ ] ReScript の全主要構文（キーワード / 文字列 / template literal / 単行・複数行コメント /
      `@annotation` / `#PolyVariant` / `'typeArg` / モジュール名 / 演算子 / JSX タグ）が
      想定どおりのトークンに分類される。
- [ ] 既存の Pygments lexer (例: `ocaml` / `reason`) には依存しない（独立した
      `RegexLexer` サブクラスとして実装する）。
- [ ] disk usage 圧迫を避けるため、追加 pip / npm install を必要としない実装になっている。
