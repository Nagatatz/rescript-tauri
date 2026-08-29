# タスクリスト: ドキュメントと実装の乖離修正

| 項目 | 内容 |
|---|---|
| ステアリング番号 | 20260509-058 |
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

- [x] §1 ルートレイアウトの ASCII ツリーに `LICENSE` `CONTRIBUTING.md` `CODE_OF_CONDUCT.md` `SECURITY.md` `AGENTS.md` `Cargo.toml` `pnpm-lock.yaml` を追加
- [x] §5 sphinx-docs ツリー更新（実在 14 ファイル + sphinx-docs/{conf.py,Makefile,pyproject.toml,tests,_static,_templates,index.md} 反映、未追加 plugin-shell/notification ガイドを注記）
- [x] §8 workflows 列挙を 21 件（template 2 件は別途注記）に更新、`tests-coverage.yml` の "4 パッケージ matrix" → "6 パッケージ matrix" 修正
- [x] §9 ルート設定ファイル表に 7 ファイル追記（AGENTS / CONTRIBUTING / CODE_OF_CONDUCT / SECURITY / LICENSE / Cargo.toml / pnpm-lock.yaml）
- [x] `pnpm --recursive build` 成功確認 (doc-only 修正)
- [x] commit: `📝 Sync repository-structure.md with current workflows / sphinx-docs / root files`

### Task D: M4 — README publish 待ちリストに plugin-shell + plugin-notification を追加

- [x] `README.md:19` の文を 6 パッケージに更新（core / plugin-fs / plugin-dialog / plugin-shell / plugin-notification / schema）
- [x] Packages 表に plugin-notification あり（054 で追加済み確認）
- [x] npm 版バッジに plugin-shell / plugin-notification を追加
- [x] schema 行の "rescript-struct" を deprecated 注記付きに修正（追加で発見した乖離）
- [x] `pnpm --recursive build` 成功確認
- [x] commit: `📝 Add plugin-shell and plugin-notification to README publish status`

### Task E: M5+M6+L1 — functional-design Core / Event / Dpi セクション拡張

- [x] §2.1 に「IPC 中核」「プラグイン共通基盤・環境」の 2 つのシグネチャブロックを設け、`isTauri` / `Resource` / `PluginListener` / `addPluginListener` / `permissionState` / `checkPermissions` / `requestPermissions` / `LowLevel` / `Internal` / `decoder` を追記。実装方針節も更新
- [x] §2.2 修正時に `PhysicalSize` / `PhysicalPosition` の出所 (`Dpi`) コメントを Predefined Tauri 注釈に同梱済み（Task B で実施）
- [x] §2.5 Dpi セクションを完全な opaque-type + accessor 仕様に置き換え、`LogicalSize` / `PhysicalSize` / `LogicalPosition` / `PhysicalPosition` / `Size` / `Position` を追記。`Event` 連携の補足も追加
- [x] `pnpm --recursive --workspace-concurrency=1 build` 成功確認（並列時の race 回避）
- [x] commit: `📝 Expand functional-design Core/Dpi sections to match Core.resi surface`

### Task F: M7 — sphinx-docs plugin-shell 言及追加

- [x] `sphinx-docs/user/installation.md` のプラグインインストールセクションに `@rescript-tauri/plugin-shell` と `@rescript-tauri/plugin-notification` を追加
- [x] 注記: 「専用ユーザーガイドは後続 sub-steering で追加予定、現状は各 README.md 参照」
- [x] `sphinx-docs/dev/project-structure.md` Subsystem map に plugin-shell + plugin-notification を追記、Core/Event 行コメントを実装に合わせて修正
- [x] commit: `📝 Mention plugin-shell in sphinx-docs installation guide`

### Task G (途中で発生): main から plugin-log + plugin-os を取り込み、ステアリング再採番

- [x] 並列セッションが同じ 056 番号で plugin-os を完了 → 自分を **056 → 057** に再採番。さらに別セッションが 057 を plugin-clipboard-manager / Common module で同時使用していたため **057 → 058** に再々採番（`git mv` + 内部 ref 更新）
- [x] main に追加された 4 commit (steering 055 plugin-log + steering 056 plugin-os) を `git merge main --no-ff` で取り込み
- [x] README.md の Packages テーブル衝突を解消（plugin-log + plugin-os 行を残しつつ schema 行の deprecated 注記を保持）
- [x] README.md npm バッジに plugin-log + plugin-os を追加、publish 待ちパッケージ数を 6 → 8 に更新
- [x] docs/repository-structure.md §8 に 4 件の新規 workflow を追加、tests-coverage.yml の matrix 注記を 6 → 8 に修正
- [x] sphinx-docs/user/installation.md に plugin-log + plugin-os の install command を追加、未追加ガイド注記を 4 パッケージに拡張
- [x] sphinx-docs/dev/project-structure.md Subsystem map を 7 パッケージに拡張
- [x] commit: `Merge branch 'main' into worktree-doc-implementation-sync` (renumber + plugin absorption 同梱)

## Phase 4: マージ前検証

- [x] `pnpm --recursive build` 全件成功 (sequential, race 回避)
- [x] `pnpm run check` 確認: 既知の Biome 2.x 問題（worktree path に `.claude/worktrees` が含まれて `!**/.claude/worktrees` exclude が CWD に該当し全除外）。CI (lint-format.yml) は main 上で success 継続
- [x] `pnpm --recursive test` 全件成功 — 23 test files all pass (core 16, plugin-fs 1, plugin-dialog 1, plugin-shell 1, plugin-notification 1, plugin-log 1, plugin-os 1, schema 1)
- [x] `grep -rn "Event.Predefined" docs/ README.md sphinx-docs/` 結果: 自己説明用の `glossary.md` 1 件のみ（"Event.Predefined という別モジュールは存在しない" の注記）
- [x] `ls .github/workflows/*.yml | wc -l` (25) と repository-structure.md §8 の列挙数 (25) が一致
- [x] `tasklist.md` を本ファイルの全タスク `[x]` 状態でコミット
- [ ] commit: `✅ Mark steering 058 tasklist complete`

## Phase 5: マージ

- [ ] `AskUserQuestion` で main へのマージ可否を確認
- [ ] 承認後、worktree を merge → worktree-cleanup → ブランチ削除を一括実行
- [ ] `git worktree list` が main のみであることを検証
- [ ] `git branch --list 'worktree-*'` が空であることを検証
- [ ] `.claude/worktrees/` が空であることを検証

## ロールバック条件

- 各 Task のコミット後、`pnpm --recursive build` が失敗した場合は直前コミットを `git revert` し、原因を切り分けて再着手
- 並列 worktree が同じファイルを編集している場合、最終マージ時に rebase で解消
