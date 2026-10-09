#!/usr/bin/env bash
set -euo pipefail

# 引数は検証用のホームディレクトリ。省略時は現在のユーザーを対象にする。
if (( $# > 1 )); then
    echo '使い方: bash linux/install.sh [ホームディレクトリ]' >&2
    exit 2
fi
config_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
target_home="${1:-$HOME}"
if [[ "$target_home" != /* || ! -d "$target_home" ]]; then
    echo 'ホームディレクトリは、存在するディレクトリの絶対パスで指定してください。' >&2
    exit 1
fi
target_home="$(cd -- "$target_home" && pwd -P)"

sources=()
targets=()
for name in .bash_aliases .gitconfig .nanorc .vimrc; do
    sources+=("$config_root/$name")
    targets+=("$target_home/$name")
done

# 全対象を検査してからリンクを作る。
for i in "${!sources[@]}"; do
    source_path="${sources[i]}"
    target_path="${targets[i]}"
    if [[ ! -e "$source_path" ]]; then
        echo "原本がありません: $source_path" >&2
        exit 1
    fi
    if [[ -e "$target_path" || -L "$target_path" ]]; then
        if [[ -L "$target_path" && "$(readlink -f -- "$target_path" || true)" == "$(readlink -f -- "$source_path")" ]]; then
            continue
        fi
        echo "配置先が既に存在します。変更せず停止します: $target_path" >&2
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
    target_path="${targets[i]}"
    if [[ -L "$target_path" ]]; then
        echo "変更なし: $target_path"
        continue
    fi
    mkdir -p -- "$(dirname -- "$target_path")"
    ln -s -- "${sources[i]}" "$target_path"
    echo "リンク作成: $target_path"
done
echo 'Linux設定を反映するには source ~/.bashrc を実行してください。'
