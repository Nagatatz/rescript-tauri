# Skill / Agent 品質計測設計メモ

> **本ドキュメントは設計メモであり、実装はまだ存在しない**。`empirical-prompt-tuning` スキルを既存の skill / agent に適用して品質を計測・反復改善するための運用設計案。Phase 10 候補。

## 目的

本テンプレートが配布する skill / agent は **意図通り auto-invoke されるか / タスクを完遂するか / コンテキストを効率的に使うか** が運用品質の鍵。`description` リライト（Phase 8 H2）後の効果を実測ベースで検証し、継続的に最適化する仕組みを整える。

## 評価対象

優先度の高い順:

1. **agent**: 6 体（code-reviewer / build-resolver / security-reviewer / quick-search / debugger / release-manager）
2. **skill (auto-invoke 対象)**: bash-safety / worktree-safety / context-management / token-optimization / typescript-conventions / pr-summary / deep-research など
3. **skill (手動起動)**: steering / git-workflow / archive-steering など — auto-invoke 評価不要、ワークフロー完遂率で評価

## 評価指標

各 skill / agent について:

| 指標 | 計測方法 | 目標 |
|---|---|---|
| **auto-invoke 成功率** | テストプロンプト 10 件のうち、期待通り発火した割合 | 80% 以上 |
| **タスク完遂率** | 発火後、要件を満たす出力を生成できた割合 | 90% 以上 |
| **コンテキスト消費量** | スキル起動から完了までのトークン数（メイン会話への影響含む） | ベースライン -20% |
| **再現性** | 同じ入力で安定した出力を生成するか | 主観評価 |

## 評価フロー

`empirical-prompt-tuning` skill を活用:

1. **テストデータセット作成**: 各 skill / agent ごとに 10-20 件のテストプロンプト（auto-invoke が発火すべき / すべきでない両方）
2. **実行**: バイアスのない実行者（別の Claude セッション）でテストを回す
3. **評価**: 自己申告（実行者が「発火した / 完遂した」と判断したか）+ 客観メトリクス（実行者が呼び出したツール / トークン数）
4. **改善**: description / system prompt / allowed-tools をリライトして再評価
5. **頭打ち判定**: 改善幅が 5% 未満になったら停止

## 実装オプション

### Option A: 手動運用
- 月次または PR 単位で empirical-prompt-tuning を手動起動
- 結果は `.steering/<日付>-quality-measurement-<対象>/` に記録
- コスト: 低、頻度: 低

### Option B: CI 自動化
- 週次 cron で全 skill / agent を再評価する GitHub Actions
- 結果を `quality-reports/` ディレクトリに蓄積
- コスト: 中（Anthropic API 利用料）、頻度: 高

### Option C: Anthropic Console 連携
- 公式の Anthropic Console で Workbench 評価を活用
- skill / agent を Workbench の prompt として登録
- コスト: 低、メリット: GUI で結果が見やすい

推奨: **Option A から始める**。改善ROI が高いことが確認できたら Option B に移行。

## 評価データセット例

### code-reviewer agent

| # | プロンプト | 期待挙動 |
|---|---|---|
| 1 | "コミット前にレビューして" | code-reviewer に委譲 |
| 2 | "このコードを見て" | code-reviewer に委譲 |
| 3 | "セキュリティチェックして" | security-reviewer に委譲（code-reviewer ではない） |
| 4 | "ファイルを開いて" | どの agent にも委譲しない |
| ... | ... | ... |

### bash-safety skill

| # | プロンプト | 期待挙動 |
|---|---|---|
| 1 | "rm -rf /tmp/foo を実行" | bash-safety skill が auto-load される |
| 2 | "git worktree remove ..." | bash-safety + worktree-safety が auto-load |
| 3 | "ls -la" | bash-safety は load されない（破壊的でない） |
| ... | ... | ... |

## 効果計測のためのベースライン取得

empirical-prompt-tuning 適用前に、以下の測定をベースラインとして取得:

1. 各 agent / skill の現状 description を記録（git で履歴管理）
2. 主要シナリオ 3-5 件で実行ログを保存
3. トークン消費量・タスク完遂結果を記録

リライト後、同じシナリオで再測定し差分を比較。

## 関連スキル

- `empirical-prompt-tuning`: 評価フロー実行（既存）
- `retrospective-codify`: 学びを skill / rule に反映（既存）
- `learn`: 知見を `.claude/rules/learnings.md` に永続化（既存）

これら 3 つを組み合わせて、計測 → 改善 → 永続化のループを回す。

## 次のアクション

このドキュメントを起点に Phase 10 (品質計測フェーズ) を起動する場合:

1. `.steering/<日付>-quality-measurement/` を作成
2. 評価対象を 1 つに絞る（推奨: `code-reviewer` agent）
3. テストデータセット 10 件作成
4. empirical-prompt-tuning skill で評価実施
5. 結果から description リライト → 再評価
6. 効果が頭打ちまで反復
7. 学びを agent 定義 + `.claude/rules/learnings.md` に永続化

## 参考

- 公式 best-practices「自分の作業を検証する方法を Claude に与える」
- empirical-prompt-tuning skill 本文
- Anthropic engineering "Building effective agents" (Evaluator-Optimizer pattern)
