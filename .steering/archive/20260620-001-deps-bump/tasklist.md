# tasklist — 20260620-001 deps bump

- [x] 1. root `package.json` の `@types/node` を `^25.9.2` → `^26.0.0` に更新
- [x] 2. `packages/*/package.json` 9 ファイルの `@types/node` を `^26` に更新
- [x] 3. `pnpm install` + `pnpm update` で lockfile を refresh（biome 2.5.0 / vitest 4.1.9 / happy-dom 20.10.6 / @types/node 26.0.0）
- [x] 4. `pnpm run check` が clean であることを確認（biome 2.5.0、exit 0。既存の lint warning 3 件は 2.4.16 から不変で CI 非ブロック）
- [x] 5. `pnpm --recursive build` が成功することを確認
- [x] 6. `pnpm --recursive test` 全 268 件 pass を確認（vitest 4.1.9）
- [x] 7. ステアリングドキュメント + 変更をコミット（`🔧 Bump dev/tooling deps ...`）
- [x] 8. tasklist 全 [x] 化 → push → PR 作成 → self-merge → worktree クリーンアップ

## 検証メモ

- `@tauri-apps/api` 2.11.0 → 2.11.1 は `window.d.ts` の `Monitor` doc comment のみで公開シンボル変化なし → バインディングコード修正不要。
- biome 2.5.0 は 0 ファイル処理時に exit 1 になる挙動変更があるが、`.claude/worktrees` 除外により worktree 内実行時のみ顕在化。CI はリポジトリルートから実行するため影響なし。
- transitive な `@types/node@25.9.2`（`@types/ws` 等が `*` で参照）が残るが、workspace 直接依存は全て 26.0.0 に解決済み・型のみで無害。

> テスト: 本変更は dev 依存のみで新規ロジックを追加しないため、新規テスト作成は不要。既存テスト全件 pass がリグレッション検証を兼ねる。
