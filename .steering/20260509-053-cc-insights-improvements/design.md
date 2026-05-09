# Design: Claude Code Insights Improvements

## 1. アーキテクチャ概観

Claude Code の **rule（常時 @import）** / **skill（状況発火）** / **hook（lifecycle 起動）** の 3 種で、レポート指摘の摩擦を多層的に防ぐ。

```
┌─────────────────────────────────────────────────────────────┐
│ CLAUDE.md  @import                                          │
│  ├─ steering-workflow.md  ← #1 #2 #4 を追加                 │
│  ├─ pre-flight-verification.md  ← #3 新規                   │
│  └─ (他既存ルール)                                           │
├─────────────────────────────────────────────────────────────┤
│ .claude/skills/  状況発火                                    │
│  ├─ parallel-implementation-swarm/  ← #8 新規               │
│  └─ coverage-climber/  ← #9 新規                            │
├─────────────────────────────────────────────────────────────┤
│ .claude/settings.json  lifecycle hook                        │
│  ├─ PreToolUse Bash → disk space 警告 (#5)                  │
│  └─ PostToolUse Edit/Write → Biome auto-format (#5)         │
└─────────────────────────────────────────────────────────────┘
```

## 2. 個別設計

### 2.1 `steering-workflow.md` への追記 (#1 #2 #4)

#### 2.1.1 Worktree 鮮度チェック (#1)

既存「セッション開始時の worktree 健全性チェック」セクションの直後に新規サブセクション「**worktree 作成前の鮮度確認**」を追加。

```bash
# Worktree 作成前に必ず実行
git fetch origin
git log --oneline origin/main..HEAD  # ローカル main が origin/main より進んでいないか確認
```

`worktree.baseRef` の既定値が `fresh`（origin/<default-branch> ベース）であることを再確認する文言を追記。

#### 2.1.2 ステアリング番号衝突防止 (#2)

「ステアリングワークフロー」のステップ 1 を以下のように改訂:

```markdown
1. `.steering/[YYYYMMDD]-[NNN]-[開発タイトル]/` ディレクトリを作成する
   - **NNN の決定手順**: `ls -1 .steering/ | grep -oE '^[0-9]{8}-[0-9]{3}' | sort -u | tail -1` で当日の最大番号を確認し、+1 を採番する
   - 並列セッションが稼働中の可能性がある場合は `AskUserQuestion` で番号確認する
   - **既に同番号の Worktree ブランチが存在する場合** (`git branch --list 'worktree-*'` で衝突確認) は +1 で再採番する
```

#### 2.1.3 Checkpoint 計画ルール (#4)

新規サブセクション「**長時間タスクの Checkpoint 計画**」を追加:

```markdown
### 長時間タスクの Checkpoint 計画

usage limit による中断に備え、tasklist.md 作成時に以下を満たすこと:

- 各タスクが **単独でコミット可能な粒度** であること
- 各タスクの完了時点で **テストが pass する green commit** が残ること
- 大規模 refactor / 翻訳 / API 全カバー等は **N 個の独立 PR に分割可能** であること

中断が発生した場合、最後の green commit から再開できる構造を保つ。
```

### 2.2 `pre-flight-verification.md` 新規作成 (#3)

新規ルールファイル。CLAUDE.md の @import チェーンに追加する。

```markdown
# Pre-flight Verification 規約

リポジトリの状態（push 済み / 未 push、依存バージョン、ブランチ状態、ファイル存在）を主張する前に、**必ず実行コマンドで検証し、出力を回答に引用すること**。

## 必須検証ケース

| 主張する内容 | 必須検証コマンド |
|---|---|
| 「コミットが未 push」「push 済み」 | `git status -sb` および `git log --oneline origin/main..HEAD` |
| 「依存パッケージのバージョン X」 | `cat <lockfile>` または `node -e "console.log(require('<pkg>/package.json').version)"` |
| 「ファイル <path> が存在 / 不在」 | `ls -la <path>` または `Read` ツール |
| 「ブランチが merge 済み」 | `git branch --merged main` |
| 「workflow が green」 | `gh run list --branch <branch> --limit 5` |

## 引用ルール

検証コマンドの **出力をそのまま回答に含める**（要約せず）。出力なしの場合はそれも明示する。

## なぜか

レポート (`~/.claude/usage-data/report.html`) で「未 push と誤主張」「@types/node bump を unexpected と誤判定」等が複数回発生したため。事前検証は数秒のコストで誤った前提に基づくリカバリ作業を防ぐ。
```

CLAUDE.md の @import セクションに以下を追加:

