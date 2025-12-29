#!/bin/bash

# dotfilesディレクトリの場所を特定
DOT_DIRECTORY="$HOME/dotfiles"

# リンクを張りたいファイルのリスト
# (今後ファイルが増えたら、ここに追加)
files=(".bash_aliases" ".gitconfig" ".nanorc" ".vimrc")

echo "環境構築を開始します。"

for file in "${files[@]}"; do
    # 既にファイルやリンクがある場合はスキップ
    if [ -e "$HOME/$file" ]; then
        echo "スキップ: $file (既に存在します)"
    else
        ln -s "$DOT_DIRECTORY/$file" "$HOME/$file"
        echo "リンク完了: $file"
    fi
done

echo "source ~/.bashrc を実行してください。"
