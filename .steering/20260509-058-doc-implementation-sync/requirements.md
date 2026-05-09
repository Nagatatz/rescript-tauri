# 要件定義書: ドキュメントと実装の乖離修正

| 項目 | 内容 |
|---|---|
| ステアリング番号 | 20260509-058 |
| タイトル | doc-implementation-sync |
| 作成日 | 2026-05-09 |
| 関連 | 調査セッション (2026-05-09 の乖離レポート) |

## 1. 背景

Phase 1 + Phase 2 の実装が `main` にマージされた現時点で、`docs/` / `README.md` / `sphinx-docs/` / `packages/*/README.md` の各ドキュメントが実装の進化に追従しきれておらず、複数の HIGH / MEDIUM 重大度の乖離が確認された。

調査結果サマリ:
- HIGH: 3 件（`README.md` Quick Start のサンプルがコンパイルしない、`Event.Predefined` モジュールが doc 多数で参照されているが未実装、`product-requirements.md` 内部矛盾）
- MEDIUM: 7 件（`docs/repository-structure.md` の workflows / ルートファイル / sphinx-docs リスト古い、README publish リスト漏れ、functional-design Core API 未記載、`PhysicalSize` 出所未記載、sphinx-docs に plugin-shell ガイド欠落）
- LOW: 2 件（functional-design `Dpi` モジュールの仕様が空、Phase ステータス俯瞰しにくい）

## 2. 解決すべき問題

### 2.1 HIGH (修正必須)

- **H1**: `README.md:112` の `Event.listen` サンプルがコンパイルしない（`evt =>` ではなく `result<event<'payload>, string> => unit` が正）
- **H2**: `Event.Predefined` モジュールが `docs/functional-design.md` `docs/product-requirements.md` で参照されているが実装は `Event.TauriEvent`（文字列定数）のみ。pre-release のため互換 shim を残す必要はない（MEMORY: pre_release_no_compat）→ 実装に合わせて doc を修正する方針
- **H3**: `docs/product-requirements.md` 内で `Event.Predefined` のステータスが矛盾（L276 "Phase 1 — Should" / L422 "Phase 1 リリース後継続"）→ H2 と整合させて 1 つに統一

### 2.2 MEDIUM (リリース前に整える)

- **M1**: `docs/repository-structure.md §8` の CI workflows リストを 21 ファイルすべてに更新
- **M2**: `docs/repository-structure.md §9` のルート設定ファイル列挙に `AGENTS.md` `CONTRIBUTING.md` `SECURITY.md` `CODE_OF_CONDUCT.md` `LICENSE` `Cargo.toml` `pnpm-lock.yaml` を追加
- **M3**: `docs/repository-structure.md §5` の sphinx-docs ファイル列挙を実態に合わせる（`user/plugin-fs.md` `user/plugin-dialog.md` `user/schema.md` `user/index.md` `dev/project-structure.md` `dev/index.md`）
- **M4**: `README.md:19` の npm publish 待ちパッケージリストに `plugin-shell` を追加
- **M5**: `docs/functional-design.md §2.1 (Core)` に `isTauri` `Resource` `PluginListener` `addPluginListener` `permission*` `LowLevel` を追記
- **M6**: `docs/functional-design.md §2.2 (Event)` で `PhysicalSize` / `PhysicalPosition` の出所（`Dpi` モジュール）を明示
- **M7**: `sphinx-docs/user/plugin-shell.md` を最低限のスタブで追加、または `installation.md` に明示的に「後続追加予定」と記載

### 2.3 LOW (余裕があれば)

- **L1**: `docs/functional-design.md §2.5` の `Dpi` モジュール仕様を補完
- **L2**: `docs/product-requirements.md` Phase ステータス俯瞰表をリリース直前に整える（任意）

## 3. スコープ外

- 実装の追加（`Event.Predefined` を実装し直す等）— pre-release で互換不要のため、ドキュメントを実装に合わせる方針
- 大規模な PRD / functional-design の再構成 — 当該乖離箇所のピンポイント修正のみ
- sphinx-docs の翻訳 (.po) の更新 — 別 steering で実施
- `Image.transformImage` などの "意図的に除外" 項目の再検討

## 4. 完了条件

- [ ] 3 件の HIGH すべてが修正済みで doc 再読時に矛盾なし
- [ ] 7 件の MEDIUM すべてが反映済み
- [ ] 修正後に `pnpm --recursive build` が成功（doc-only 修正だが念のため）
- [ ] 修正後に `pnpm run check` が成功（Biome）
- [ ] 修正後にリンクチェック (`doc-link-lint.yml` 相当) で死リンクが新規発生していない
- [ ] `docs/repository-structure.md` に本ステアリング 058 を Section 6 に追記不要（archive 規約により完了後 30 日経過時に archive へ）
- [ ] `tasklist.md` の全タスクが `[x]`

## 5. 検証方法

| 観点 | 検証コマンド / 確認方法 |
|---|---|
| ビルド | `pnpm --recursive build` が成功 |
| Biome | `pnpm run check` が成功 |
| doc 整合 | `Event.listen` サンプルを `Event.resi:102-106` の signature と照合、`Event.Predefined` 参照が doc 内 0 件 |
| repository-structure | `ls .github/workflows/` の出力件数と doc の列挙数が一致、ルートの `ls` 結果と doc の §9 が一致 |
| README publish status | `README.md:19` 付近に plugin-shell を含む 5 パッケージが列挙されている |
| functional-design Core | `Core.resi` の公開トップレベルメンバーすべてが §2.1 で言及されている |

## 6. リスク

| リスク | 緩和策 |
|---|---|
| 別セッション (worktree-plugin-log / 055-refactor-common-module) と doc 更新箇所が衝突 | `repository-structure.md` 等の共有 doc を編集する際は最終マージ直前に rebase |
| `Event.Predefined` を将来実装する判断が後で出る | 削除ではなく "Phase X 以降で再検討" と doc 内に追記して履歴を残す |
| sphinx-docs リンク切れ | 修正後に `doc-link-lint.yml` 相当の検証を CI 任せにせずローカル確認 |
