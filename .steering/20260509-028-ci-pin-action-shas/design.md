# Design: CI Action SHA Pin

| 項目 | 内容 |
|---|---|
| 作業 ID | 20260509-028-ci-pin-action-shas |
| 関連 | [requirements.md](./requirements.md) |

## 1. 方針

`uses: <owner>/<repo>@<tag>` を `uses: <owner>/<repo>@<sha> # <tag>` に書き換える機械的置換。
コードは変わらないため、ロジック設計や移行計画は不要。重要なのは **採用する SHA の正確性** と **コメントによる可読性維持** の 2 点。

## 2. 採用する SHA 一覧（2026-05-09 時点）

GitHub API (`GET /repos/<owner>/<repo>/git/refs/tags`) で取得した、各メジャータグの最新解決先。

| アクション | 現状の参照 | 採用 SHA | 対応バージョン |
|---|---|---|---|
| actions/checkout | @v4 | `34e114876b0b11c390a56381ad16ebd13914f8d5` | v4.3.1 |
| actions/checkout | @v6 | `de0fac2e4500dabe0009e67214ff5f5447ce83dd` | v6.0.2 |
| actions/setup-node | @v4 | `49933ea5288caeca8642d1e84afbd3f7d6820020` | v4.4.0 |
| pnpm/action-setup | @v4 | `a15d269cd4658e1107c09f1fabf4cbd7bd1f308a` | v4.4.0 |
| astral-sh/setup-uv | @v6 | `d0cc045d04ccac9d8b7881df0226f9e82c39688e` | v6.8.0 |
| actions/upload-pages-artifact | @v4 | `7b1f4a764d45c48632c6b24a0339c27f5614fb0b` | v4.0.0 |
| actions/deploy-pages | @v4 | `d6db90164ac5ed86f2b6aed7e0febac5b3c0c03e` | v4.0.5 |
| dtolnay/rust-toolchain | @stable | `29eef336d9b2848a0b548edc03f92a220660cdb8` | (heads/stable @ 2026-05-09) |

### 2.1 補足

- `dtolnay/rust-toolchain` は安定版を表す `stable` ブランチ参照のみが提供されており、リリースタグ運用ではない。`heads/stable` を当日時点の SHA で固定し、コメントで `# stable @ 2026-05-09` と明記する。
- `actions/checkout` は 2 系統（v4 / v6）が混在。`docs.yml` のみ v6 を使用しており、互換性のため両系統を併存させる（major bump はスコープ外）。

## 3. 書き換えフォーマット

```yaml
# 変更前
- uses: actions/checkout@v4

# 変更後
- uses: actions/checkout@34e114876b0b11c390a56381ad16ebd13914f8d5 # v4.3.1
```

dependabot は `# vX.Y.Z` コメントを認識して自動更新を行うため、コメントフォーマットは厳守する。

## 4. ファイル別の差分概要

| ファイル | 置換数 |
|---|---|
| `build-core.yml` | 3 |
| `examples-build.yml` | 4 |
| `docs.yml` | 7 |
| `doc-link-lint.yml` | 1 |
| `tests-core-runtime.yml` | 3 |
| `tests-core-types.yml` | 3 |
| **合計** | **21** |

## 5. 検証方針

ローカルで構文検証できる範囲は限定的（GitHub Actions は実行時にしかバリデーションしない）。
- ローカル: `yamllint` 相当のチェック（YAML パース可能か）
- リモート: PR を push して Actions が起動するか（SHA 拒否エラーが出ないか）を確認

ReScript / pnpm のビルドや単体テストは本変更の影響範囲外（CI ワークフローのメタ情報のみの変更）のため、ビルド検証は省略する。

## 6. リスクと緩和

| リスク | 緩和策 |
|---|---|
| 採用 SHA の取り違え | API 応答ログを `design.md` §2 に明記し、コメントで対応バージョンを併記 |
| dtolnay/rust-toolchain の `stable` 参照が今後のリリースで動く | コメントで取得時点を明記し、定期的な更新を dependabot に委ねる |
| dependabot 未設定で SHA が固定化 | 本作業のスコープ外。別途 `chore/dependabot-actions` で対応 |
