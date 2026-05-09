# Pre-flight Verification 規約

リポジトリの状態（push 済み / 未 push、依存バージョン、ブランチ状態、ファイル存在、CI 結果）を主張する前に、**必ず実行コマンドで検証し、出力を回答に引用すること**。

## 原則

- **「事実の主張」と「推測の表明」は明確に区別する**
- 「〜は X です」と断言する場合、その根拠となるコマンド出力を直近 1 ターン以内に取得していること
- 過去ターンの出力で十分な場合はその旨を明示（「先の `git status` の出力より」等）
- 不確実な場合は **「未確認」と明示** する。誤った前提でユーザーを誘導しない

## 必須検証ケース

以下の主張をする前に、対応する検証コマンドを必ず実行すること:

| 主張する内容 | 必須検証コマンド | 例外 |
|---|---|---|
| 「コミットが未 push」「push 済み」 | `git status -sb` および `git log --oneline origin/main..HEAD` | 直近 1 ターン以内に確認済みなら省略可 |
| 「依存パッケージのバージョンは X」 | `cat <lockfile>` または `node -e "console.log(require('<pkg>/package.json').version)"` | package.json を Read 済みなら省略可 |
| 「ファイル <path> が存在する / 不在」 | `ls -la <path>` または `Read` ツール | 直近 1 ターン以内に確認済みなら省略可 |
| 「ブランチが merge 済み」 | `git branch --merged main` | — |
| 「workflow / CI が green」 | `gh run list --branch <branch> --limit 5` | — |
| 「git tree が clean」 | `git status --porcelain` | — |
| 「依存パッケージが更新された」 | `git diff <lockfile>` または `pnpm-lock.yaml` を Read | — |

## 引用ルール

- 検証コマンドの **出力をそのまま回答に含める** （要約せず、最低でも該当行は引用）
- 出力が空（= 何も該当無し）の場合は **「出力なし」と明示**
- コマンドが失敗した場合は **失敗したことを明示**し、推測で代替しない

### 良い例

> origin/main に対する未 push コミットを確認します:
>
> ```
> $ git log --oneline origin/main..HEAD
> bd84146 📝 Add steering 053
> ```
>
> 1 件未 push の commit があります。

### 悪い例

> ローカルに未 push の commit があるはずです（← 検証なしの推測）
> 最新版は v0.1.13 だと思います（← lockfile / package.json を確認していない）

## 例外

- **読み取り専用の概念質問**（「git とは」「依存解決の仕組み」等）には適用しない
- **ユーザーが既に状態を提示している**場合はその情報を信頼してよい（例: ユーザー入力に `git status` 出力が含まれる）
- **設計・要件議論で仮定として state を置く**場合は「仮定」と明示すれば検証不要（例: 「もし未 push なら〜」）

## 背景

CC Insights レポート（`~/.claude/usage-data/report.html`、2026-04 〜 2026-05、599 messages / 82 sessions）で以下が複数回観測された:

- 「コミットが未 push」と Claude が誤主張 → 実際は push 済み
- `@types/node` の dependency bump を「予期せぬ変更」と flag → 実際は既にコミット済み
- `packageManager` の値を誤読

事前検証は数秒のコストで誤った前提に基づくリカバリ作業（複数ターンに渡る revert / 訂正）を防ぐ。

## 関連

- `.claude/rules/steering-workflow.md` — worktree 作成前の鮮度確認
- `.claude/rules/git-conventions.md` — main へのコミット例外条項
- `.claude/skills/bash-safety/` — 破壊的操作前の安全確認
