# タスクリスト: ドキュメントと実装の乖離修正

| 項目 | 内容 |
|---|---|
| ステアリング番号 | 20260509-056 |
| 関連 | requirements.md / design.md |

## Phase 1: 計画

- [x] requirements.md を作成
- [x] design.md を作成
- [x] tasklist.md を作成
- [x] EnterWorktree で worktree 作成（base ref: head、ローカル main の最新を取り込む）

## Phase 2: 実装 (HIGH)

### Task A: H1 — README.md Quick Start の Event.listen サンプル修正

- [x] `README.md:112` 付近の `Event.listen(evt => ...)` を `result => switch ...` 形式に書き換え
- [x] `pnpm --recursive build` 成功確認
- [x] commit: `📝 Fix README Event.listen sample to match actual signature`

### Task B: H2+H3 — Event.Predefined → Event.TauriEvent への doc 移行

- [x] `docs/functional-design.md` 内 `Event.Predefined` 参照 6 箇所のうち Event 関連 5 箇所を書き換え (L435 Menu は除外)
  - [x] L26 (ツリー図コメント)
  - [x] L206-213 (`Predefined` モジュール仕様 → `TauriEvent` モジュール仕様 + listen/once シグネチャを result 形式に修正)
  - [x] L227 (機能リスト)
  - [x] L589 (テスト対応表)
  - [x] L670 (意思決定表)
- [x] `docs/product-requirements.md` 内 4 箇所を書き換え
  - [x] L144-150 (User Story: 16 種に拡張、利用形態を文字列定数として明示)
  - [x] L276 (状態表: Should/Phase 1 → Must/Phase 1（実装済み）、ラベル修正)
  - [x] L422 (decision table)
- [x] `docs/glossary.md` の Predefined Event エントリで `Event.TauriEvent` への対応を明記
- [x] doc 内に `Event.Predefined` の文字列が残存しないことを `grep` で確認 (Menu 系 / `docs/ideas/RFC-0001` の編集禁止文書のみ残存)
- [x] `pnpm --recursive build` 成功確認
- [x] commit: `📝 Replace Event.Predefined references with Event.TauriEvent`

## Phase 3: 実装 (MEDIUM)

### Task C: M1+M2+M3 — repository-structure.md の §5/§8/§9 更新

- [ ] §1 ルートレイアウトの ASCII ツリーに `LICENSE` `CONTRIBUTING.md` `CODE_OF_CONDUCT.md` `SECURITY.md` `AGENTS.md` `Cargo.toml` `pnpm-lock.yaml` を追加（既存の `.gitignore` 行と並べる）
- [ ] §5 sphinx-docs ツリー更新（実在 14 ファイル反映）
- [ ] §8 workflows 列挙を 19 件（テンプレート 2 件除外）に更新、`tests-coverage.yml` の "4 パッケージ matrix" → "5 パッケージ matrix" 修正
- [ ] §9 ルート設定ファイル表に 7 ファイル追記
- [ ] `pnpm --recursive build` 成功確認
- [ ] commit: `📝 Sync repository-structure.md with current workflows / sphinx-docs / root files`

### Task D: M4 — README publish 待ちリストに plugin-shell + plugin-notification を追加

- [ ] `README.md:19` の文を 5+ パッケージに更新（core / plugin-fs / plugin-dialog / plugin-shell / plugin-notification / schema）
- [ ] Packages 表 (line 38-44) に plugin-notification が無ければ追加（054 で追加済みのはずなので確認）
- [ ] npm 版バッジに plugin-shell / plugin-notification が追加されているか確認、無ければ追加
- [ ] `pnpm --recursive build` 成功確認
- [ ] commit: `📝 Add plugin-shell and plugin-notification to README publish status`

### Task E: M5+M6+L1 — functional-design Core / Event / Dpi セクション拡張

- [ ] §2.1 を §2.1.1〜§2.1.7 のサブセクションに分割し、`isTauri` / `Resource` / `PluginListener` / `addPluginListener` / `permission*` / `LowLevel` / `Internal` を追記
- [ ] §2.2 で `PhysicalSize` / `PhysicalPosition` の脚注（Dpi モジュール出所）を追加
- [ ] §2.5 Dpi セクションに `LogicalSize` / `PhysicalSize` / `LogicalPosition` / `PhysicalPosition` / `Size` / `Position` の型定義リストを追加
- [ ] `pnpm --recursive build` 成功確認
- [ ] commit: `📝 Expand functional-design Core/Dpi sections to match Core.resi surface`

### Task F: M7 — sphinx-docs plugin-shell 言及追加

- [ ] `sphinx-docs/user/installation.md` のプラグインインストール表に `@rescript-tauri/plugin-shell` を追加
- [ ] 注記: 「専用ユーザーガイドは後続 sub-steering で追加予定、現状は `packages/plugin-shell/README.md` 参照」
- [ ] `sphinx-docs/dev/project-structure.md` で plugin-shell の項目が無ければ追加（既存なら確認のみ）
- [ ] commit: `📝 Mention plugin-shell in sphinx-docs installation guide`

## Phase 4: マージ前検証

- [ ] `pnpm --recursive build` 全件成功
- [ ] `pnpm run check` 全件成功
- [ ] `pnpm --recursive test` 全件成功
- [ ] `grep -r "Event.Predefined" docs/ README.md sphinx-docs/` の結果が 0 件（Menu の `Predefined(predefinedMenuItemId)` は除外）
- [ ] `ls .github/workflows/*.yml | wc -l` と repository-structure.md §8 の列挙数が一致
- [ ] `tasklist.md` を本ファイルの全タスク `[x]` 状態でコミット
- [ ] commit: `✅ Mark steering 056 tasklist complete`

## Phase 5: マージ

- [ ] `AskUserQuestion` で main へのマージ可否を確認
- [ ] 承認後、worktree を merge → worktree-cleanup → ブランチ削除を一括実行
- [ ] `git worktree list` が main のみであることを検証
- [ ] `git branch --list 'worktree-*'` が空であることを検証
- [ ] `.claude/worktrees/` が空であることを検証

## ロールバック条件

- 各 Task のコミット後、`pnpm --recursive build` が失敗した場合は直前コミットを `git revert` し、原因を切り分けて再着手
- 並列 `worktree-plugin-log` 等が同じファイルを編集している場合、最終マージ時に rebase で解消
