# 設計: sphinx-docs 英日 2 箇国語化（フル）

| 項目 | 内容 |
|---|---|
| 関連 | `requirements.md` |
| 作成日 | 2026-05-08 |

## 1. 派生決定の確定（要承認）

requirements.md §4 に対し、本設計で以下を採用する:

| § | 採用 | 内容 |
|---|---|---|
| 4.1 placeholder 値 | requirements.md 表どおり | `rescript-tauri` / `Nagatatz and rescript-tauri contributors` / GitHub URL / `https://nagatatz.github.io/rescript-tauri/` |
| 4.2 コンテンツ深度 | **案 A** | 各 `.md` 50–150 行、要点 + 詳細は `docs/` や `CONTRIBUTING.md` にリンク委譲 |
| 4.3 翻訳トーン | **案 A** | です・ます調、技術用語は英語のまま、コードブロック内は翻訳しない |
| 4.4 quickstart の API サンプル | **案 A** | "Phase 1 リリース後の予定 / target API" 注記入りで設計上の最終形を示す |

## 2. ファイル別変更方針

### 2.1 `sphinx-docs/conf.py`

| 行 | before | after |
|---|---|---|
| 6 | `project = "{{PROJECT_NAME}}"` | `project = "rescript-tauri"` |
| 7 | `copyright = "2026, {{AUTHOR}}"` | `copyright = "2026, Nagatatz and rescript-tauri contributors"` |
| 8 | `author = "{{AUTHOR}}"` | `author = "Nagatatz and rescript-tauri contributors"` |
| 59 | `"source_repository": "{{GITHUB_URL}}",` | `"source_repository": "https://github.com/Nagatatz/rescript-tauri",` |
| 65 | `"url": "{{GITHUB_URL}}",` | `"url": "https://github.com/Nagatatz/rescript-tauri",` |
| 97 | `html_baseurl = ""` | `html_baseurl = "https://nagatatz.github.io/rescript-tauri/"` |
| 99 | `ogp_site_name = "{{PROJECT_NAME}}"` | `ogp_site_name = "rescript-tauri"` |

`html_baseurl` の TODO コメント（line 96 の `# TODO: ...`）は削除し、代わりに `# Set via SPHINX_SITE_PREFIX env var if deploying under a subpath; see html_context below.` のような注記に置き換える。

### 2.2 `sphinx-docs/pyproject.toml`

| 行 | before | after |
|---|---|---|
| 2 | `name = "{{PROJECT_NAME_SLUG}}-docs"` | `name = "rescript-tauri-docs"` |
| 4 | `description = "Sphinx documentation for {{PROJECT_NAME_SLUG}}"` | `description = "Sphinx documentation for rescript-tauri"` |

### 2.3 `sphinx-docs/index.md`（landing）

章立て:

```
# rescript-tauri

(1 段落) Production-ready ReScript bindings for Tauri 2.x's official JS SDK
(grid card 2 つ) User Guide / Developer Guide
(Quick Links) Installation / Quick Start / Configuration / Changelog
(toctree, hidden, depth 2) user/index, dev/index
```

placeholder の `{{PROJECT_NAME}}` / `{{PROJECT_DESCRIPTION}}` を確定値に置換し、grid-item-card の `Description` 文を「ReScript で Tauri 2.x のフロントエンドを書くためのバインディング集」相当に書き換え。

### 2.4 `sphinx-docs/user/index.md`（User Guide TOC）

「rescript-tauri を使い始めるためのガイド」サマリ + 既存 TOC（`installation` / `quickstart` / `configuration` / `changelog`）。`{{PROJECT_NAME}}` を解消するだけで構造はほぼ維持。

### 2.5 `sphinx-docs/user/installation.md`

| セクション | 内容 |
|---|---|
| Status banner | "Not yet published. Phase 1 release で publish 予定。" |
| Requirements | Tauri 2.x / ReScript >= 12 / `@rescript/core` >= 1.6 / Node Active LTS / pnpm >= 9 / Linux/macOS/Windows |
| Install (planned) | `pnpm add @rescript-tauri/core @tauri-apps/api` |
| `rescript.json` setup | `dependencies` に `@rescript-tauri/core` を追加 |
| Verify | Phase 1 リリース後に追加予定の旨 |
| Troubleshooting | Phase 1 リリース後に充実予定 |

README §Compatibility と §Installation の内容を sphinx-docs フォーマットに移植。

### 2.6 `sphinx-docs/user/quickstart.md`

| セクション | 内容 |
|---|---|
| Status banner | "Target API. 設計上の最終形を示す。実装は Phase 1 で進行中。" |
| Layer 1 sample | `Tauri.Core.Raw.invoke` の例（README と同じコード）|
| Layer 2 sample | `Core.Command.make` + `Core.Command.invoke` の例 |
| Event 購読 sample | `Event.make` + `Event.listen` の例 |
| Next steps | Configuration / docs/functional-design.md へリンク |

