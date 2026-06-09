# タスクリスト: 依存パッケージ更新とドキュメント整合修正

| 項目 | 内容 |
|---|---|
| 機能名 | deps-and-docs-sync |
| 作成日 | 2026-06-09 |
| 進捗 | 0 / 12 完了 |

## フェーズ1: 準備

- [x] ディスク空き容量を再確認する（`df -h .`、install に十分か）
- [x] ルート / packages / examples の package.json で対象 dev 依存の現 range 表記を確認する

## フェーズ2: 依存更新

> 既存 package.json の version range は `^` で緩く設定済み（`^4.0.0` / `^20.9.0` / `^12.2.0` / `^2.0.0` / `^25.0.0`）。対象 8 件は全て既存レンジ内のため **package.json 編集は不要**。`pnpm update --recursive` でレンジ内最新へ引き上げ + lockfile 更新のみ。

- [x] `pnpm update --recursive` で対象 8 パッケージを最新 patch/minor に引き上げる
- [x] `pnpm outdated --recursive` で対象が消えたことを確認する（対象 outdated なし）
- [x] `pnpm-lock.yaml` の差分を確認する（608 insertions / 603 deletions）

> 補足: pnpm v11 既定挙動で package.json の caret 下限も解決バージョンに narrowing された（`^4.0.0`→`^4.1.8` 等、全 24 workspace の devDependencies + examples の demo 依存）。**公開パッケージの peerDependencies は全て不変** のため利用者向けレンジと repository-structure.md の peerDep 記載に影響なし。`@rescript/core 1.6.0→1.6.1` / `rescript-schema 9.5.x` / `@tauri-apps/plugin-* ` も in-range で specifier 基準のみ更新（harmless）。

## フェーズ3: 検証（テスト）

- [x] `pnpm --recursive build` が成功する（rescript 12.3.0 で全 workspace 緑）
- [x] `pnpm --recursive test` が全件パスする（vitest 4.1.8、全 package exit 0）
- [x] `pnpm run check`（Biome）が警告・エラーなし（変更した 24 package.json を biome 2.4.16 で個別 check → all clean。`biome check .` は worktree パスが `!**/.claude/worktrees` に自己マッチする artifact で `.` 全体が除外されるが、CI / main の checkout では発生しない）
- [x] biome bump に伴い `biome.json` の `$schema` を 2.4.16 に更新

## フェーズ4: ドキュメント修正

- [x] `docs/repository-structure.md` §5 の sphinx-docs/user/ ツリーに 6 plugin ページを追記する（実 user/ 14 ファイルと一致）
- [x] `doc-link-lint` 観点で記述に破綻がないか目視確認する（ツリー記述のみ・リンク追加なし）

## フェーズ5: 仕上げ・コミット

- [x] コミット1（🔧 依存更新 + lockfile + biome.json + steering）とコミット2（📝 docs 修正）を分けて作成する
- [x] 本 tasklist の全タスクを `[x]` に更新し、マージ前最終コミットに含める

## 完了条件

- [x] すべてのタスクが完了していること
- [x] `pnpm --recursive build` / `test` / `pnpm run check` がすべて成功すること（check は worktree artifact を除き全 package.json clean）
- [x] requirements.md の受け入れ条件をすべて満たしていること
- [x] PR 作成 → self-merge → worktree クリーンアップまで完了していること

---

## 振り返り

<!-- モード3（/steering review）で記録する -->

### 実装で工夫した点

### 発生した問題と解決策

### 設計変更の理由

### 次回への改善点
