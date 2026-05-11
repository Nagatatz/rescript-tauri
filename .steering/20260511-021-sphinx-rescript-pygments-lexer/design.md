# Sphinx-docs に ReScript の Pygments lexer を追加 — Design

## 1. アーキテクチャ概要

Sphinx は `pygments` を介してコードブロックをハイライトする。`source_suffix` で指定された
言語名（コードブロックの `info string` 部分）が Pygments の lexer alias と一致した時に
ハイライトが適用される。

Pygments 同梱 lexer には `rescript` / `res` が存在しないため、**プロジェクト内に lexer を
配置して Sphinx の `setup(app)` フックで登録する**。これは Sphinx 公式の推奨パターン
（[Custom syntax highlighter](https://www.sphinx-doc.org/en/master/development/theming.html)
配下の `sphinx.highlighting.lexers` への直接登録）。

### 1.1 配置方針

```
sphinx-docs/
├── _ext/                              # 新規ディレクトリ
│   ├── __init__.py                    # 空ファイル（Python パッケージマーカー）
│   └── rescript_lexer.py              # RescriptLexer (RegexLexer サブクラス) + setup(app)
├── conf.py                            # extensions リストに "rescript_lexer" を追加 +
│                                      # sys.path.insert(0, "_ext")
└── tests/
    └── test_rescript_lexer.py         # 新規 — Pygments トークン分類の検証
```

`_ext/` をディレクトリで切る理由: 将来別の Sphinx 拡張（例: 独自ディレクティブ）を
足したくなったときの拡張点を確保する。リポジトリ全体の構造的にも
`docs/repository-structure.md` §5 を 1 行追記するだけで済む。

### 1.2 conf.py への変更箇所

未コミットの WIP（setup() 内の OGP/baseurl 改修）と**完全に別 region** にする:

- ファイル冒頭の `import os` 直後に `import sys` と `sys.path.insert(0, os.path.abspath("_ext"))` を追加。
- `extensions = [...]` リストの末尾に `"rescript_lexer"` を追加。

これにより `def setup(app)` 本体を一切変更しない。`rescript_lexer.py` 側で
`def setup(app)` を独自に定義し、Sphinx が自動的に両方を呼ぶ仕組みを利用する。

## 2. RescriptLexer 設計

### 2.1 ベースクラス

`pygments.lexer.RegexLexer` を継承する。Pygments 同梱の `ReasonLexer` / `OcamlLexer` は
ML 系の構文に特化していて ReScript 特有の `@annotation` / JSX / template literal / `dict`
キーワード等をカバーしていないため、独立した RegexLexer サブクラスとして実装する。

### 2.2 lexer メタデータ

| 属性 | 値 |
|---|---|
| `name` | `"ReScript"` |
| `aliases` | `["rescript", "res", "resi"]` |
| `filenames` | `["*.res", "*.resi"]` |
| `mimetypes` | `["text/x-rescript"]` |

`aliases` に `resi` も含めることで `.resi` ファイル抜粋のフェンスにも対応。

### 2.3 トークンマップ（IntelliJ プラグイン参照）

`Rescript.flex` と `RescriptSyntaxHighlighter.kt` の対応関係を Pygments token に落とし込む:

| IntelliJ token | Pygments token | 備考 |
|---|---|---|
| `KEYWORDS` (let/if/switch/match/...) | `Keyword` | flex 86–144 行 |
| `mod` / `land` / `lor` / `lxor` / `lsl` / `lsr` / `asr` | `Keyword` | flex 146–152 行（演算子キーワード） |
| `unit` / `ref` / `option` / `list` / `dict` | `Keyword.Type` | builtin 型名 |
| `true` / `false` / `None` / `Some` | `Keyword.Constant` | builtin constant |
| `STRING_VALUE` (`"..."`) | `String.Double` | エスケープシーケンス対応 |
| Template literal (`` `...` ``) | `String.Backtick` + `String.Interpol` で `${}` | flex 277–286 行 |
| `CHAR_VALUE` (`'a'`) | `String.Char` | flex 170 行 |
| `INT_VALUE` (DEC/HEX/OCT/BIN) | `Number.Integer` / `Number.Hex` / `Number.Oct` / `Number.Bin` |
| `FLOAT_VALUE` | `Number.Float` |
| `SINGLE_COMMENT` (`//`) | `Comment.Single` |
| `MULTI_COMMENT` (`/* */`) | `Comment.Multiline` | ネスト対応 |
| `TYPE_ARGUMENT` (`'a`) | `Name.Variable` |
| `POLY_VARIANT` (`#Foo`/`#bar`) | `Name.Tag` |
| `UIDENT` (`Module`) | `Name.Class` | モジュール名 / バリアントコンストラクタ |
| `ARROBASE` + `ANNOTATION_NAME` (`@module`) | `Name.Decorator` | `@some.path` 形式 |
| `OPERATORS` (`+`, `-`, `=>`, `->`, `<-`, `|>`, `++`, `==`, `===`, etc.) | `Operator` |
| JSX タグ (`<Foo`, `</Foo>`, `/>`) | `Name.Tag` / `Punctuation` | 簡易対応 |
| `LBRACE` / `RBRACE` / `LBRACKET` / `RBRACKET` / `LPAREN` / `RPAREN` / `,` / `;` / `.` / `:` | `Punctuation` |
| `LIDENT` | `Name` | 識別子（変数 / 関数） |
| `BAD_CHARACTER` | `Error` |

### 2.4 状態遷移

`RegexLexer.tokens` ディクショナリで以下の状態を持つ:

- `root` — 通常の ReScript ソース
- `comment` — `/* ... */` 内（ネスト対応のため `#push` / `#pop`）
- `string` — `"..."` 内
- `template` — `` `...` `` 内
- `interp` — `` `${...}` `` の `${` 〜 `}` 内（`root` を include して再帰）

これで以下が正しく動作する:
- 文字列内に `let` が出現してもキーワード扱いされない。
- `/* let x = /* nested */ 1 */` のネストコメント。
- `` `hello ${name}` `` の `${}` 内が ReScript として再ハイライトされる。

### 2.5 「IDENT の後の `<` は JSX ではない」問題

flex の `AFTER_IDENT` 状態は context-sensitive な JSX 検出のため。Pygments の
RegexLexer は完全な状態機械を持つので、以下の妥協を行う:

- `<` の直後が大文字または小文字英字なら **JSX タグ開始候補** として `Name.Tag` で
  ハイライトし、`>` まで簡易マッチ。
- これは識別子の直後でも JSX 扱いになる誤検出を含むが、ドキュメントコード例では
  `arr[i]<count` のような比較は稀で、可読性への影響は最小限と判断。
- 100% 正確な JSX 検出が必要になった場合の対応は本ステアリングの非ゴール。

### 2.6 Regex の優先順位

トークンマッチは記述順なので、以下の順で並べる:

1. 空白 / 改行
2. 単行コメント `//` → 複数行コメント `/*`
3. annotation `@foo.bar`
4. 数値リテラル（hex/oct/bin → float → int の順で長一致優先）
5. 文字リテラル `'a'`（型引数 `'a` と区別: 後ろが `'` で閉じるか）
6. 型引数 `'lowercase[0-9_]*`
7. poly variant `#Foo` / `#bar`
8. キーワード（`words()` で正確一致、`prefix=r'\b'` / `suffix=r'\b'`）
9. 大文字始まり識別子 → `Name.Class`
10. 小文字始まり識別子 → `Name`
11. 文字列開始 `"` / template `` ` ``
12. 演算子（長一致優先: `===` → `==` → `=`、`!==` → `!=` → `!`、`<=` → `<-` → `<`、etc.）
13. JSX タグ `<Foo` / `</Foo` / `/>`
14. punctuation

## 3. テスト戦略

### 3.1 lexer の単体テスト

`sphinx-docs/tests/test_rescript_lexer.py` に以下を追加:

```python
from pygments.token import Comment, Keyword, Name, Number, Operator, Punctuation, String

# Sphinx 経由ではなく直接 lexer を import してトークン列を assert
from _ext.rescript_lexer import RescriptLexer

def _tokenize(source: str):
    lexer = RescriptLexer()
    return [(tok, value) for tok, value in lexer.get_tokens(source) if value.strip()]

def test_let_binding():
    tokens = _tokenize('let x = 42')
    assert (Keyword, 'let') in tokens
    assert (Name, 'x') in tokens
    assert (Operator, '=') in tokens
    assert (Number.Integer, '42') in tokens

def test_string_with_keyword_inside():
    tokens = _tokenize('let s = "let y = 1"')
    # 文字列内の "let" はキーワードにならない
    assert (Keyword, 'let') in tokens  # 最初の let
    assert all(value != 'let' or tok == Keyword for tok, value in tokens if tok == Keyword)
    # 文字列がトークンに含まれること
    string_tokens = [v for t, v in tokens if t in (String, String.Double)]
    assert any('let y = 1' in v for v in string_tokens)

def test_multiline_comment_nested():
    tokens = _tokenize('/* outer /* inner */ outer-end */')
    comment_text = ''.join(v for t, v in tokens if t.parent is Comment or t is Comment.Multiline)
    assert 'inner' in comment_text

def test_annotation():
    tokens = _tokenize('@module("foo")')
    assert any(t is Name.Decorator and '@module' in v for t, v in tokens)

def test_poly_variant():
    tokens = _tokenize('let x = #Red')
    assert (Name.Tag, '#Red') in tokens

def test_type_argument():
    tokens = _tokenize("type t<'a> = list<'a>")
    assert (Name.Variable, "'a") in tokens

def test_module_uppercase():
    tokens = _tokenize('Console.log("hello")')
    assert (Name.Class, 'Console') in tokens

def test_template_literal():
    tokens = _tokenize('`hello ${name}!`')
    template_strings = [v for t, v in tokens if t in (String.Backtick,)]
    assert any('hello ' in v for v in template_strings)

def test_lexer_registered_as_rescript():
    """lexer alias 'rescript' で Pygments から引けることを Sphinx setup 経由で確認"""
    # sphinx-docs/_ext/rescript_lexer.py の setup() が呼ばれる経路は
    # 別途 sphinx 統合テストでカバー。ここでは alias 属性のみ確認。
    assert 'rescript' in RescriptLexer.aliases
    assert 'res' in RescriptLexer.aliases
```

### 3.2 ビルド検証

`cd sphinx-docs && make build` で warning なくビルドが完了することを確認。
warning が出る場合は `linkcheck_ignore` / `suppress_warnings` に該当しないか調査。

`_build/html/user/quickstart.html` を grep して `<span class="k">let</span>` が
存在することを確認:

```bash
grep -o '<span class="k">let</span>' _build/html/user/quickstart.html | head -1
```

## 4. リスクと緩和策

| リスク | 緩和策 |
|---|---|
| Pygments の RegexLexer は状態機械の表現力が限定的で、context-sensitive な構文（`<` が比較か JSX か）を完全には判別できない | 簡易ルール（`<` の直後が文字なら JSX 候補）で十分。ドキュメント例では稀。完全な対応は非ゴール |
| ネストコメントの実装漏れ | `RegexLexer` の `#push` / `#pop` で対応。テストでカバー |
| 既存ページの表示が変わって視覚的にレグレッション | 差分は色付与のみ。レイアウト崩れは起きない |
| sphinx-docs/conf.py の WIP（未コミット OGP/baseurl 改修）と競合 | 変更箇所を `extensions = [...]` 周辺に局所化し、`setup()` 本体は触らない |
| disk usage 93% で追加 install 不可 | pygments / sphinx は既に uv.lock に含まれており追加 install 不要。lexer は純 Python で in-repo に配置 |

## 5. ロールバック計画

問題が発覚した場合の戻し方:

1. `conf.py` の `extensions` から `"rescript_lexer"` を削除
2. `sys.path.insert` 行を削除
3. `_ext/` ディレクトリと `tests/test_rescript_lexer.py` を削除
4. Pygments は `rescript` を unknown lexer として扱い、ハイライトなし（元の状態）に戻る

## 6. 完了後のドキュメント更新

- `docs/repository-structure.md` §5 sphinx-docs ツリーに `_ext/` ディレクトリと
  目的を追記。
- 追加した lexer 自体は `sphinx-docs` のユーザーガイドからは見えないため、ユーザー
  向けドキュメント (`sphinx-docs/user/`) の追記は不要。
