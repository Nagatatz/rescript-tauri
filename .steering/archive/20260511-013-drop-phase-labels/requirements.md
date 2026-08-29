# Requirements: Drop Phase 1 / Phase 2 labels across docs (release prep Phase D)

| 項目 | 内容 |
|---|---|
| Steering 番号 | 20260511-013 |
| 作業タイトル | Phase 1 / Phase 2 ラベル撤去（リリース準備 Phase D） |
| 作成日 | 2026-05-11 |
| 関連 steering | 20260511-010 (CI), 20260511-012 (CHANGELOG), 20260511-011 (sphinx note substitution) |

---

## 1. 背景

ユーザー指示「一気にリリースしようと思うので、ドキュメントから Phase 2 に関する内容は省いてください」を受け、Phase 1 / Phase 2 / Phase 2+ などの開発フェーズラベルを user-facing / 設計ドキュメントから撤去する。

並列セッションで:
- steering 20260511-010 (CI) — 完了
- steering 20260511-011 — `sphinx-docs/user/plugin-*.md` (9 ファイル) の Phase 2 pre-release note を MyST substitution `phase_2_note` に集約済み（main にマージ済み）
- steering 20260511-012 (CHANGELOG cleanup) — 完了

本ステアリングは残りの 14 ファイル / 約 105 hit を処理する:

| ファイル | hit 数 |
|---|---|
| `README.md` | 11 |
| `docs/product-requirements.md` | 20 |
| `docs/repository-structure.md` | 17 |
| `docs/functional-design.md` | 16 |
| `docs/architecture.md` | 7 |
| `docs/development-guidelines.md` | 5 |
| `docs/glossary.md` | 4 |
| `sphinx-docs/conf.py` | 4 (substitution `phase_2_note` 内) |
| `sphinx-docs/user/installation.md` | 7 |
| `sphinx-docs/user/configuration.md` | 6 |
| `sphinx-docs/user/changelog.md` | 2 |
| `sphinx-docs/user/quickstart.md` | 2 |
| `sphinx-docs/user/index.md` | 2 |
| `sphinx-docs/user/schema.md` | 2 |

**`docs/ideas/RFC-*.md` は履歴文書のため触らない (out of scope)**。

## 2. 目的

Phase 1 / Phase 2 / Phase 2+ などのフェーズラベルを以下の方針で除去し、リリース版として 10 packages 全てが同一に扱われる状態にする:

- "Phase 1" / "Phase 2" / "Phase 2+" のラベルそのものは削除
- 「all 10 packages」「the bindings」「the released packages」など中立的表現に置換
- 履歴的記述 (例: "Phase 2 着手済み (steering 037, ...)") は steering 参照だけ残す
- リリース後のスナップショットとして整合する文面に整える

## 3. スコープ

### 3.1 含めるもの

- 上記 14 ファイルの Phase ラベル撤去・書き換え
- `sphinx-docs/conf.py` の `phase_2_note` substitution の文言から "Phase 2" を削除（substitution 構造自体は 011 で導入されたばかりのため保持。「first npm publish is pending」のような中立的文言に書き換え）
- `docs/product-requirements.md` の "Phase 1 / Phase 2 ロードマップ" 章は **節タイトルも書き換え** て「リリース済み」状態を表現

### 3.2 含めないもの

- `sphinx-docs/user/plugin-*.md` (9 ファイル) — 既に 011 で substitution 化済み
- `docs/ideas/RFC-*.md` — 履歴文書
- `packages/*/CHANGELOG.md` — 個別 release note は保持
- `packages/*/package.json` の version bump
- npm publish 実行
- `phase_2_note` substitution 自体の削除（pre-release note の概念は残す）
- ja `.po` ファイルの更新（並列セッションが定期的に `make update-po` で同期している）

## 4. 受け入れ基準

- [ ] 以下の grep が **空** （RFC を除く）:
  ```bash
  grep -rln 'Phase 1\|Phase 2\|Phase2\|Phase1' \
    README.md CLAUDE.md docs/ sphinx-docs/ \
    | grep -v 'docs/ideas/RFC-'
  ```
- [ ] `sphinx-docs/conf.py` の substitution `phase_2_note` の文言から "Phase 2" が消えている
- [ ] sphinx ビルドが壊れない（CI で確認）
- [ ] tasklist 全タスク `[x]` で main マージ完了

## 5. リスク

- **並列衝突**: 14 ファイル中、共有ファイル (README.md / repository-structure.md / index.md など) は他並列セッションも頻繁に触る。worktree 中に複数回 main merge が必要になる前提。
- **大きな書き換え**: docs/product-requirements.md は 20 hit、リファクタ規模大。fundamental な文章書き換えになるため、レビューが必要なら別ステップに分ける。
- **意味の損失**: 「Phase 1 必須」「Phase 2 着手済み」のような時系列情報を消すと、後から経緯が辿りにくくなる → steering 参照だけ残す形で履歴は保持。
