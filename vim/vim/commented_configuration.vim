" =============================================================================
"                                暂时注释不用
" =============================================================================
" 
" 显示空格并以红色高亮（暂时不用)
"highlight WhitespaceEOL ctermbg=red guibg=red 
"match WhitespaceEOL /\s\+$/

" 在旁边高亮未修改部分
"let g:gitgutter_override_sign_column_highlight = 0
"highlight SignColumn ctermbg=green

" GitGutter Signs' colors and symbols
"highlight GitGutterAdd    guifg=#009900 guibg=#073642 ctermfg=2 ctermbg=0
"highlight GitGutterChange guifg=#bbbb00 guibg=#073642 ctermfg=3 ctermbg=0
"highlight GitGutterDelete guifg=#FF0000 guibg=#073642 ctermfg=1 ctermbg=0

"let g:gitgutter_sign_added = '++'
"let g:gitgutter_sign_modified = '+'
"let g:gitgutter_sign_removed = '--'
"let g:gitgutter_sign_removed_first_line = 'r'
"let g:gitgutter_sign_modified_removed = 'w'
" 禁止光标闪烁
"set gcr=a:block-blinkon0 这种方式没有用，我所使用的平台为ubuntu，需要到
"系统设置 - 键盘下勾选掉，即可。

"-------------
" iab用于编辑模式，实现替换功能
"-------------
" insert into now time
"iab xtime <c-r>=strftime("%Y-%m-%d %H:%M:%S")<cr>
"iab xdate <c-r>=strftime("%Y-%m-%d %a %Y年%j天")<cr>

"-------------
" Hitting space make j and k move faster
"-------------
"nmap <Space>j 10j<Space>
"nmap <Space>k 10k<Space>
"nmap <Space><Space> <Nop> " Hit space again to exits the mode

"-------------
" syntastic
"-------------
" error/warning的图标 
"let g:syntastic_enable_signs = 1 
"let g:syntastic_error_symbol='✗' 
"let g:syntastic_warning_symbol='►'
"let g:syntastic_warning_symbol='⚠ '
" 总是打开Location List（相当于QuickFix）窗口，如果你发现syntastic因为与其他
" 插件冲突而经常崩溃，将下面选项置0
"let g:syntastic_always_populate_loc_list = 1
" 自动打开Locaton List，默认值为2，表示发现错误时不自动打开，当修正以后没有再
" 发现错误时自动关闭，置1表示自动打开自动关闭，0表示关闭自动打开和自动关闭，
" 3表示自动打开，但不自动关闭 
"let g:syntastic_auto_loc_list = 1 
" 修改Locaton List窗口高度
" let g:syntastic_loc_list_height = 5
" 打开文件时自动进行检查 
"let g:syntastic_check_on_open = 1 
" 自动跳转到发现的第一个错误或警告处[not ok, 自动跳转很不好]
" let g:syntastic_auto_jump = 1
" 进行实时检查，如果觉得卡顿，将下面的选项置为1 
"let g:syntastic_check_on_wq = 0 
" 高亮错误
"let g:syntastic_enable_highlighting=1

" Git 并不怎么会看git信息
"Plug 'gregsexton/gitv', {'on': ['Gitv']}
"Plug 'airblade/vim-gitgutter'
