---
description: 実装コードをスペック準拠・コード品質・テスト・セキュリティ・パフォーマンスの 5 観点で検証し、スコア付きレポートを出す。「実装をレビューして」「品質チェックして」「要件を満たしているか検証して」、またはコミット前 / PR 作成前の自己検証で使用。
model: sonnet
allowed-tools: Bash, Read, Glob, Grep
---

# 実装コード検証

```text
/implementation-validator [<ファイル>|<ディレクトリ>]   # 省略時は git diff --name-only HEAD~3
```

## 手順

1. **対象**: 引数のファイル（ディレクトリならその配下のソース）。ソース（`packages/<pkg>/src/*.res` / `*.resi`）・テスト（`packages/<pkg>/tests/*_signature.res`・`tests/runtime/*.test.mjs`）・その他に分ける。
2. **基準を読む**（存在するものだけ）: `CLAUDE.md`、`docs/product-requirements.md`・`functional-design.md`・`architecture.md`・`repository-structure.md`・`development-guidelines.md`・`glossary.md`、最新の `.steering/*/requirements.md` と `design.md`。設計書が無い観点は「(一部ドキュメント未整備)」と付記する。
3. **ビルド・テスト**。失敗しても検証を続け、結果をレポートに載せる:
   ```bash
   pnpm build && pnpm test          # 全パッケージ。単体は pnpm --filter @rescript-tauri/<pkg> test
   pnpm check                       # oxlint + oxfmt --check
   ```
4. **カバレッジギャップ**: 各パッケージの `src/` の全モジュールと `tests/`（型テスト `*_signature.res`・実行テスト `tests/runtime/*.test.mjs`）を突き合わせ、未テストの公開関数に優先度を付ける — 高: 変換・判定ロジック / 中: 主要 API の束縛 / 低: 薄い外部束縛・型定義のみ。
5. **5 観点を 1〜5 点で採点**（5 = 問題なし、3 = 主要部は良いが漏れあり、1 = 重大な問題が複数）:
   - **スペック準拠**: requirements / design・CLAUDE.md の規約・モジュール責務どおりか
   - **コード品質**: 言語の慣習、命名の統一、単一責任、重複、コメント規約（`.claude/rules/code-comments.md`）、エラー処理
   - **テスト**: 全件パス、変更コードに対応するテスト（`tests/` を Grep）、空・境界値・エラーケース
   - **セキュリティ**: 外部入力の検証、インジェクション、秘密情報のハードコード（`password|secret|api_key|token|credential` を Grep）、パストラバーサル、既知脆弱性のある依存
   - **パフォーマンス**: ループ内の I/O・クエリ（N+1）、リソース解放、不要な再計算、非効率なアルゴリズム・メモリ保持
6. **レポート**を出す。

## レポート

```markdown
### 検証対象
対象ファイル一覧 / 参照ドキュメント（✅ あり・⚠️ 未整備）
### ビルド・テスト結果
| コマンド | 結果 | 詳細 |
### カバレッジギャップ
| モジュール | テスト状態 | 優先度 | 備考 |
### 評価サマリー
| 基準 | スコア | 概要 |        ← 最終行 **総合** = 5 観点の平均（小数第 1 位）
### 良い点
### 指摘事項
#### [必須|推奨] タイトル
- 対象: ファイル:行 / 基準 / 理由 / 改善案
### 改善の優先順位
1. ビルド・テスト失敗 → 2. セキュリティ → 3. テスト拡充 → 4. コード品質
```

**[必須]** = ビルド・テスト失敗、脆弱性、重大な設計違反。**[推奨]** = それ以外の改善。
