请运行健康检查：

1. 检查 dotfiles symlink 是否完好（对比 install.conf.yaml）
2. 检查必要工具是否存在：git, zsh, brew, fzf, rg, bat, fd
3. 检查 git submodule 状态
4. 检查是否存在未追踪的敏感文件（.env, secrets, token 等）
5. 给出健康状态总结

$ARGUMENTS
