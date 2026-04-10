# GitHub MCP Setup For Codex CLI

Mục tiêu:

- Dùng GitHub MCP với Codex CLI mà không cần commit secret vào repo
- Giữ setup đủ đơn giản để chạy lại trong project này

## Files In This Repo

- `.env.github-mcp`
- `.env.github-mcp.example`
- `scripts/codex-with-github-mcp.sh`

## Cách dùng nhanh

1. Tạo GitHub Personal Access Token.
2. Đảm bảo máy đã cài `codex` và `docker`.
3. Mở file `.env.github-mcp` và thay token placeholder:

```bash
# Optional for GitHub Enterprise or custom GitHub domains.
# Example: export GITHUB_HOST="https://github-minhlong.com"
# Required: GitHub Personal Access Token (PAT) with appropriate permissions.
export GITHUB_PERSONAL_ACCESS_TOKEN="YOUR_GITHUB_PAT"
```

4. Chạy Codex qua script của project:

```bash
./scripts/codex-with-github-mcp.sh
```

5. Kiểm tra trong Codex:

```text
Use GitHub MCP to list my open issues in this repository.
```

## Troubleshooting

Nếu script báo:

```text
Docker daemon is not running. Start Docker Desktop and try again.
```

thì nghĩa là Docker CLI có cài, nhưng Docker Desktop hoặc Docker daemon chưa thực sự chạy.

Nếu script mở được Codex nhưng agent vẫn không gọi được GitHub MCP:

- kiểm tra `docker info` có chạy được không
- kiểm tra `.env.github-mcp` có `GITHUB_PERSONAL_ACCESS_TOKEN`
- nếu repo dùng domain riêng, kiểm tra `.env.github-mcp` có `GITHUB_HOST`
- chạy `./scripts/codex-with-github-mcp.sh mcp list` để xác nhận Codex đã nhận server `github`

## Chạy với prompt ngay từ đầu

```bash
./scripts/codex-with-github-mcp.sh "Use GitHub MCP to inspect open pull requests."
```

## Nếu muốn override tạm thời từ shell

Biến trong shell vẫn được dùng bình thường:

```bash
export GITHUB_PERSONAL_ACCESS_TOKEN="YOUR_GITHUB_PAT"
./scripts/codex-with-github-mcp.sh
```

## Dùng image khác cho GitHub MCP

Mặc định script dùng:

```text
ghcr.io/github/github-mcp-server
```

Nếu cần override:

```bash
export GITHUB_MCP_IMAGE="ghcr.io/github/github-mcp-server:latest"
./scripts/codex-with-github-mcp.sh
```

## Nếu muốn dùng config global thay vì script

Bạn có thể tự thêm vào:

```toml
[mcp_servers.github]
command = "docker"
args = [
  "run",
  "-i",
  "--rm",
  "-e",
  "GITHUB_PERSONAL_ACCESS_TOKEN",
  "ghcr.io/github/github-mcp-server",
]
env = { GITHUB_PERSONAL_ACCESS_TOKEN = "YOUR_GITHUB_PAT" }
```

trong file:

```text
~/.codex/config.toml
```

Sau đó thay `YOUR_GITHUB_PAT` bằng token thật hoặc inject qua môi trường theo cách bạn đang dùng.

## Nếu repo dùng GitHub Enterprise hoặc domain riêng

Nếu `git remote -v` không trỏ tới `github.com` mà là domain riêng, thêm vào `.env.github-mcp`:

```bash
export GITHUB_HOST="https://your-github-host"
```

Ví dụ:

```bash
export GITHUB_HOST="https://github-minhlong.com"
```

GitHub MCP server chính thức hỗ trợ `GITHUB_HOST` cho GitHub Enterprise Server hoặc GitHub Enterprise Cloud domain riêng.

## Lưu ý bảo mật

- Không commit token thật vào repo
- Chỉ cấp quyền PAT ở mức tối thiểu cần thiết
- Thường sẽ cần `repo`; nếu làm việc với organization có thể cần thêm quyền đọc organization
