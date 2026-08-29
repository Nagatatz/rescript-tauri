# Design: sphinx-docs JA 完全翻訳

| 項目 | 内容 |
|---|---|
| 作成日 | 2026-05-12 |
| 関連 | requirements.md |

## 1. アプローチ

### 1.1 翻訳方針

- **直訳より自然な日本語訳** を優先（過去 steering 050 / 006 の方針を踏襲）
- 既存翻訳済み msgstr のトーン（です・ます調、技術用語は英字併記）に揃える
- コード識別子 / モジュール名 / API 名はそのまま英字（例: `invoke`, `Channel`, `WebviewWindow`）
- インラインコード ``` ``code`` ``` / リンク `:doc:`...`` / 参照 ``:ref:`...`` は **改変しない**
- プレースホルダ `{0}`, `%(name)s`, `\n` 等の特殊記号も維持

### 1.2 ファイル順序

未翻訳件数の多い順に処理（バーンダウンで進捗が分かりやすい）:

1. plugin-http (85) → plugin-shell (73) → plugin-clipboard-manager (51)
2. changelog (34) → plugin-log (25) → plugin-notification (21) → plugin-os (19)
3. schema (16) → plugin-fs (12) → dev/architecture (11) → quickstart (10)
4. dev/building / user/configuration / user/index / plugin-dialog / dev/contributing (各 9)
5. dev/index (5) → installation (4) → dev/setup (3) → dev/project-structure (3) → index (2)

### 1.3 commit 粒度

- **1 ファイル = 1 commit** （21 commit）
- commit メッセージ: `📝 Translate sphinx-docs/locale/ja/.../<file>.po`
- 最終 commit: `📝 Mark steering 20260512-001 tasklist complete`
- すべての commit が green commit（このディレクトリは `.po` ファイルのみで build 影響なし、tests も unaffected）

## 2. worktree 戦略

ビルトイン worktree 機能で `worktree-sphinx-docs-ja-full-translation` ブランチを作成。
ベース: 最新の origin/main（fresh ベース、未 push commit なし確認済み）。

## 3. 翻訳手順（1 ファイルあたり）

1. `.po` ファイルを Read で全体取得
2. 未翻訳 entry（`msgstr ""` の直前 `msgid` 値）を抽出
3. Edit で msgstr に日本語訳を埋め込む（複数行は ` "..." \n "..."` 形式維持）
4. ファイル全体で `msgstr ""` 残存がヘッダ 1 件のみであることを確認（`grep -c '^msgstr ""' <file>` で検証）
5. tasklist.md の該当タスクを `[x]` に更新
6. commit（ファイル + tasklist.md）

## 4. 検証

### 4.1 ファイル単位検証

```bash
# 未翻訳カウント（ヘッダ除く 0 件を期待）
for f in $(find sphinx-docs/locale/ja -name "*.po"); do
  empty=$(awk '/^msgid "/{flag=1; msgid=""} /^msgstr "/{flag=0; if($0 == "msgstr \"\"" && msgid != "msgid \"\"") empty++} flag{msgid=$0}END{print empty+0}' "$f")
  echo "$empty  $f"
done | sort -rn
```

### 4.2 全体検証（最終 commit 前）

```bash
# Sphinx 日本語ビルド
cd sphinx-docs
uv sync
SPHINXOPTS="-D language=ja" make html
```

### 4.3 構造検証

- msgstr 値内のコード ``` ``...`` ``` / `:doc:` / `:ref:` / `{0}` / `\n` などが msgid と整合している
- 改行コード（複数行 msgstr）の構造が msgid と同じ

## 5. リスク・回避策

| リスク | 回避策 |
|---|---|
| 大規模 commit で中断発生時に作業ロスト | 1 ファイル = 1 commit の checkpoint 戦略 |
| 翻訳品質のばらつき | 既存翻訳済みファイルをトーンの参考にする、技術用語は英字維持 |
| msgid プレースホルダの破壊 | 各 Edit 後に grep で構造確認 |
| `.mo` の stale 化 | コミット対象は `.po` のみ。Sphinx ビルド時に自動再生成 |
| ファイル順による意味的依存 | `.po` ファイルは独立しているため依存なし |

## 6. 並列化判断

並列実装（parallel-implementation-swarm）は **採用しない**:

- 全 21 ファイルが同一ディレクトリ配下で軽量編集
- 各ファイル独立だが、coordinator overhead が単一セッションの逐次処理より大きい
- ファイル単位 commit による checkpoint で十分な障害耐性
