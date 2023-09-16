#!/bin/bash

# 设置本地 Git 用户信息
git config --local user.email "action@github.com"
git config --local user.name "GitHub Action"

# 判断 release_version 和 prerelease_version 是否都不为空
if [[ -n "${{ steps.git-push.outputs.release_version }}" && -n "${{ steps.git-push.outputs.prerelease_version }}" ]]; then
    git commit -am "Update ReleaseTag ${{ steps.git-push.outputs.release_version }}, PreReleaseTag ${{ steps.git-push.outputs.prerelease_version }}"
    git push -v --progress
    echo "::set-output name=status::success"
elif [[ -n "${{ steps.git-push.outputs.release_version }}" ]]; then
    git commit -am "Update ReleaseTag ${{ steps.git-push.outputs.release_version }}"
    git push -v --progress
    echo "::set-output name=status::success"
elif [[ -n "${{ steps.git-push.outputs.prerelease_version }}" ]]; then
    git commit -am "Update PreReleaseTag ${{ steps.git-push.outputs.prerelease_version }}"
    git push -v --progress
    echo "::set-output name=status::success"
fi
