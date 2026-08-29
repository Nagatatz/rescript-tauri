# Requirements: Mocks packaging decision (PRD §10 #5)

| 項目 | 内容 |
|---|---|
| ステアリング ID | 20260509-045 |
| 親プラン | `.steering/20260509-030-phase2-planning/` §I (Phase 2 完了条件) — `PRD §10 残課題 #5 が「確定済み」に` |
| 関連ドキュメント | `docs/product-requirements.md` §10 #5, `docs/functional-design.md` §10 #5, `docs/architecture.md` §7.2 |
| 作成日 | 2026-05-09 |

---

## 1. 背景

PRD §10 (残課題) #5 は `Mocks` モジュールを **独立パッケージ
(`@rescript-tauri/mocks`)** にするか、**`@rescript-tauri/core` に
同梱** し続けるかを Phase 2 で再評価することになっていた。

| 残課題 | 暫定方針 | 確定タイミング |
|---|---|---|
| #5 `Mocks` の独立パッケージ化 | 当面 `@rescript-tauri/core` に同梱 | Phase 2 で再評価 |

Phase 2 の必須スコープが揃った今 (steering 031 / 032 / 035 で
schema / plugin-fs / plugin-dialog の実装完了、036/037/039 で
examples、041 で CI、042 で sphinx-docs、043 で README、044 で
CHANGELOG)、再評価して結論を確定する。

## 2. 目的

- `Mocks` モジュールの将来パッケージ構造について **明確な判断と
  根拠** を steering ドキュメントに記録する。
- PRD §10 / functional-design §10 の "Phase 2 で再評価" 行を
  「確定済み」にフリップする。
- Phase 2 完了条件 §I の `PRD §10 残課題 #5 が「確定済み」に` を
  満たす。

## 3. スコープ

### Must

- `requirements.md` (本ファイル) に判断材料・現状を記録
- `design.md` に決定文書 (Decision: 現状維持 / Mocks は core 同梱
  継続) と理由を記載
- `docs/product-requirements.md` §10 #5 行を更新
  - 暫定方針 → 確定方針 (実質変わらず "Core 同梱継続")
  - 確定タイミング → "確定済み (2026-05-09 — `.steering/20260509-045-mocks-packaging-decision/`)"
- `docs/functional-design.md` §10 #5 行を同期 (PRD と整合)

### Should（余裕があれば）

- `docs/architecture.md` §7.2 (Mocks 設計) に「core 同梱継続を
  確定」の旨を追記
- `packages/core/src/Mocks.resi` の doc-comment に "核心モジュール
  であり独立 publish しない方針 (PRD §10 #5 確定済み)" を追記

### 非対象（Out of scope）

- Mocks モジュール自体の実装変更
- 他の §10 残課題 (#2 / #3 / #4 / #6 など) の再評価
- 別 steering で扱う npm publish 実施

## 4. 受け入れ条件

1. PRD §10 #5 行が "確定済み (2026-05-09)" になっている
2. functional-design.md §10 #5 行が PRD と一致
3. design.md に決定とその理由 (代替案比較含む) が記録される
4. `pnpm --recursive build` / `pnpm --recursive test` が引き続き
   全件パスする (実コード非変更)
5. tasklist の全タスクが `[x]` の状態で main マージされる

## 5. 依存・前提

- `Mocks` モジュールが `packages/core/src/` に存在し、
  schema / plugin-fs / plugin-dialog の runtime テストから
  `@rescript-tauri/core/src/Mocks.res.mjs` を import している (現状)。
- Phase 2 の必須パッケージ (schema / plugin-fs / plugin-dialog) が
  既に main にマージされている。

## 6. リスク

- **将来の方針変更**: 現状維持を確定しても、後の Phase で十分な
  理由が出れば再分離は可能 (パッケージ独立化は破壊的変更ではない
  — peer dep 追加で済む)。本 steering ではあくまで Phase 2 完了
  条件としての確定を行うのみで、永続的な決定を意図しない。
  → design.md に "再評価のトリガ" を明示しておく。

## 7. 影響範囲

- 更新: `docs/product-requirements.md`, `docs/functional-design.md`
- (任意) 更新: `docs/architecture.md`, `packages/core/src/Mocks.resi`
- 既存パッケージのコード・テスト・CI には影響なし
