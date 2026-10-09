#!/usr/bin/env bash
set -euo pipefail

# 引数は検証用のホームディレクトリ。省略時は現在のユーザーを対象にする。
if (( $# > 1 )); then
    echo '使い方: bash codex/install.sh [ホームディレクトリ]' >&2
    exit 2
fi
config_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
target_home="${1:-$HOME}"
if [[ "$target_home" != /* || ! -d "$target_home" ]]; then
    echo 'ホームディレクトリは、存在するディレクトリの絶対パスで指定してください。' >&2
    exit 1
fi
target_home="$(cd -- "$target_home" && pwd -P)"

sources=("$config_root/.agents" "$config_root/AGENTS.md")
targets=("$target_home/.agents" "$target_home/.codex/AGENTS.md")
shopt -s nullglob
for skill in "$config_root/.agents/skills/"*/; do
    [[ -d "$skill" ]] || continue
    if [[ ! -f "$skill/SKILL.md" ]]; then
        echo "SKILL.mdがありません: $skill" >&2
        exit 1
    fi
done

# 全対象を検査してからリンクを作る。
for i in "${!sources[@]}"; do
    source_path="${sources[i]}"
    target_path="${targets[i]}"
    if [[ ! -e "$source_path" ]]; then
        echo "原本がありません: $source_path" >&2
        exit 1
    fi
    if [[ -e "$target_path" && ! -L "$target_path" ]]; then
        echo "配置先に実ファイルまたは実ディレクトリがあります。変更せず停止します: $target_path" >&2
        exit 1
    fi
    parent="$(dirname -- "$target_path")"
    while [[ ! -d "$parent" ]]; do
        if [[ -e "$parent" || -L "$parent" ]]; then
            echo "親ディレクトリとして使えません: $parent" >&2
            exit 1
        fi
        parent="$(dirname -- "$parent")"
    done
done

for i in "${!sources[@]}"; do
    source_path="${sources[i]}"
    target_path="${targets[i]}"
    replacing=false
    # 事前検査後も実データを削除しないよう、操作直前に再確認する。
    if [[ -e "$target_path" && ! -L "$target_path" ]]; then
        echo "配置先に実ファイルまたは実ディレクトリがあります。変更せず停止します: $target_path" >&2
        exit 1
    fi
    if [[ -L "$target_path" ]]; then
        if [[ "$(readlink -f -- "$target_path" || true)" == "$(readlink -f -- "$source_path")" ]]; then
            echo "変更なし: $target_path"
            continue
        fi
        # 再帰削除はせず、リンクそのものだけを削除する。
        rm -- "$target_path"
        replacing=true
    fi
    mkdir -p -- "$(dirname -- "$target_path")"
    ln -s -- "$source_path" "$target_path"
    if [[ "$replacing" == true ]]; then
        echo "リンク更新: $target_path"
    else
        echo "リンク作成: $target_path"
    fi
done
echo 'Codex設定の配置が完了しました。'
