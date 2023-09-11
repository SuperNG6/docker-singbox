#!/bin/bash

# 通过 GitHub API 获取最新 release 的版本号
RELEASE_TAG=$(curl -s https://api.github.com/repos/SagerNet/sing-box/releases/latest | jq -r '.tag_name')

# 通过 GitHub API 获取 prerelease 的版本号
PRERELEASE_TAG=$(curl -s https://api.github.com/repos/SagerNet/sing-box/releases | jq -r '.[0].tag_name')

OnlineReleaseTag=${RELEASE_TAG}
OnlinePrereleaseTag=${PRERELEASE_TAG}

# 从 releasetag 文件中提取本地的版本号
LocalReleaseTag=$(cat ReleaseTag | head -n1)
LocalPrereleaseTag=$(cat PreReleaseTag | head -n1)

echo "本地 Release 版本号: ${LocalReleaseTag}"
echo "本地 Prerelease 版本号: ${LocalPrereleaseTag}"
echo "在线 Release 版本号: ${RELEASE_TAG}"
echo "在线 Prerelease 版本号: ${PRERELEASE_TAG}"

# 检查本地版本号和在线版本号是否不同，如果有任何一个版本号不同，则触发更新动作
if [ "${LocalReleaseTag}" != "${OnlineReleaseTag}" ] || [ "${LocalPrereleaseTag}" != "${OnlinePrereleaseTag}" ]
then
   # 设置输出变量以便在后续步骤中使用
   echo "::set-output name=release_version::${RELEASE_TAG}"
   echo "::set-output name=prerelease_version::${PRERELEASE_TAG}"
   echo  ${RELEASE_TAG} > ./ReleaseTag
   echo  ${PRERELEASE_TAG} > ./PreReleaseTag
   echo "::set-output name=status::success"
fi
