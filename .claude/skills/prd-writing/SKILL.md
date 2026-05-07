---
name: prd-writing
description: プロダクト要求定義書(PRD)を作成するための詳細ガイドとテンプレート。PRD作成時にのみ使用。
allowed-tools: Read, Write
disable-model-invocation: true
---

## 既存 PRD 一覧（自動取得）

!`ls -1 docs/product-requirements*.md 2>/dev/null || echo "(no existing PRDs)"`

## 作成手順

1. `docs/ideas/initial-requirements.md`を読み込む
2. `./template.md`を読み込む
3. テンプレートのプレースホルダー([○○]の部分)を、アイデアメモの内容に基づいて具体化する
4. `docs/product-requirements.md`として保存する
