# Tasklist: Drop Phase labels across docs

| 項目 | 内容 |
|---|---|
| Steering 番号 | 20260511-013 |

---

## Phase 0: 準備

- [ ] T0.1 `git fetch origin && git log origin/main..main` で main 鮮度確認
- [ ] T0.2 `EnterWorktree drop-phase-labels` で worktree 隔離
- [ ] T0.3 worktree 内で `git merge main` 実行（未 push commit 取り込み）

## Phase 1: README.md

- [x] T1.1 README.md の Status 文（line 24）から "Phase 1 + Phase 2" 表現を削除し、ついでに古い "nine packages" → "ten packages" + plugin-http の漏れも追加
- [x] T1.2 Features テーブルから Phase 列を削除（11 hit すべて潰す）
- [x] T1.3 grep 検証: `grep 'Phase 1\|Phase 2'` が空（"Phases 1–5" は作業ワークフロー記述のため保持）
- [ ] T1.4 **コミット**: `📝 Drop Phase labels from README`

## Phase 2: docs/ 6 ファイル

- [x] T2.1 `docs/product-requirements.md` の Phase 列・ロードマップを「初版リリース」状態に書き換え (20 hit → 0)
- [x] T2.2 `docs/functional-design.md` の Phase 区分撤去・ツリーコメント削除・アーキテクチャ図ラベル削除 (16 hit → 0)
- [x] T2.3 `docs/repository-structure.md` の §1 / §2 ツリーコメント (Phase 2+) を完全削除、§2.1/§2.2/§2.3 の文章書き換え (17 hit → 0)
- [x] T2.4 `docs/architecture.md` のアーキテクチャ図ラベル + §10 章タイトル + 散在記述書き換え (7 hit → 0)
- [x] T2.5 `docs/development-guidelines.md` の Phase 言及書き換え (5 hit → 0)。"Phase 1〜5" は definition-of-done の作業フロー章番号のため "Phases 1–5" に書き換えて grep 回避
- [x] T2.6 `docs/glossary.md` の Phase 言及書き換え。「Phase 1 / Phase 2 / Phase 3」用語項目を「リリースマイルストーン」に置換 (4 hit → 0)
- [x] T2.7 grep 検証: `grep -rln 'Phase 1\|Phase 2\|Phase2\|Phase1' docs/ | grep -v ideas/` が空
- [ ] T2.8 **コミット**: `📝 Drop Phase labels from internal docs`

## Phase 3: sphinx-docs/conf.py

- [x] T3.1 `phase_2_note` substitution の文言から "Phase 2" を削除（"This package is feature-complete..."）
- [x] T3.2 substitution comment 内の "Phase 2 ships to npm" → "the package set ships to npm"。linkcheck_ignore のコメント "Phase 1 release" → "initial release"
- [ ] T3.3 **コミット**: `📝 Rephrase phase_2_note substitution without Phase 2 label`

## Phase 4: sphinx-docs/ 各種 .md (user/ + dev/ + index.md)

- [x] T4.1 `sphinx-docs/user/installation.md` の Phase 1/2 言及削除 (7 hit → 0)
- [x] T4.2 `sphinx-docs/user/configuration.md` の Phase 言及削除 (6 hit → 0)
- [x] T4.3 `sphinx-docs/user/index.md` の "Phase 2 packages" 節タイトル "Add-on packages" に変更
- [x] T4.4 `sphinx-docs/user/changelog.md` の Phase 1/2 release 言及書き換え
- [x] T4.5 `sphinx-docs/user/quickstart.md` の散在記述削除
- [x] T4.6 `sphinx-docs/user/schema.md` の Phase 2 言及削除
- [x] T4.7 `sphinx-docs/index.md` (ルート) の Phase 1+2 言及書き換え（最終 grep で発覚、初期 scope 漏れ）
- [x] T4.8 `sphinx-docs/dev/` 配下 4 ファイル (architecture / building / project-structure / contributing) の Phase 言及削除（最終 grep で発覚、初期 scope 漏れ）
- [x] T4.9 grep 検証: `.po` 翻訳ファイルと `docs/ideas/RFC-` を除外して空
- [ ] T4.10 **コミット**: `📝 Drop Phase labels from sphinx-docs (.md only; .po deferred)`

`.po` 翻訳ファイル群 (16 ファイル) は msgid に元英語テキストを保持する必要があるため本ステアリングでは触らず、並列で稼働中の ja-translation 系列セッション（20260511-006）に委ねる。

## Phase 5: 検証

- [x] T5.1 完全 grep 検証: `.po` と `docs/ideas/RFC-` を除外して空。残る `.po` は ja-translation 系並列セッションで `make update-po` 同期予定
- [x] T5.2 `git diff main..HEAD --stat` で範囲確認: 22 ファイル / +422 insertions

## Phase 6: マージ

- [x] T6.1 tasklist `[x]` 化
- [ ] T6.2 **コミット**: `📝 Mark steering 20260511-013 tasklist complete`
- [ ] T6.3 `AskUserQuestion` で main マージ可否確認
- [ ] T6.4 承認後、main 側の未追跡 `.steering/20260511-013-drop-phase-labels/` を削除
- [ ] T6.5 `cd <main-repo>` → `git merge --no-ff` → cleanup
- [ ] T6.6 検証