```diff
 @.claude/rules/testing.md
 @.claude/rules/code-comments.md
 @.claude/rules/git-conventions.md
 @.claude/rules/steering-workflow.md
 @.claude/rules/documentation.md
 @.claude/rules/definition-of-done.md
 @.claude/rules/permission-modes.md
+@.claude/rules/pre-flight-verification.md
```

### 2.3 `.claude/settings.json` 新規作成 (#5)

```jsonc
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": ".claude/hooks/check-disk-space.sh"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": ".claude/hooks/biome-format.sh"
          }
        ]
      }
    ]
  }
}
```

#### 2.3.1 `.claude/hooks/check-disk-space.sh`

- df の使用率が **90% 超** の場合のみ警告（情報のみ、deny しない）
- 95% 超の場合、ユーザーに介入を促すメッセージを返す
- 失敗しても他の hook と build を止めない（`exit 0` 終端）

#### 2.3.2 `.claude/hooks/biome-format.sh`

- 編集ファイルが `*.mjs` / `*.json` の場合のみ `pnpm exec biome check --write <files>` を実行
- ReScript 生成物 `*.res.mjs` / `lib/` は biome.json 側で除外済み（追加処理不要）
- 失敗しても build を止めない（`|| true`）
- `pnpm` が無い環境でも fallback で何もせず exit 0

### 2.4 `parallel-implementation-swarm` skill 新規作成 (#8)

```
.claude/skills/parallel-implementation-swarm/
└── SKILL.md
```

YAML frontmatter:
```yaml
---
name: parallel-implementation-swarm
description: 複数の独立した実装作業（plugin / template / 機能パッケージ）を並列に worktree で進める際のオーケストレーション手順。番号予約・coordinator・batch merge を扱う。「N 個を並列で実装」「複数 plugin 同時着手」のリクエストに proactively 使用。
---
```

本文構成:
1. **発火条件**: N >= 2 の独立した類似実装、各々が独立 PR 化可能な場合
2. **番号予約手順**: `.claude/steering-lock.json` で atomic 採番（ファイル mtime ベース簡易ロック）
3. **Coordinator パターン**: 親セッションが skill 適用、各 worktree は子 Agent (Task tool) で並列実行、最終 reconcile pass を親が実施
4. **競合解決**: 共通ファイル（`docs/repository-structure.md` など）の編集は coordinator が直列実施
5. **Batch merge**: 全 worktree green を確認後、順序を決めて merge

### 2.5 `coverage-climber` skill 新規作成 (#9)

```
.claude/skills/coverage-climber/
└── SKILL.md
```

YAML frontmatter:
```yaml
---
name: coverage-climber
description: vitest --coverage の結果からカバレッジが低いファイルを特定し、自動的にテストを追加して目標閾値（line coverage 85% 等）に climb していくループ。state file `.claude/coverage-progress.json` で再開可能。「カバレッジを上げて」「テストカバー追加」「coverage 改善ループ」のリクエストに proactively 使用。
---
```

本文構成:
1. **発火条件**: 「カバレッジを上げる」「テスト追加して 80% 目指す」等
2. **state file**: `.claude/coverage-progress.json`（gitignore 推奨。`.gitignore` 更新も skill が指示）
3. **ループ手順**: baseline → top N 抽出 → テスト追加 → 検証 → コミット → state 更新 → 繰り返し
4. **ガード**: production code を変更しない、test/build/generated パターンは除外、5 回失敗で skip
5. **PR 単位**: 10 commit ごとに PR、main 直接 push 禁止

## 3. テスト戦略

ドキュメント / 設定ファイルのため自動テスト対象外（`testing.md` 例外条項）。代替検証:

- `jq . .claude/settings.json` で JSON 妥当性
- `pnpm run check` で Biome lint pass
- skill md は frontmatter フィールド (`name`, `description`) を `head -10` で目視確認
- hook シェルスクリプトは `bash -n .claude/hooks/*.sh` で構文チェック

## 4. ロールアウト

worktree でまとめて実装し、main にマージ。後方互換性のため:

- 新規 hook は **失敗しても build を止めない** 設計
- 新規 rule / skill は累積追加（既存ルールを書き換えない）
- 既存の自動 fix tool（Biome）が走っても、ReScript 生成物に手を加えない

## 5. リスクと緩和

| リスク | 緩和 |
|---|---|
| Biome hook が大きい diff を生成して PR が膨らむ | 編集ファイルのみを対象 (`$CLAUDE_FILE_PATHS`)、ReScript 生成物は biome.json で除外済み |
| disk space hook が誤検知で警告連発 | 90% 超のみ警告、95% 超のみ ERR、deny しない |
| 並列 swarm の番号 lock 競合 | mtime ベース atomic write + AskUserQuestion fallback |
| coverage loop が production code を改変 | skill 本文で明示禁止、検出 pattern を列挙 |
