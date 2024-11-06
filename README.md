# dotfiles

存放文本三巨头[zsh][1]、[vim][2]、[tmux][3]的设置文件.

[Shell生产力环境恢复][4]

## dotfiles管理方法1

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

## dotfiles管理方法2(*推荐*)

使用[dotbot][7]

## Zsh 

### 1. 安装

- 查看shell列表
    ```bash
    cat /etc/shells
    ```

- 查看当前shell: `echo $SHELL`
- 安装zsh

    ```bash
    $ sudo apt-get install zsh  # ubuntu installation
    ```

之后使用`chsh -s /bin/zsh`将默认的shell改为zsh

### 2. 安装oh-my-zsh

第一种方法: 通过`curl`
```bash
$ sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```
第二种方法: 通过`wget`
```bash
$ sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```
## Tmux

#### 在ubuntu下的安装

```bash
$ sudo apt install tmux
```

#### tmux的升级

当前以`tmux 3.1c`版本为例

1. 首先到[tmux release页面][5]下载自己的版本,这里下载的是[tmux 3.1c][6]
2. 解压这个`.tar.gz`包
3. `cd tmux-3.1c`
4. 运行`./configure`
5. 这时可能会出现`error: libevent not found`的错误,因为这个没有安装
  解决: `sudo apt-get install libevent-dev`
  安装完成后重新执行`./configure`
6. 运行`make`
7. `sudo make install`
8. 重启终端后输入`tmux -V`检查版本是否正确.

更新tmux.conf: `tmux source ~/.tmux.conf`

## Git

#### git diff美化工具[diff-so-fancy][8]

在命令行中对于用户更加友好.

安装: `npm install -g diff-so-fancy`

## 参考
1. [为初学者准备的 ln 命令教程（5 个示例）](https://linux.cn/article-9501-1.html)
2. [文本三巨头：zsh、tmux 和 vim](https://linux.cn/article-5399-1.html)

[1]: http://www.zsh.org/
[2]: http://www.vim.org/
[3]: https://github.com/tmux/tmux
[4]: https://ongoing-z.github.io/blog/posts/2020/07/recover-the-shell-production-environment.html
[5]: https://github.com/tmux/tmux/releases/
[6]: https://github.com/tmux/tmux/releases/tag/3.1c
[7]: https://github.com/anishathalye/dotbot/
[8]: https://github.com/so-fancy/diff-so-fancy
