# Dotfiles

個人用の開発環境設定をGitで管理し、複数のPCで共有するリポジトリです。Linuxの設定と、Windows・Linuxで使うCodexの指示・自作スキルを管理します。

## 構成

- [codex/](codex/README.md): 個人用AGENTSと自作スキル。Windows・Linuxそれぞれの導入方法を記載しています。
- [linux/](linux/README.md): Bash・Git・nano・Vimの設定と導入方法。

各設定は独立して導入できます。必要なもののREADMEを読み、導入スクリプトを実行してください。Windows固有の設定はまだありません。

## 取得

```bash
git clone https://github.com/taketake-dev/dotfiles.git
cd dotfiles
```

clone先は任意です。導入スクリプトは自身の場所から原本を探します。

## 編集と別PCとの共有

設定はこのリポジトリの原本を編集します。導入先はリンクなので、導入先から編集した場合も同じ原本が変わります。

編集したPCで変更を確認してcommit・pushします。

```bash
git status
git add <変更したファイル>
git commit -m "設定を更新"
git push
```

別のPCでは、cloneしたリポジトリ内で更新を取得します。

```bash
git pull --ff-only
```

既存リンクが参照する原本の更新はそのまま反映されます。Codexのスキルを追加しても、`.agents/` 全体へのリンクで反映されるため、再導入は不要です。設定の追加方法は各READMEを参照してください。Git操作はスクリプトから自動実行しません。

原本やclone先を移動・削除するとリンクが切れるため、配置場所を維持してください。スクリプトは古いリンクを自動削除しません。

## 管理する情報

認証情報・秘密情報・会話履歴・DB・キャッシュ・Codexの `config.toml` は取り込みません。このリポジトリは公開なので、追加する内容をcommit前に確認してください。`.gitignore` は未追跡ファイルをGit管理から除外する設定であり、秘密情報を保護する仕組みではありません。
