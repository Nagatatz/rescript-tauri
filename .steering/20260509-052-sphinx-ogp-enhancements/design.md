# 設計: sphinx-docs OGP 設定の強化

## 1. 全体方針

`sphinx-docs/conf.py` に閉じた変更のみで完結させる。Makefile / 依存関係の変更は不要 (`sphinxext-opengraph` 0.13.0 はすでに導入済み)。

## 2. 設定追加箇所

### 2.1 `conf.py` の Open Graph セクション拡張

既存の `# -- Open Graph (social sharing previews) --` セクションに以下を追加:

```python
# Description length for social previews (default 200; expanded for richer cards)
ogp_description_length = 300
ogp_enable_meta_description = True

# Static custom meta tags (Twitter Card; locale tags are added dynamically in setup()).
ogp_custom_meta_tags = [
    '<meta name="twitter:card" content="summary_large_image" />',
]
```

### 2.2 動的な og:locale 切替 (`setup(app)` フック)

`make build-ja` は `-D language=ja` で `language` を上書きするため、conf.py のモジュールレベルでは
日本語ビルド時の値を確定できない。Sphinx の `config-inited` イベントで上書き後の `config.language`
を読み、`ogp_custom_meta_tags` に locale 用メタを追加する。

```python
def setup(app):
    """Append per-build OGP locale meta tags after Sphinx finalizes config."""

    _OGP_LOCALE_MAP = {
        "en": ("en_US", "ja_JP"),
        "ja": ("ja_JP", "en_US"),
    }

    def _add_locale_meta(_app, config):
        primary, alternate = _OGP_LOCALE_MAP.get(
            config.language, ("en_US", "ja_JP")
        )
        config.ogp_custom_meta_tags = list(config.ogp_custom_meta_tags) + [
            f'<meta property="og:locale" content="{primary}" />',
            f'<meta property="og:locale:alternate" content="{alternate}" />',
        ]

    app.connect("config-inited", _add_locale_meta)
```

**設計判断:**

- `og:locale` 自体も `ogp_custom_meta_tags` 経由で出す — `sphinxext-opengraph` 0.13 は
  `language` から自動で `og:locale` を生成しないため明示的に追加する必要がある。
- 言語コードは `en_US` / `ja_JP` を採用 — Open Graph 仕様 (Facebook) で広く使われている
  IETF BCP 47 互換の `lang_TERRITORY` 形式。
- `_OGP_LOCALE_MAP` を関数内クロージャに置く — モジュールトップを汚染せず、Sphinx の他フック
  との衝突を避ける。

## 3. テスト戦略

`sphinx-docs/tests/test_ogp.py` を新設し、以下を pytest で検証:

| ケース | 期待 |
|---|---|
| `language="en"` でビルド → `_build/html/index.html` を読む | `og:locale.*en_US`, `og:locale:alternate.*ja_JP`, `twitter:card.*summary_large_image` を含む |
| `language="ja"` でビルド → `_build/html_ja/index.html` を読む | `og:locale.*ja_JP`, `og:locale:alternate.*en_US`, `twitter:card.*summary_large_image` を含む |

ビルドは pytest fixture で `subprocess.run(["uv", "run", "sphinx-build", ...])` を呼ぶか、
あるいは `sphinx.application.Sphinx` を直接呼ぶ。後者の方が起動が速いが、
ビルドの再現性 (Makefile と同じ) を優先して subprocess 方式を採用する。

ビルド済み artifact (`_build/html`, `_build/html_ja`) が既に存在する場合は再利用しないでクリーンビルドする
(古い HTML を読んでテストが false-positive になるのを避けるため)。

**テスト実行時間の考慮:** 1 ビルドで数秒程度。en + ja の 2 ビルドで 10〜20 秒程度を許容する。
将来的に遅すぎる場合は `--cache-dir` を活用するが、現状は素直に毎回ビルドする。

## 4. ドキュメント更新

| ファイル | 更新内容 |
|---|---|
| `docs/repository-structure.md` | 変更なし (構造変更なし) |
| `CLAUDE.md` | 変更なし (規約変更なし) |
| `README.md` | 変更なし (ユーザー視点の機能変化なし) |
| `sphinx-docs/` 内ユーザードキュメント | 変更なし (内部実装のみ) |

ステアリングドキュメント (本書) のみを成果物として残す。

## 5. リスク・トレードオフ

- **`setup(app)` の追加** — conf.py の責務がやや増えるが、Sphinx 標準パターンであり許容範囲。
- **ビルドテストの実行時間** — pytest 全体で 10〜20 秒増加。CI でも許容できる範囲。
- **将来 OGP 画像を追加する際** — `ogp_image` を conf.py に追加するだけで対応可能。
  本変更で `ogp_custom_meta_tags` に Twitter Card を入れているため、Twitter Card の
  `twitter:image` も将来追加できる構造になっている。
