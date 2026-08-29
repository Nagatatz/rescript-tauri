# Requirements: changelog.po 未翻訳 12 件の翻訳

| 項目 | 内容 |
|---|---|
| ステアリング ID | 20260512-007-translate-changelog-untranslated |
| 起票日 | 2026-05-12 |
| 関連 | steering 20260512-001 (sphinx-docs ja 全翻訳), steering 20260511-022 (po refresh) |

## 1. 背景

ユーザーから「未翻訳の空 msgstr 333 件を翻訳して」と依頼があった。
`grep -c '^msgstr ""'` の表層集計では 320〜359 件がヒットするが、これらの大半は複数行 msgstr の **継続行** (`msgstr ""\n"actual translation"\n...`) であり、実体は翻訳済みである。

`msgfmt --statistics`（GNU gettext 公式判定）による真の未翻訳カウントは以下:

```
sphinx-docs/locale/ja/LC_MESSAGES/user/changelog.po: 67 translated, 12 untranslated.
他全 .po: untranslated = 0
TOTAL: 12 untranslated
```

つまり実質的に **`user/changelog.po` の 12 件** が翻訳対象である。

## 2. スコープ

### In scope

`sphinx-docs/locale/ja/LC_MESSAGES/user/changelog.po` の以下 12 エントリの msgstr に日本語訳を入れる:

| # | 参照行 (changelog.md) | msgid 概要 |
|---|---|---|
| 1 | L117 | `plugin-shell` v2.3.5 stable 100% bindings 説明 |
| 2 | L132 | `plugin-notification` v2.3.3 stable 100% bindings 説明 |
| 3 | L136 | `sendNotification` overload 分割の説明 |
| 4 | L150 | `plugin-log` v2.8.0 stable 100% bindings 説明 |
| 5 | L153 | `LogLevel.t` `@unboxed` polymorphic-variant 説明 |
| 6 | L167 | `plugin-os` v2.3.2 stable 100% bindings 説明 |
| 7 | L170 | `OsType.get` サブモジュール理由 |
| 8 | L177 | `@rescript-tauri/plugin-clipboard-manager` 0.1.0 ヘッダ |
| 9 | L183 | `plugin-clipboard-manager` v2.3.2 stable 100% bindings 説明 |
| 10 | L187 | `readImage` 戻り値型の説明 |
| 11 | L200 | `plugin-http` v2.5.9 stable 100% bindings 説明 |
| 12 | L204 | DOM 型を polymorphic にした理由 |

### Out of scope

- 他の .po ファイルの整備（未翻訳 0 件のため）
- `#~` (obsolete) エントリ
- 翻訳済みエントリのリビジョン
- `index.mo` の再生成（CI で自動生成）

## 3. 受け入れ基準

- [ ] `msgfmt --statistics sphinx-docs/locale/ja/LC_MESSAGES/user/changelog.po` の出力に `untranslated` が含まれない（= 79 translated）
- [ ] 全 .po 合計の `msgfmt --statistics` で `untranslated` が 0 件
- [ ] 翻訳トーンが既存翻訳（package 単位の「実行可能な例 [...]」「peerDependencies: ...」スタイル）と整合
- [ ] バッククォート / コードフェンス / リンク URL を改変しない（msgid と同じトークンを保持）
- [ ] worktree → PR → self-merge → クリーンアップを完遂

## 4. 非機能要件

- ディスク使用率 92% のため大規模ビルド（`pnpm install` / sphinx full build）は実行しない
- `msgfmt --statistics` での検証で十分とする
- 翻訳作業はテキスト編集のみで完結
