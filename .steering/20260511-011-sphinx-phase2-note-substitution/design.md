# Design: Phase 2 pre-release note を MyST substitution で一元化

| 項目 | 内容 |
|---|---|
| ステアリング番号 | 20260511-011 |
| 関連 | requirements.md |

---

## 1. 影響ファイル

### 編集 (10 ファイル)

```
sphinx-docs/conf.py                                  # substitution extension 有効化 + 定義追加
sphinx-docs/user/plugin-fs.md
sphinx-docs/user/plugin-dialog.md
sphinx-docs/user/plugin-notification.md
sphinx-docs/user/plugin-shell.md
sphinx-docs/user/plugin-log.md
sphinx-docs/user/plugin-os.md
sphinx-docs/user/plugin-clipboard-manager.md         # 最初の {note} のみ
sphinx-docs/user/plugin-http.md
```

### `.po` 再生成 (auto)

`make update-po` 後に以下が更新される見込み:

```
sphinx-docs/locale/ja/LC_MESSAGES/user/plugin-fs.po           # 旧 note msgid が消え新 msgid 追加
sphinx-docs/locale/ja/LC_MESSAGES/user/plugin-dialog.po       # 同上
sphinx-docs/locale/ja/LC_MESSAGES/user/plugin-notification.po
sphinx-docs/locale/ja/LC_MESSAGES/user/plugin-shell.po
sphinx-docs/locale/ja/LC_MESSAGES/user/plugin-log.po
sphinx-docs/locale/ja/LC_MESSAGES/user/plugin-os.po
sphinx-docs/locale/ja/LC_MESSAGES/user/plugin-clipboard-manager.po
sphinx-docs/locale/ja/LC_MESSAGES/user/plugin-http.po
```

## 2. `conf.py` の変更

### Before

```python
myst_enable_extensions = [
    "colon_fence",
    "deflist",
    "fieldlist",
    "attrs_inline",
]
```

### After

```python
myst_enable_extensions = [
    "colon_fence",
    "deflist",
    "fieldlist",
    "attrs_inline",
    "substitution",
]

myst_substitutions = {
    "phase_2_note": (
        "The Phase 2 implementation of this package is feature-complete in "
        "`main`. Its first npm publish is scheduled alongside the other "
        "Phase 2 packages. Until then, consume it via the source repository "
        "or a workspace link."
    ),
}
```

挿入位置: `myst_enable_extensions` の直後に `myst_substitutions` を続けて配置（関連設定をひとまとめにする）。

## 3. 各 plugin ユーザーガイドの変更

### Before（plugin-fs.md の例）

```markdown
```{note}
The Phase 2 implementation is feature-complete in `main`. The
first npm publish (`plugin-fs-v0.1.0`) is scheduled alongside the
other Phase 2 packages. Until then, consume
`@rescript-tauri/plugin-fs` via the source repository or a
workspace link.
```
```

### After

```markdown
```{note}
{{ phase_2_note }}
```
```

`{note}` directive はそのまま、本文を substitution 参照に置換。

### plugin-clipboard-manager.md の特殊性

このファイルには `{note}` ブロックが 2 つある:

1. **L7-13**: Phase 2 pre-release boilerplate → **置換対象**
2. **L186-192**: Android / iOS で `writeImage` / `readImage` が未サポートの注意 → **対象外**

L186-192 はパッケージ固有の content であり、本ステアリングのスコープに含まれない。

## 4. `.po` 取扱い

### 4.1 旧 msgid（package 名入りの文章）の扱い

`make update-po` 実行時、旧 msgid は MD ソースから消えるため、`.po` には `#~ msgid "..."` 形式のコメントアウト obsolete エントリとして残るか、完全に削除される（sphinx-intl の挙動による）。obsolete として残る場合は、自動的な無害化のみで追加対応不要。

### 4.2 新 msgid の翻訳

新 msgid（"The Phase 2 implementation of this package is feature-complete in `main`. ..."）について:

- 8 つの plugin ガイドそれぞれの `.po` に追加されることが見込まれる（rendered 後の文字列が抽出されるため）
- 既訳のある plugin-fs.po / plugin-dialog.po については、旧訳の文面を新 msgid 用に編集して転写（"this package" / "it" の用法に合わせて再構成）
- 他 6 ファイル（plugin-shell / notification / log / os / clipboard-manager / http）は今日のステアリングで生成されたばかりで、note の msgstr は空のまま。新 msgid 用にも空のままで OK（fallback で英語表示）

### 4.3 共有 msgid 化されるか？

MyST substitution の gettext 挙動を実機検証する。理想:

- conf.py 内の `myst_substitutions["phase_2_note"]` が単一の msgid として `sphinx-docs/locale/ja/LC_MESSAGES/sphinx.po` 等に登場
- 8 plugin ガイドの .po には登場せず、参照のみ

これが叶うなら .po 重複も削減できるが、Sphinx のバージョンによっては各ファイルで rendered text が抽出される（重複あり）。後者の場合でも本ステアリングのゴールは達成される（マスター文面の単一ソース化）。

## 5. テスト戦略

### 5.1 ビルド検証

```bash
cd sphinx-docs
make html 2>&1 | tail -10   # error なし
make build-ja 2>&1 | tail -10
```

### 5.2 HTML 出力検証

各 plugin HTML で note が正しく展開されていることを確認:

```bash
grep -A2 'admonition note' sphinx-docs/_build/html/user/plugin-fs.html | head -3
grep -A2 'admonition note' sphinx-docs/_build/html/user/plugin-http.html | head -3
```

期待: いずれも「The Phase 2 implementation of this package is feature-complete...」の文言が含まれる。

### 5.3 ja 出力検証

```bash
grep -A2 'admonition note' sphinx-docs/_build/html_ja/user/plugin-fs.html | head -3
```

期待: 上記と同じ english 文言（msgstr 空のため fallback）または日本語訳（あれば）が表示される。

## 6. コミット粒度

1. `🔧 Enable MyST substitution and define phase_2_note`
2. `♻️ Replace duplicated phase-2 pre-release notes with substitution`
3. `📝 Refresh .po files after note refactor`
4. （ja 旧訳を新 msgid 用に転写する場合）`📝 Carry over ja translation for refactored phase_2 note`
5. `✅ Mark steering 20260511-011 tasklist complete`

## 7. リスク

- **MyST substitution が gettext で抽出されない**: HTML には正しく出るが gettext PO に msgid として現れないケース。この場合 .po に旧 msgid が obsolete として残り、新文面に対する翻訳は不可能。発生時はビルド出力をログから読み、原因に応じて (a) extension 設定を変更 (b) substitution を諦めて include 方式に切り替える、を判断。
- **rendered 文字列の改行差異**: substitution の文字列を Python 文字列連結で組み立てるため、改行位置が `make update-po` の出力で意図と異なる可能性。比較確認する。