### 2.7 `sphinx-docs/user/configuration.md`

| セクション | 内容 |
|---|---|
| `rescript.json` 設定 | `dependencies` に `@rescript-tauri/core` を追加。namespace は任意 |
| `peerDependencies` | `@tauri-apps/api ^2.0.0`, `rescript >=12.0.0`, `@rescript/core >=1.6.0` |
| 互換マトリクス | Tauri 2.x / ReScript >= 12 / Node LTS / 3 OS |
| 上位 `Tauri` モジュール | `open Tauri` で `Core` / `Event` / `Window` 等にアクセス可能（functional-design §2.13）|

### 2.8 `sphinx-docs/user/changelog.md`

現状の Unreleased + テンプレートをほぼ維持。`{{PROJECT_NAME}}` 系の placeholder はないが、「Phase 1 リリース時にここに記載」という案内を冒頭に追加。

### 2.9 `sphinx-docs/dev/index.md`（Developer Guide TOC）

「sphinx-docs 自身および rescript-tauri リポジトリへのコントリビュート方法」サマリ + 既存 TOC。

### 2.10 `sphinx-docs/dev/setup.md`

`sphinx-docs/` 自体の開発環境セットアップ。既存の uv / Python / Node 要件を維持し、`{{PROJECT_NAME_SLUG}}` / `{{GITHUB_URL}}` を解消。`Clone the Repository` セクションは `git clone https://github.com/Nagatatz/rescript-tauri.git && cd rescript-tauri/sphinx-docs` の流れに修正。

### 2.11 `sphinx-docs/dev/building.md`

| セクション | 内容 |
|---|---|
| Build commands | Makefile の主要ターゲットを表で列挙: `make install` / `make html` / `make build-ja` / `make build-all` / `make serve` / `make liveserve` / `make linkcheck` / `make pagefind` / `make lint` / `make test` |
| Output | `_build/html/` (en), `_build/html_ja/` (ja), `_build/site/` (assembled) |
| CI Pipeline | `.github/workflows/docs.yml` が active で動作中。push / PR (`sphinx-docs/**`) で lint + test、main push で Pages デプロイ |

### 2.12 `sphinx-docs/dev/architecture.md`

rescript-tauri リポジトリの**簡易アーキテクチャサマリ** + `docs/architecture.md` への深堀りリンク。

| セクション | 内容 |
|---|---|
| Overview | モノレポ構造、`@rescript-tauri/core` 中心、3-layer IPC |
| Key components | `packages/core` (Phase 1) / `packages/plugin-*` (Phase 2+) / `packages/schema` (Phase 2) / `examples/*` |
| Design principles | Idiomatic ReScript / Faithful to Tauri / Three-layer IPC / Maintainable monorepo (README ハイライトと整合) |
| Deep dive | `docs/architecture.md` (Japanese, internal) へリンク |

### 2.13 `sphinx-docs/dev/project-structure.md`

`docs/repository-structure.md` の簡易版。トップレベル構造図 + 詳細は `docs/repository-structure.md` へリンク。

### 2.14 `sphinx-docs/dev/contributing.md`

ルート `CONTRIBUTING.md` への redirect が主目的。sphinx-docs 固有の貢献（翻訳、誤字修正、コンテンツ追加）の流れを補足。

| セクション | 内容 |
|---|---|
| Where to start | ルート `CONTRIBUTING.md` を参照（GitHub URL でリンク）|
| sphinx-docs 固有の貢献 | i18n（`.po` 翻訳）、誤字修正、コンテンツ充実 |
| Branch naming / commit style | ルート `CONTRIBUTING.md` §3.1 / §3.2 を参照 |
| Build before PR | `make lint && make build-all` を実行してから PR |

## 3. 翻訳の進め方

### 3.1 `.po` 生成

```bash
cd sphinx-docs
make update-po       # gettext (.pot) → .po (locale/ja/LC_MESSAGES/)
```

`gettext_compact = False` 設定により、ソース 1 ファイルに対し 1 `.po` ファイルが生成される（合計 12 `.po`）。

### 3.2 `.po` のフォーマット

各 msgid に対し msgstr を日本語で埋める:

```po
#: ../../user/installation.md:5
msgid "Requirements"
msgstr "要件"

#: ../../user/installation.md:7
msgid "Tauri 2.x or later"
msgstr "Tauri 2.x 以降"
```

### 3.3 翻訳ルール

- **トーン**: です・ます調
- **技術用語**: 英語のまま（Layer 1 (Raw), polymorphic variant, peerDependencies, IPC, Channel, Event, Window 等）
- **コードブロック**: 翻訳しない（msgid に含まれる場合は msgstr に同じものをコピー）
- **URL / リンク**: 翻訳しない（テキスト部分のみ翻訳）
- **見出し**: 日本語化（例: "Quick Start" → "クイックスタート", "Installation" → "インストール"）
- **既存の docs/glossary.md** に定義されている用語は同じ訳語を使う

