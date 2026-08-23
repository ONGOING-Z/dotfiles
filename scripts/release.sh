#!/usr/bin/env bash
# 统一发布流程：CHANGELOG（git-cliff，canonical cliff.toml 在 dotfiles）→ bump 版本 → 打 tag → push。
# 仓类型自动探测：
#   npm 仓   npm version（自动 commit package.json/lock + tag）
#   maven 仓 mvn versions:set + commit + 手动 tag
#   其它     git-cliff + 手动 tag
# 业务 Worker 的部署仍由 Release PR → CF Builds 负责，tag 是版本标记/CHANGELOG 锚点；
# framework_sdk_worker / Java SDK 仓的 tag 即发布触发器（CI publish）。
# 用法：release.sh [X.Y.Z]   # 缺省时 git-cliff --bumped-version 自动计算
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CLIFF_TOML="$DOTFILES_ROOT/cliff.toml"
VERSION="${1:-}"
DRY_RUN=0
[[ "${2:-}" == "--dry-run" ]] && DRY_RUN=1

git rev-parse --git-dir >/dev/null 2>&1 || { echo "当前目录不是 git 仓库" >&2; exit 1; }
[[ -z "$(git status --porcelain)" ]] || { echo "working tree 不干净，先提交或清理" >&2; exit 1; }

BRANCH="$(git branch --show-current)"
case "$BRANCH" in
  master|main) ;;
  dev_*) [[ "${ALLOW_DEV:-0}" == "1" ]] || { echo "当前在 dev 分支；确认要在此发布请设 ALLOW_DEV=1" >&2; exit 1; } ;;
  *) echo "仅支持在 master/main 发布（当前: $BRANCH）" >&2; exit 1 ;;
esac

if [[ -z "$VERSION" ]]; then
  if command -v git-cliff >/dev/null 2>&1; then
    VERSION="$(git-cliff --bumped-version 2>/dev/null || true)"
  fi
  [[ -n "$VERSION" ]] || { echo "无法自动计算版本，请显式传入: release.sh X.Y.Z" >&2; exit 1; }
fi
[[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || { echo "版本须为 X.Y.Z（不带 v 前缀）" >&2; exit 1; }
TAG="v$VERSION"
git rev-parse "$TAG" >/dev/null 2>&1 && { echo "tag $TAG 已存在" >&2; exit 1; }

if [[ ! -t 0 ]]; then
  echo "版本: $TAG（非交互环境，自动继续）"
else
  echo -n "发布版本: $TAG，回车确认（Ctrl-C 取消）"
  read -r _ || exit 1
fi

# CHANGELOG：canonical cliff.toml 只在 dotfiles 一份，不复制到各仓
if command -v git-cliff >/dev/null 2>&1; then
  git-cliff -c "$CLIFF_TOML" -u -t "$TAG" -o CHANGELOG.md
  echo "CHANGELOG.md 已生成（git-cliff）"
else
  echo "git-cliff 未安装，跳过 CHANGELOG"
fi

if [[ $DRY_RUN -eq 1 ]]; then
  echo "dry-run：跳过 bump/commit/tag/push。CHANGELOG.md 已生成，查看后删除即可。"
  exit 0
fi

if [[ -f package.json ]]; then
  npm version "$VERSION" -m "chore(release): v%s"
  git add CHANGELOG.md
  git commit --amend --no-edit
elif [[ -f pom.xml ]]; then
  mvn versions:set -DnewVersion="$VERSION" -DgenerateBackupPoms=false
  mapfile -t POMS < <(find . -name pom.xml -not -path '*/node_modules/*' -not -path '*/.git/*')
  git add CHANGELOG.md "${POMS[@]}"
  git commit -m "chore(release): v$VERSION"
  git tag -a "$TAG" -m "chore(release): v$VERSION"
else
  git add CHANGELOG.md
  git commit -m "chore(release): v$VERSION"
  git tag -a "$TAG" -m "chore(release): v$VERSION"
fi

git push origin HEAD
git push origin "$TAG"
echo "done: $TAG"
