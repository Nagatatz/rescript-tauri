---
description: 新機能を実装するとき、既存コードのパターン（パッケージ構成・バインディングの書き方・エラー処理・テストスタイル）を調べて合わせる。「機能を追加して」「実装して」で使用。
---

# 新機能の追加

1. **把握**: `README.md`・`docs/architecture.md`（レイヤー構造）・`docs/repository-structure.md` で全体像を掴む。
2. **既存パターン調査**: Grep で類似機能を探して読み、公開 API の書き方・エラー処理・テストの書き方を確認する（バインディングは `packages/<pkg>/src/*.res` と `.resi`、テストは `tests/*_signature.res`・`tests/runtime/*.test.mjs`）。
3. **実装**: 見つけたパターンと `docs/architecture.md` のレイヤー構造に従う。
4. **テスト**: 既存のテストディレクトリに、既存スタイルで正常系・エッジケース（空入力・境界値）・エラーケースを書く。
5. **検証**: `pnpm --filter @rescript-tauri/<pkg> test`（ビルド込み）、最後に `pnpm build && pnpm test`。失敗したら既存パターンとの差を確かめて直し、再実行する。
6. **ドキュメント**: 公開 API を変えたら パッケージの README と `sphinx-docs/` を更新する（`.claude/rules/documentation.md` に従い、ja の `.po` も更新）。
