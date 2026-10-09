# タスクリスト: Vitest / @vitest/coverage-v8 のペア更新

- [x] 全 10 package の manifest で 2 依存を `^5.0.3` に更新
- [x] `pnpm install` で lockfile 再生成、4.1.11 の残存 0 件・`@vitest/coverage-v8@5.0.3(vitest@5.0.3)` を確認
- [x] `pnpm install --frozen-lockfile` で整合性確認
- [x] `pnpm --recursive build`
- [x] 全 10 package の `test:coverage`（既存閾値で pass）
- [x] main (4.1.11) との coverage 値比較（core/schema/plugin-shell/plugin-dialog で完全一致）
- [x] `pnpm test` / `pnpm check`
- [x] テスト追加は省略: 依存更新のみでコード変更がなく、既存の runtime / coverage テスト自体が回帰検証となるため
- [x] コミット・push
- [x] PR 作成 (#87)・CI 確認・マージ（ユーザー承認済み）