### 3.4 翻訳工数の見積

| ファイル | 想定 msgid 数 | 想定行数 |
|---|---|---|
| `index.md` | 10–15 | ~15 |
| `user/index.md` | 5–10 | ~10 |
| `user/installation.md` | 25–40 | ~50 |
| `user/quickstart.md` | 30–50 | ~80 |
| `user/configuration.md` | 15–25 | ~30 |
| `user/changelog.md` | 5–10 | ~10 |
| `dev/index.md` | 5–10 | ~10 |
| `dev/setup.md` | 30–40 | ~50 |
| `dev/building.md` | 30–40 | ~50 |
| `dev/architecture.md` | 20–30 | ~40 |
| `dev/project-structure.md` | 10–15 | ~20 |
| `dev/contributing.md` | 15–20 | ~30 |
| **合計** | **~250–350** | **~400** |

合計 400 行程度の翻訳。`.po` ファイルとしてはこれにメタデータ・コメント行が加わる。

## 4. コミット粒度

`git-conventions.md` の「1 コミット = 1 論理的変更」に従い分割:

| # | コミット | 内容 |
|---|---|---|
| 1 | 📝 Add steering for 20260508-004 (sphinx-docs-bilingual) | ステアリング 3 ファイル配置 |
| 2 | 🔧 Resolve sphinx-docs placeholders in conf.py and pyproject.toml | placeholder 解消 + html_baseurl 設定 |
| 3 | 📝 Rewrite sphinx-docs/index.md and user/* with rescript-tauri content | landing + user guide 5 ファイル |
| 4 | 📝 Rewrite sphinx-docs/dev/* with rescript-tauri content | dev guide 6 ファイル |
| 5 | 🌐 Generate Japanese .po files via make update-po | 12 `.po` 配置（msgstr 空のまま）|
| 6 | 🌐 Translate user/* .po files into Japanese | user/ 5 ファイル + index.md = 6 `.po` 翻訳 |
| 7 | 🌐 Translate dev/* .po files into Japanese | dev/ 6 ファイル分 `.po` 翻訳 |
| 8 | ✅ Verify make build-all produces en + ja sites | 動作確認結果を tasklist に記録 |
| 9 | 📝 Mark steering 20260508-004 complete | tasklist 全 [x] 化 + push |

各コミットで `tasklist.md` の該当タスクを `[x]` 化する。

## 5. worktree 運用

ドキュメントのみの追加 + 既存ドキュメントの書き換えのため、`.claude/rules/steering-workflow.md` の worktree 規約（「コード実装」対象）には該当しない。**worktree を省略する**。

ただし変更量が大きく長時間に及ぶため、各コミットで `make lint` を実行し、コミット間の整合性を保つ。`.po` ファイルの大量編集はバッチで進めて 1 コミットにまとめる（コミット 6 / 7）。

## 6. テスト・検証戦略

### 6.1 各コミットでの最小検証

| コミット | 検証 |
|---|---|
| 2 (placeholder) | `grep -rn '{{' sphinx-docs/` が空であること |
| 3 (user/) | `make html` が成功し `_build/html/user/` が生成 |
| 4 (dev/) | `make html` が成功し `_build/html/dev/` が生成 |
| 5 (.po 生成) | `ls sphinx-docs/locale/ja/LC_MESSAGES/*.po` が 12 ファイル |
| 6/7 (翻訳) | `make build-ja` が成功し `_build/html_ja/` が生成 |
| 8 (build-all) | `make build-all` が成功し `_build/site/{en,ja}/index.html` が両方存在、Pagefind が `_build/site/pagefind/` を生成 |

### 6.2 最終検証

- `make linkcheck` で broken link なし（外部 URL の一時的不達は許容）
- `make lint` (ruff) が pass
- `make test` (pytest) が pass（既存テストがあれば）
- `_build/site/index.html` が `/en/` への redirect を含む

### 6.3 検証失敗時の対応

3 回修正しても解決しない場合はユーザーに報告（`.claude/rules/testing.md` 自己検証フロー準拠）。

## 7. リリース判定への影響

本ステアリング完了で `README.md` Visibility ブロックの 5 条件への直接影響はない（sphinx-docs はリスト外）。ただし visibility 切替時に GitHub Pages を有効化する前提条件（コンテンツが存在する）を満たす。

| visibility 切替条件 | 状態 |
|---|---|
| LICENSE | ✅ 既達 |
| CONTRIBUTING.md | ✅ 既達 (steering 003) |
| `@rescript-tauri/core` npm publish | ⏳ Phase 1 |
| `examples/*` 3 OS ビルド | ⏳ Phase 1 |
| CI ワークフロー実体化 | ⏳ Phase 1 |

本ステアリングは「visibility 切替時にすぐ Pages を enable できる状態」を作る間接的な前進。
