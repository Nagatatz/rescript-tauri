# Development Setup

## Prerequisites

| Requirement | Version | Note |
|-------------|---------|------|
| [uv](https://docs.astral.sh/uv/) | 0.5+ | Python パッケージ管理・仮想環境 |
| Python | 3.12+ | uv が自動インストール |
| Node.js | 24+ | Pagefind 検索インデックス生成に使用 |

### uv のインストール

```bash
# macOS / Linux
curl -LsSf https://astral.sh/uv/install.sh | sh

# Windows
powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"

# Homebrew
brew install uv
```

## Clone the Repository

```bash
git clone {{GITHUB_URL}}.git
cd {{PROJECT_NAME_SLUG}}
```

## Install Dependencies

```bash
cd sphinx-docs
make install    # uv sync で依存関係をインストール
```

## Verify the Setup

```bash
make html       # 英語 HTML ビルド
make serve      # localhost:8000 で確認
```
