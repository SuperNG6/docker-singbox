#!/bin/bash

# 保证脚本在出错时立即退出
set -e

# 设置本地 Git 用户信息
git config --local user.email "action@github.com"
git config --local user.name "GitHub Action"

# 通过 GitHub API 获取最新 release 的版本号
# 使用 V3 API 并明确接受 JSON 格式，增加稳定性
RELEASE_TAG=$(curl -s -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/SagerNet/sing-box/releases | jq -r '.[] | select(.prerelease == false) | .tag_name' | head -n 1)

# 通过 GitHub API 获取 prerelease 的版本号
PRERELEASE_TAG=$(curl -s -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/SagerNet/sing-box/releases | jq -r '.[] | select(.prerelease == true) | .tag_name' | head -n 1)

# 初始化输出变量
SHOULD_BUILD_STABLE=false
SHOULD_BUILD_PRE=false

# 检查 ReleaseTag 文件是否存在，不存在则创建
if [ ! -f ReleaseTag ]; then
    touch ReleaseTag
fi
# 检查 PreReleaseTag 文件是否存在，不存在则创建
if [ ! -f PreReleaseTag ]; then
    touch PreReleaseTag
fi

# 从文件中提取本地的版本号
LocalReleaseTag=$(cat ReleaseTag | head -n1)
LocalPrereleaseTag=$(cat PreReleaseTag | head -n1)

echo "本地稳定版 (Local Stable): ${LocalReleaseTag}"
echo "在线稳定版 (Remote Stable): ${RELEASE_TAG}"
echo "本地预发布版 (Local Pre-release): ${LocalPrereleaseTag}"
echo "在线预发布版 (Remote Pre-release): ${PRERELEASE_TAG}"

# 检查稳定版是否有更新
if [ -n "${RELEASE_TAG}" ] && [ "${LocalReleaseTag}" != "${RELEASE_TAG}" ]; then
   echo "检测到新的稳定版: ${RELEASE_TAG}"
   echo "${RELEASE_TAG}" > ./ReleaseTag
   git add ReleaseTag
   git commit -m "Update stable release to ${RELEASE_TAG}"
   # 推送变更。如果远程有更新，先拉取再推送，避免冲突。
   git pull --rebase && git push
   SHOULD_BUILD_STABLE=true
else
    echo "稳定版无需更新。"
fi

# 检查预发布版是否有更新
if [ -n "${PRERELEASE_TAG}" ] && [ "${LocalPrereleaseTag}" != "${PRERELEASE_TAG}" ]; then
   echo "检测到新的预发布版: ${PRERELEASE_TAG}"
   echo "${PRERELEASE_TAG}" > ./PreReleaseTag
   # 检查是否有未提交的更改（例如上面已经修改了 ReleaseTag）
   if ! git diff --quiet --cached; then
     # 如果有暂存的更改，则追加提交
     git add PreReleaseTag
     git commit --amend --no-edit
   else
     # 否则创建新的提交
     git add PreReleaseTag
     git commit -m "Update pre-release to ${PRERELEASE_TAG}"
   fi
   git pull --rebase && git push
   SHOULD_BUILD_PRE=true
else
    echo "预发布版无需更新。"
fi

# 使用新的 GITHUB_OUTPUT 方式设置输出
echo "stable_version=${RELEASE_TAG}" >> $GITHUB_OUTPUT
echo "pre_version=${PRERELEASE_TAG}" >> $GITHUB_OUTPUT
echo "should_build_stable=${SHOULD_BUILD_STABLE}" >> $GITHUB_OUTPUT
echo "should_build_pre=${SHOULD_BUILD_PRE}" >> $GITHUB_OUTPUT

echo "脚本执行完毕。"