#!/bin/bash

# 保证脚本在出错时立即退出
set -e

# 设置本地 Git 用户信息
git config --local user.email "action@github.com"
git config --local user.name "GitHub Action"

# 通过 GitHub API 获取版本号
# 使用 /releases/latest 获取最新稳定版，避免分页问题（默认只返回30条，若有超过30个预发布版在稳定版之后则会漏掉稳定版）
# 使用 per_page=100 获取预发布版，减少遗漏风险
# 若 GITHUB_TOKEN 存在则添加认证头以避免 API 速率限制
CURL_AUTH_ARGS=()
if [ -n "${GITHUB_TOKEN}" ]; then
  CURL_AUTH_ARGS=(-H "Authorization: Bearer ${GITHUB_TOKEN}")
fi

RELEASE_TAG=$(curl -s \
  -H "Accept: application/vnd.github.v3+json" \
  "${CURL_AUTH_ARGS[@]}" \
  "https://api.github.com/repos/SagerNet/sing-box/releases/latest" \
  | jq -r '.tag_name // empty')
PRERELEASE_TAG=$(curl -s \
  -H "Accept: application/vnd.github.v3+json" \
  "${CURL_AUTH_ARGS[@]}" \
  "https://api.github.com/repos/SagerNet/sing-box/releases?per_page=100" \
  | jq -r '[.[] | select(.prerelease == true)] | first | .tag_name // empty')

# 初始化输出变量
SHOULD_BUILD_STABLE=false
SHOULD_BUILD_PRE=false
HAS_CHANGES=false
COMMIT_MSG=""

# 确保文件存在
touch ReleaseTag PreReleaseTag

# 读取本地版本
LocalReleaseTag=$(cat ReleaseTag | head -n1)
LocalPrereleaseTag=$(cat PreReleaseTag | head -n1)

echo "--- 版本信息 ---"
echo "本地稳定版: ${LocalReleaseTag} | 远程: ${RELEASE_TAG}"
echo "本地预发布: ${LocalPrereleaseTag} | 远程: ${PRERELEASE_TAG}"
echo "----------------"

# --- 检查稳定版 ---
if [ -n "${RELEASE_TAG}" ] && [ "${LocalReleaseTag}" != "${RELEASE_TAG}" ]; then
    echo "发现新稳定版: ${RELEASE_TAG}"
    echo "${RELEASE_TAG}" > ReleaseTag
    SHOULD_BUILD_STABLE=true
    HAS_CHANGES=true
    COMMIT_MSG="${COMMIT_MSG}Update stable to ${RELEASE_TAG}. "
fi

# --- 检查预发布版 ---
if [ -n "${PRERELEASE_TAG}" ] && [ "${LocalPrereleaseTag}" != "${PRERELEASE_TAG}" ]; then
    echo "发现新预发布版: ${PRERELEASE_TAG}"
    echo "${PRERELEASE_TAG}" > PreReleaseTag
    SHOULD_BUILD_PRE=true
    HAS_CHANGES=true
    COMMIT_MSG="${COMMIT_MSG}Update pre-release to ${PRERELEASE_TAG}."
fi

# --- 统一提交与推送 ---
if [ "$HAS_CHANGES" = true ]; then
    echo "准备提交更改..."
    git add ReleaseTag PreReleaseTag
    git commit -m "${COMMIT_MSG}"
    
    # 拉取最新代码防止冲突，尝试重试 3 次
    for i in {1..3}; do
        if git pull --rebase && git push; then
            echo "推送成功"
            break
        else
            echo "推送失败，重试 ($i/3)..."
            sleep 2
        fi
    done
else
    echo "没有检测到版本更新。"
fi

# 设置 GitHub Output
echo "stable_version=${RELEASE_TAG}" >> $GITHUB_OUTPUT
echo "pre_version=${PRERELEASE_TAG}" >> $GITHUB_OUTPUT
echo "should_build_stable=${SHOULD_BUILD_STABLE}" >> $GITHUB_OUTPUT
echo "should_build_pre=${SHOULD_BUILD_PRE}" >> $GITHUB_OUTPUT
