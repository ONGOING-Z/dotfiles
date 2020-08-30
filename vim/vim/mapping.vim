" ------------------------------------------------------------------- Mapping 
"nnoremap <C-g> :Goyo<CR>
" Tagbar
nmap <F8> : TagbarToggle<CR>
" F7键编译cpp文件 20.3.16
map <F7> :call CompileGcc()<CR>

" 虚拟行与屏幕行
" 当在vim中显示的一行很长的时候，在屏幕上显示了几行，使用
" 下面设置可以和正常jk移动相同，在行内上下移动。20.3.16
noremap <silent> <expr> j (v:count == 0 ? 'gj' : 'j')
noremap <silent> <expr> k (v:count == 0 ? 'gk' : 'k')

" Use <space> + number to jump between windows.
"set statusline=%{winnr()}
"for key in range(0, 9)
"	execute 'nnoremap <Space>'.key key.'<C-w>w'
"endfor

" NerdTree Mapping
"map <F3> :NERDTreeMirror<CR>
"map <F3> :NERDTreeToggle<CR>
map <Tab>t :NERDTreeMirror<CR>
map <Tab>t :NERDTreeToggle<CR>

" Instant_markdown_autostart
map <leader>p :InstantMarkdownPreview<CR>
map <leader>p :InstantMarkdownStop<CR>

" vim-easy-align
" 1. Start interactive EasyAlign in visual mode (e.g. vipga)
xmap ga <Plug>(EasyAlign)
" 2. Start interactive EasyAlign for a motion/text object (e.g. gaip)
nmap ga <Plug>(EasyAlign)

" easymotion
" 1. <Leader>f{char} to move to {char}
map  <Leader>f <Plug>(easymotion-bd-f)
nmap <Leader>f <Plug>(easymotion-overwin-f)
" 2. s{char}{char} to move to {char}{char}
"nmap s <Plug>(easymotion-overwin-f2)
" 3. Move to line
"map <Leader>L <Plug>(easymotion-bd-jk)
"nmap <Leader>L <Plug>(easymotion-overwin-line)
" 4. Move to word
"map  <Leader>w <Plug>(easymotion-bd-w)
"nmap <Leader>w <Plug>(easymotion-overwin-w)

" md-img-paste.vim
let g:mdip_imgdir='img'
autocmd FileType markdown nmap <buffer><silent> <leader>i :call mdip#MarkdownClipboardImage()<CR>

" tabedit to open a new file in new tab
map <C-t> :tabedit ./

" <Leader> is \ by default.
" Make it to easy to update/reload vimrc
nmap <Leader>s :source $MYVIMRC
" Open $MYVIMRC for editing in a new tab
nmap <Leader>v :tabedit $MYVIMRC
