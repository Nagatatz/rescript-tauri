# Design: Drop Phase labels across docs

| 項目 | 内容 |
|---|---|
| Steering 番号 | 20260511-013 |
| 関連 | `requirements.md` |

---

## 1. 書き換えルール

| 既存表現 | 書き換え後 |
|---|---|
| "Phase 1 + Phase 2 implementations are merged on `main`" | "All ten packages are merged on `main`" |
| "Phase 1" 列のテーブルヘッダ / セル | 列ごと削除 |
| "(Phase 1)" / "(Phase 2)" / "(Phase 2+)" 括弧書き付加情報 | 括弧ごと削除 |
| "ships with 12 Phase-1 modules" | "ships with 12 modules" |
| "Phase 2 introduces five add-on packages" | "Five add-on packages build on the core:" |
| "Phase 2 着手済み (steering 037)" | "(steering 037, 2026-05-09)" のみ |
| "Phase 1 必須" / "Phase 2" comment | 完全削除（節構造で十分） |
| "Phase 1 / Phase 2 ロードマップ" 節 | "Implemented packages" 等に節タイトル変更し、リリース済み状態を記述 |
| substitution `phase_2_note` 内の "Phase 2 implementation" / "Phase 2 packages" | "This package" / "the other packages" 等の中立表現 |

## 2. 各ファイルの主な変更内容

### 2.1 `README.md` (11 hit)

- Line 24 (Status 文): "Phase 1 + Phase 2 implementations are merged" → "All ten packages are merged"
- Features テーブル (line 45-53): 末尾の "Phase 1" / "Phase 2+" 列を全削除（列ごと）
- それ以外の散在記述: 個別書き換え

### 2.2 `docs/product-requirements.md` (20 hit)

- Phase 1 / Phase 2 ロードマップ章のリファクタ
- 「Phase 2 完了条件」「Phase 1 完了条件」のような節も「リリース完了条件」一本化
- 個別行: "Phase 1" / "Phase 2" の文字を削除し、文章の流れを保つ

### 2.3 `docs/functional-design.md` (16 hit)

- "Phase 1 で実装する〜" → "コア (`@rescript-tauri/core`) では〜"
- "Phase 2 で〜" → "プラグイン群では〜"
- 構造図表のラベルから Phase 行削除

### 2.4 `docs/repository-structure.md` (17 hit)

- §1 のディレクトリ comment: `# Phase 1 必須` / `# Phase 2` を完全削除
- §2.1: "Phase 1 の中心パッケージ" → "コアパッケージ"
- §2.2: "Phase 2 着手済み (steering XXX, ...)" → "(steering XXX, YYYY-MM-DD)"
- §3 のディレクトリ comment: 同様に Phase 表記削除
- §5 内のリストヘッダ "Phase 2 packages" → "Add-on packages"

### 2.5 `docs/architecture.md` (7 hit) / `docs/development-guidelines.md` (5 hit) / `docs/glossary.md` (4 hit)

個別の散在記述を行単位で書き換え。

### 2.6 `sphinx-docs/conf.py` (4 hit)

`phase_2_note` substitution の文言を:

**変更前:**
```python
"phase_2_note": (
    "The Phase 2 implementation of this package is feature-complete in "
    "`main`. Its first npm publish is scheduled alongside the other "
    "Phase 2 packages. Until then, consume it via the source repository "
    "or a workspace link."
),
```

**変更後:**
```python
"phase_2_note": (
    "This package is feature-complete in `main`. Its first npm publish "
    "is scheduled alongside the other packages. Until then, consume it "
    "via the source repository or a workspace link."
),
```

comment の "when Phase 2 ships to npm" も "when the package set ships to npm" などに書き換え。

### 2.7 `sphinx-docs/user/` 6 ファイル

- `index.md`: "Phase 2 packages" 節を "Add-on packages" 等に
- `installation.md`: "Phase 1" / "Phase 2" のステップ分け削除
- `configuration.md`: 個別書き換え
- `changelog.md`: "Phase 1 release" / "Phase 2 release" 等を "Initial release" 等に
- `quickstart.md`: 散在記述削除
- `schema.md`: Phase 2 言及削除

## 3. コミット分割戦略

文章書き換え量が多いため、論理ユニットでコミット分割（usage limit 対策）:

| Commit | 対象 |
|---|---|
| C1 | README.md |
| C2 | docs/ 7 ファイル全て (architecture / development-guidelines / functional-design / glossary / product-requirements / repository-structure) を 1 まとめ |
| C3 | sphinx-docs/conf.py |
| C4 | sphinx-docs/user/ 6 ファイル全て |

7 ファイル / 6 ファイルを 1 まとめにするのは規模的に微妙だが、各文書ごとの整合性を保ちながら書き換えるため、関連が深い `docs/` / `sphinx-docs/user/` グループは 1 単位とする。

## 4. 影響範囲

| カテゴリ | ファイル数 |
|---|---|
| README | 1 |
| 内部 docs | 6 |
| sphinx config | 1 |
| sphinx user guide | 6 |
| steering | 3 |
| **合計** | **17 ファイル** |

## 5. 検証

```bash
# 受け入れ基準の grep:
grep -rln 'Phase 1\|Phase 2\|Phase2\|Phase1' \
  README.md CLAUDE.md docs/ sphinx-docs/ \
  | grep -v 'docs/ideas/RFC-'
# → 出力空であること
```

CI lint / sphinx ビルドは別途 CI で検証。

## 6. ロールバック

ドキュメントのみの変更のため `git revert <merge-commit>` で原状復帰可能。
