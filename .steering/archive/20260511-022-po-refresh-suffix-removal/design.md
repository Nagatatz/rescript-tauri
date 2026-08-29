# Design: plugin-{log,notification,os} 翻訳 .po refresh

## ワークフロー

```
1. cd sphinx-docs
2. make install            # uv sync to ensure .venv has sphinx + sphinx-intl
3. make update-po          # gettext → .pot → sphinx-intl update -l ja
                           #   ↳ refreshes 3 .po files in place
4. 手動で .po を編集して fuzzy/untranslated を埋める
5. make build-ja           # html_ja 生成、warnings: 0 を確認
6. 必要に応じて sphinx-intl stat で進捗確認
```

## msgid 同期の挙動

`sphinx-intl update` の動作:
- 既存 msgstr は維持される（msgid が変わると `fuzzy` フラグ付きで残る）
- 削除された msgid は `obsolete` (`#~`) としてコメント化
- 新規 msgid は `msgstr ""` として追加

## 翻訳対象

steering 020 で変更された .md セクションに対応する範囲のみ:

### plugin-log.po

| 旧 msgid (削除/fuzzy) | 新 msgid (要翻訳) |
|---|---|
| Numeric `LogLevel` constants | `LogLevel.t` variant |
| LogLevel exposes the upstream numeric enum as `int` named constants... | LogLevel exposes the upstream numeric enum as an `@unboxed` variant... |
| The trailing underscores on `debug_` / `info_` / ... | (削除) |
| `LogLevel` constants are suffixed | (セクションごと削除) |
| attachLogger 内のコード比較例 | switch + LogLevel.t 例 |

### plugin-notification.po

| 旧 msgid (削除/fuzzy) | 新 msgid (要翻訳) |
|---|---|
| Numeric enum constants | `Importance` / `Visibility` variants |
| `Importance` and `Visibility` are exposed as `int` named constants... | `Importance.t` and `Visibility.t` are `@unboxed` variants... |
| Importance.default_ / Visibility.private_ の表記 | Importance.Default / Visibility.Private |
| trailing underscores 説明 | (削除) |

### plugin-os.po

| 旧 msgid (削除/fuzzy) | 新 msgid (要翻訳) |
|---|---|
| `osType_()` | `OsType.get()` |
| `type()` renamed to `osType_()` | `type()` lives under the `OsType` submodule |
| Renamed from upstream type() — type is reserved... | Submodule because type is reserved at the top level... |

## 翻訳スタイル

- 既存 .po の語彙 / トーンを踏襲: 「〜です・〜ます」調 + 専門用語は英語のまま (`@unboxed` / `variant` / `polymorphic variant` 等)
- 既存翻訳済みエントリの語尾を観察し（`〜してください` / `〜できます`）合わせる
- コードフェンスは原文のまま（翻訳対象外）

## 検証

```bash
cd sphinx-docs
make build-ja
# 期待: warnings: 0, build succeeded.

# untranslated を再確認
uv run sphinx-intl stat -l ja
# 期待: plugin-{log,notification,os} で untranslated: 0
```

## リスク

- `sphinx-intl update` が既存翻訳に予期せぬ fuzzy フラグを付ける可能性 → 既存翻訳済みの msgid に fuzzy が付いたら、内容が同じなら fuzzy を外す
- .pot 生成中に sphinx 警告が出ると msgid が部分的に取れないことがある → ログを確認
- uv install で大きな依存ダウンロード → ディスク 92% 使用中なので空き確認
