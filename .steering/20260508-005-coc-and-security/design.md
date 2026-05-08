# 設計: CODE_OF_CONDUCT.md と SECURITY.md

| 項目 | 内容 |
|---|---|
| 関連 | `requirements.md` |
| 作成日 | 2026-05-08 |

## 1. 派生決定の確定（要承認）

requirements.md §4 に対し、本設計で以下を採用する:

| § | 採用 | 内容 |
|---|---|---|
| 4.1 CoC ソース | **案 A** | Contributor Covenant 2.1 の全文採用 |
| 4.2 CoC enforcement contact | **案 A** | 個人 email（`nagata.hbdc@gmail.com`）を直接記載 |
| 4.3 Security disclosure channel | **案 A** | GitHub Security Advisories（GHSA）のみ。SECURITY.md で起票手順を案内 |
| 4.4 Supported versions | **案 A** | 1 段落で "未公開" 明記、Pre-release report は GHSA で受付 |

## 2. ファイル構成

### 2.1 `CODE_OF_CONDUCT.md`（新規、英語、ルート）

#### ベース

[Contributor Covenant 2.1](https://www.contributor-covenant.org/version/2/1/code_of_conduct/) のテキストを全文転載する（CC BY 4.0 ライセンス、attribution 必須）。

#### 章立て（Contributor Covenant 標準）

```
# Contributor Covenant Code of Conduct

## Our Pledge
## Our Standards
   - Examples of acceptable behavior (5 項目)
   - Examples of unacceptable behavior (5 項目)
## Enforcement Responsibilities
## Scope
## Enforcement
   - 連絡先: nagata.hbdc@gmail.com
## Enforcement Guidelines
   - 1. Correction
   - 2. Warning
   - 3. Temporary Ban
   - 4. Permanent Ban
## Attribution
   - Contributor Covenant 2.1, CC BY 4.0
```

#### 連絡先記載方針

`Enforcement` セクションに以下のように記載:

> Instances of abusive, harassing, or otherwise unacceptable behavior may be reported to the project maintainer responsible for enforcement at **nagata.hbdc@gmail.com**.

GitHub Security Advisories は本来セキュリティ専用の channel であり、CoC 違反は対象外（公式に CoC reports は GHSA の対象としていない）。そのため email 直接記載が現実的。

### 2.2 `SECURITY.md`（新規、英語、ルート）

#### 章立て

```
# Security Policy

## Supported Versions
   - "No supported versions yet. The project is in Phase 1 design phase.
     The first published `@rescript-tauri/core` release will be marked
     supported. Until then, pre-release reports are welcome via the
     channel below."

## Reporting a Vulnerability
   - **Please do not open a public Issue.**
   - Use GitHub Security Advisories: Security → Report a vulnerability
     URL: https://github.com/Nagatatz/rescript-tauri/security/advisories/new
   - Fallback (if GHSA is not yet enabled or is inaccessible to you):
     email **nagata.hbdc@gmail.com** with subject "[rescript-tauri SECURITY]".

## What to Include
   - Affected component / file / line if known
   - Reproduction steps (PoC)
   - Impact assessment
   - Suggested mitigation (optional)

## Response Timeline
   - Acknowledgement: 7 days (best-effort during Phase 1 design phase;
     guaranteed timeline starts at Phase 1 release).
   - Initial assessment: 14 days
   - Fix or status update: 30 days

## Disclosure Policy
   - Coordinated disclosure preferred.
   - Reporters credited in the security advisory unless anonymity is requested.
   - CVE assignment via GHSA when applicable.

## Out of Scope
   - Vulnerabilities in upstream dependencies (`@tauri-apps/api`, `rescript`,
     `@rescript/core`) — please report directly to those projects.
   - Anything in the `examples/` directory once it exists, unless the issue
     is in `@rescript-tauri/core` reachable from the example.
```

#### Fallback channel について

派生決定 4.3 では「GHSA のみ」を案とした。実装ではユーザー利便性のため email を fallback として 1 行明記する（GHSA 未有効化時 / GHSA 操作不慣れな報告者向け）。これは派生決定 4.3 案 A を緩める形だが、実用性を優先する。tasklist の検証項目で「fallback の email も明記されている」を含める。

### 2.3 `CONTRIBUTING.md` 軽微修正

| 該当 | before（要旨） | after（要旨） |
|---|---|---|
| §5 末尾（line 116） | "For security issues, do not open a public Issue. A `SECURITY.md` with a private disclosure channel will be added at the Phase 1 release. Until then, please contact the maintainer through the email listed in the GitHub profile." | "For security issues, do not open a public Issue. See [`SECURITY.md`](./SECURITY.md) for the private disclosure channel (GitHub Security Advisories, with email fallback)." |
| §6（line 122） | "A `CODE_OF_CONDUCT.md` will be added at the Phase 1 release. Until then, contributors and reviewers are expected to act with respect, assume good faith, and keep technical discussion focused on the design and code at hand." | "Contributors and reviewers follow the [`CODE_OF_CONDUCT.md`](./CODE_OF_CONDUCT.md) (Contributor Covenant 2.1). Reports of unacceptable behavior go to the contact listed in that document." |

## 3. コミット粒度

`git-conventions.md` の「1 コミット = 1 論理的変更」に従い分割:

| # | コミット | 内容 |
|---|---|---|
| 1 | 📝 Add steering for 20260508-005 (coc-and-security) | ステアリング 3 ファイル配置 |
| 2 | ✨ Add CODE_OF_CONDUCT.md (Contributor Covenant 2.1) | `CODE_OF_CONDUCT.md` 新規 |
| 3 | ✨ Add SECURITY.md with GHSA-first disclosure channel | `SECURITY.md` 新規 |
| 4 | 📝 Resolve CoC and SECURITY TBDs in CONTRIBUTING.md | `CONTRIBUTING.md` §5 / §6 軽微修正 |
| 5 | 📝 Mark steering 20260508-005 complete | tasklist 全 [x] 化 |

各コミットで `tasklist.md` の該当タスクを `[x]` 化。

## 4. worktree 運用

ドキュメントのみの追加 + 軽微修正。`.claude/rules/steering-workflow.md` の worktree 規約（コード実装対象）には該当しないため、**worktree を省略**し main 直接コミットで進める。steering 003 と同パターン。

## 5. テスト・検証戦略

ドキュメントのみの変更のためユニットテストは不要。検証は以下:

1. **ファイル存在**: `ls CODE_OF_CONDUCT.md SECURITY.md`
2. **CONTRIBUTING.md からのリンク有効性**: `CODE_OF_CONDUCT.md` / `SECURITY.md` への相対 link が解決すること
3. **TBD 残存ゼロ**: `grep -n 'TBD\|will be added at the Phase 1 release' CONTRIBUTING.md` の出力に該当行がないこと（README L159 sphinx-docs publication TBD は別件、対象外）
4. **Contributor Covenant attribution の正確性**: `CODE_OF_CONDUCT.md` 末尾に CC BY 4.0 表示と原典 URL が含まれること
5. **GHSA URL の正しさ**: `SECURITY.md` 内の `https://github.com/Nagatatz/rescript-tauri/security/advisories/new` が正しい形式（実アクセスは private repo のため authenticated なフォーマット確認のみ）

## 6. リリース判定への影響

本ステアリング完了で `README.md` Visibility ブロックの 5 条件への直接影響はない（CoC / SECURITY は条件リスト外）。ただし visibility 切替時の Community Standards 充足度が向上する。

| visibility 切替条件 | 状態 |
|---|---|
| LICENSE | ✅ 既達 |
| CONTRIBUTING.md | ✅ 既達 (steering 003) |
| `@rescript-tauri/core` npm publish | ⏳ Phase 1 |
| `examples/*` 3 OS ビルド | ⏳ Phase 1 |
| CI ワークフロー実体化 | ⏳ Phase 1 |

副次的改善:
- ✅ CODE_OF_CONDUCT.md（本ステアリング）
- ✅ SECURITY.md（本ステアリング）

## 7. 後続作業との接続

本ステアリング後にユーザーが GitHub UI で行う作業:

- Settings → Security → "Private vulnerability reporting" を有効化
- 必要なら Settings → Moderation で CoC enforcement に関連する設定

これらは Claude が実行できないため、tasklist 末尾に「ユーザー手動作業」として明記する。
