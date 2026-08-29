# Tasklist: Phase 2 release checklist

> Definition of Done は `.claude/rules/definition-of-done.md` を参照。

## Phase 1: 計画

- [x] worktree (`worktree-phase2-release-checklist`) 作成 + main 取り込み
- [x] `.steering/20260509-046-phase2-release-checklist/` 作成
- [x] `requirements.md`
- [x] `design.md`
- [x] `tasklist.md`（本ファイル）

## Phase 2: 実装

### A. release-checklist 本体

- [x] `.steering/20260509-046-phase2-release-checklist/release-checklist.md`
  - [x] §0 前提条件 (Phase 1 publish 済 / NPM_TOKEN / public)
  - [x] §1 リリース前確認 (3 パッケージ別 preflight)
  - [x] §2 Cut コミット手順 (sed + commit を 3 パッケージ + sphinx)
  - [x] §3 タグ作成と push (3 連 tag)
  - [x] §4 dry-run の留意点
  - [x] §5 リリース後検証 (npm view + GitHub Release + sphinx)
  - [x] §6 スモーク試験
  - [x] §7 告知 (任意)
  - [x] §8 Phase 3 起点準備
  - [x] §9 ロールバック (publish 失敗時)
  - [x] 連絡先

### B. 検証

- [x] release-checklist.md を text-check (656 lines total)
- [x] 内部リンク (steering 029 / 030 / 045) が解決
- [x] tag prefix が release.yml の case 文と一致
- [x] `pnpm --recursive build` regression なし
- [x] `pnpm --recursive test` 全件パス (47 tests)

## Phase 3: コミット前検証

- [x] tasklist.md の進捗を `[x]` 更新

## Phase 4: コミット

- [x] commit 1: `📝 Add Phase 2 release checklist`
  - 含む: `release-checklist.md` + ステアリング 3 種 (req/design/tasklist)
- [x] commit 2 (最終): `📝 Mark steering 046 tasks complete pre-merge`

## Phase 5: マージ

- [x] `AskUserQuestion` で main マージ可否確認
- [x] 承認後:
  - [x] CWD を main リポジトリに移動 (ExitWorktree keep)
  - [x] `git merge worktree-phase2-release-checklist --no-ff -m "..."`
  - [x] `git worktree remove .claude/worktrees/phase2-release-checklist`
  - [x] `git branch -d worktree-phase2-release-checklist`

## Phase 6: 検証

- [x] `git worktree list` から phase2-release-checklist が消える
- [x] `git branch --list 'worktree-phase2-release-checklist'` 空

## Phase 7: 親プラン更新

- [x] `.steering/20260509-030-phase2-planning/tasklist.md` の
      備考欄 (§I の publish 行) に「ランブック整備済 (steering 046)」
      の注記を追加
