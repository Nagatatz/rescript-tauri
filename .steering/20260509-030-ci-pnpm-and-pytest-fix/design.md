# Design: CI Follow-up — pnpm Version Conflict & Sphinx Pytest Empty-collection

| 項目 | 内容 |
|---|---|
| 作業 ID | 20260509-030-ci-pnpm-and-pytest-fix |
| 関連 | [requirements.md](./requirements.md) |

## 1. 問題 1: pnpm/action-setup の version 重複

### 1.1 採用方針

`with.version` を削除し、`package.json#packageManager` を SSOT とする。

**理由:**
- `package.json#packageManager` は npm / pnpm / yarn / Corepack で標準的にサポートされる SSOT
- ローカル開発と CI で同じバージョンが使われることが保証される（ワークフローと package.json のドリフトを防ぐ）
- `pnpm/action-setup` 公式 README でも v4 系では `packageManager` 自動検出を推奨

### 1.2 書き換えフォーマット

```yaml
# 変更前
- uses: pnpm/action-setup@a15d269cd4658e1107c09f1fabf4cbd7bd1f308a # v4.4.0
  with:
    version: 10

# 変更後（with: ブロックごと削除）
- uses: pnpm/action-setup@a15d269cd4658e1107c09f1fabf4cbd7bd1f308a # v4.4.0
```

`with` ブロック内に他のオプションが無いことを各ファイルで確認済み（`version: 10` のみ）。

### 1.3 対象ファイルと差分

| ファイル | 削除行数 |
|---|---|
| `build-core.yml` | 2 |
| `examples-build.yml` | 2 |
| `tests-core-runtime.yml` | 2 |
| `tests-core-types.yml` | 2 |
| `compat-rescript-prerelease.yml` | 2 |
| `compat-tauri-latest.yml` | 2 |
| `release.yml` | 2 |

各ファイル `with:` 行 + `version: 10` 行の 2 行を削除。

## 2. 問題 2: docs.yml の pytest 空コレクション

### 2.1 採用方針

`sphinx-docs/tests/` 配下に `test_*.py` または `*_test.py` が **存在する場合のみ** ステップを実行する。存在しない場合はステップをスキップ（GitHub Actions では「skipped」は失敗扱いされない）。

### 2.2 検討した代替案

| 案 | 採否 | 理由 |
|---|---|---|
| A. `if: hashFiles(...)` でガード | **採用** | 自動的に挙動が切り替わり、テスト追加時に追加変更不要。意図が明示的 |
| B. `pytest \|\| [ $? -eq 5 ]` で exit 5 を吸収 | 不採用 | 「テスト 0 件」と「テスト全 pass」の区別が CI 出力で見えなくなる |
| C. ダミーテストを追加 | 不採用 | 本番テスト戦略未定の段階で骨組みだけ追加するのはノイズ |
| D. `pytest --co` で先に存在確認 | 不採用 | 二重実行になる |

### 2.3 書き換え内容

```yaml
# 変更前
      - name: Pytest
        run: uv run pytest

# 変更後
      - name: Pytest
        if: hashFiles('sphinx-docs/tests/**/test_*.py', 'sphinx-docs/tests/**/*_test.py') != ''
        run: uv run pytest
```

`hashFiles` はワークフローのルートからの相対パスを受け取る（`working-directory` の影響を受けない）。複数パターン渡しで OR 評価される。マッチが無ければ空文字列が返り `!= ''` が false になりスキップ。

### 2.4 動作の確認

- 現状（`sphinx-docs/tests/__init__.py` のみ）: パターンにマッチしないため step は skipped（緑）
- 将来 `sphinx-docs/tests/test_foo.py` 追加時: マッチするため pytest 実行（pytest の結果次第で緑/赤）

## 3. 検証方針

ローカル: 構文チェックのみ（YAML パース可能）。
リモート: push 後に GitHub Actions が緑になるか確認。

ReScript / pnpm のビルドや pytest 自体の挙動は本変更で変わらないため、ローカルでのビルド検証は省略する。

## 4. リスクと緩和

| リスク | 緩和策 |
|---|---|
| `pnpm/action-setup` が `packageManager` 検出に失敗する | v4 系公式ドキュメントで `packageManager` 自動検出が標準動作と明記されている。失敗時は本変更を revert |
| `hashFiles` パターンが意図と違うファイルを拾う | パターンは pytest デフォルト規約 (`test_*.py`, `*_test.py`) に厳密に合わせる |
| 将来 `pytest --import-mode=importlib` で配置場所が変わった場合 | hashFiles パターンを更新（design.md §2.3 で明記） |
