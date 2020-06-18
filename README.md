# dotfiles

存放文本三巨头[zsh][1]、[vim][2]、[tmux][3]的设置文件.

Save my development environment.

## 管理dotfiles

1. 新建一个`dotfiles/`文件夹
```bash
$ mkdir dotfiles; cd dotfiles; git init
```
2. 将本机家目录下的需要备份的dotfiles移入上边新建的`dotfiles/`文件夹
```bash
$ cd # 回到家目录
$ mv .vimrc dotfiles/vimrc
$ mv .zshrc dotfiles/zshrc
$ mv .tmux.conf dotfiles/tmux.conf
```
3. 将系统下的dotfile链接到新建dotfiles文件夹里的文件
```bash
$ ln -s dotfiles/vimrc .vimrc
$ ln -s dotfiles/zshrc .zshrc
$ ln -s dotfiles/tmux.conf .tmux.conf
```

4. 换电脑后，需要恢复自己的配置
  1. 首先删除原机上的.vimrc/.zshrc...
  2. 链接到自己的dotfiles


[1]: http://www.zsh.org/
[2]: http://www.vim.org/
[3]: https://github.com/tmux/tmux

## 参考
1. [为初学者准备的 ln 命令教程（5 个示例）](https://linux.cn/article-9501-1.html)
