# Design — sphinx-docs top page plugin widget

| 項目 | 内容 |
|---|---|
| Steering ID | 20260513-001 |
| 関連 | [requirements.md](./requirements.md) |

## 1. Widget 構造

### 1.1 配置

`sphinx-docs/index.md` の以下の順序に変更する:

```
# rescript-tauri
(intro paragraph)
(note admonition)

::::{grid} 1 1 2 2   ← 既存の User Guide / Developer Guide grid
:::: (略)

## Plugins & add-ons            ← 新規セクション
(short intro paragraph)
::::{grid} 1 2 2 3              ← 新規 grid (9 cards)
::::

## Quick Links                  ← 既存
- ...

```{toctree}                    ← 既存
:hidden:
:maxdepth: 2
user/index
dev/index
```
```

### 1.2 Grid card 仕様

- `:::{grid} 1 2 2 3` — モバイル 1 列 / sm 2 列 / md 2 列 / lg 3 列。9 cards なので最終列に 1 card の余りが出るが、Sphinx の grid は自動で左寄せされ視覚的に問題ない。
- 各カードのフォーマット:

```rst
:::{grid-item-card} plugin-fs
:link: user/plugin-fs
:link-type: doc

Filesystem operations (read / write / dir / stat).
:::
```

- カードのタイトルは `plugin-fs` 形式（`@rescript-tauri/` プレフィックス無し）。これは User Guide の Table から `@rescript-tauri/` を外し、視覚的にコンパクトにするため。
- 本文は user/index.md の Purpose 列をそのまま流用する。

### 1.3 カード一覧

| Title | Body | Link |
|---|---|---|
| plugin-fs | Filesystem operations (read / write / dir / stat). | `user/plugin-fs` |
| plugin-dialog | Native dialogs (open / save / message / ask / confirm). | `user/plugin-dialog` |
| plugin-notification | Native notifications (toast / schedule / channels). | `user/plugin-notification` |
| plugin-shell | Spawn child processes, open URLs / files with the OS default. | `user/plugin-shell` |
| plugin-log | Structured logging (5 levels + log-stream listeners). | `user/plugin-log` |
| plugin-os | OS info (platform / arch / family / locale / hostname). | `user/plugin-os` |
| plugin-clipboard-manager | Clipboard read/write (text / image / HTML). | `user/plugin-clipboard-manager` |
| plugin-http | HTTP fetch with CORS bypass + proxy / TLS config. | `user/plugin-http` |
| schema | Layer 3 typed IPC via `rescript-schema`. | `user/schema` |

カードの並び順は `sphinx-docs/user/index.md` の Add-on packages テーブルと一致させる (既存読者の認知負荷を下げるため)。

## 2. Sphinx 拡張の確認

`sphinx-docs/conf.py` に `sphinx_design` extension が既に有効化されていることを確認する。既存の grid card が稼働しているので追加導入は不要 (確認のみ)。

## 3. ja .po 同期

### 3.1 手順

1. `cd sphinx-docs && uv run make update-po` で `locale/ja/LC_MESSAGES/index.po` を再生成。
2. 新規 msgid (8 plugin 名 + 9 purpose + 9 リンク + 見出し "Plugins & add-ons" + intro 文) に対応する msgstr を翻訳記入。
3. fuzzy マーカーがあれば、内容を確認した上で除去 (msgid と msgstr が乖離していないことが前提)。

### 3.2 訳語の統一

`sphinx-docs/locale/ja/LC_MESSAGES/user/index.po` の既存訳をそのまま流用する。具体的には:

| en | ja |
|---|---|
| `Plugins & add-ons` | `プラグインとアドオン` |
| Filesystem operations (read / write / dir / stat). | (user/index.po の同訳を流用) |
| Native dialogs (open / save / message / ask / confirm). | (流用) |
| ...各 plugin の purpose | (流用) |

`user/index.po` 側の Purpose msgid 末尾には句点が無いケースがあるため、新規 card 用の `<purpose>.` (末尾ピリオド付き) は別 msgid となる。新 msgid に対して `<日本語訳>。` の形で msgstr を入れる。

## 4. ビルド検証

```bash
cd sphinx-docs
uv run make html                                  # en build
uv run make -e SPHINXOPTS="-D language=ja" html   # ja build
```

両方 warning 0 で成功すること。`_build/html/index.html` を grep し、9 plugin のリンクが含まれることを確認。

## 5. リスクと緩和

| リスク | 緩和策 |
|---|---|
| grid 列数とカード数のミスマッチで最終行が崩れる | `1 2 2 3` の breakpoint を採用し 9 cards (= 3×3) を綺麗に並べる |
| 翻訳の食い違いで sphinx-build が fuzzy 警告を出す | `make update-po` 後に grep `#, fuzzy` で残存ゼロを確認 |
| `user/index.md` 側の table と表示が二重化して冗長 | top はカード型サマリー、user/index は table 型詳細という役割分担で冗長性を許容する (top にも user にも 9 plugin を見せたい) |

## 6. Out of scope (確認)

- README.md トップ — 別 PR。
- plugin 個別ページの再構成 — 触らない。
- `sphinx-docs/user/index.md` の table — 触らない (top と user で重複表示で良い)。
