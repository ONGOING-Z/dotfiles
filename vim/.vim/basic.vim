" ---------------------------------------------------------Basic Configuration 
" ---- baisc ui config

set shortmess+=atI     " disable startup message
set noshowmode       " hide mode ??
set shell=bash\ -i
set background=dark " set dark scheme
set number
set cc=80          " Display a vertical bar in 80 characters
" String to put at the start of lines that have been wrapped "
let &showbreak='↪ '

let $LANG='en'
let g:indentLine_color_term = 239

set title          " Display filename on tag page.
set showcmd
set autoread       " Auto load when external files have been changed

filetype plugin on " Enable filetype plugins
filetype indent on

" Coding folding depending on the syntax
" Press <za> to fold and unfold
set foldmethod=syntax
set nofoldenable                                " Disable code folding when launching vim

" ---- Searching
set showmatch                                   " Display matching parentheses
set fencs=utf-8,GB18030,ucs-bom,default,latin1  " Encoding configuration
set incsearch                                   " Display the matched results instantly
set hlsearch                                    " Highlight search results

" Gives vim access to a broader range of colors
" Set termguicolors

if has("termguicolors")
    " fix bug for vim
    let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
    let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
    " Enable comment italics, but if remove the 2 lines below, italics also
    " works.
    let &t_ZH = "\e[3m"
    let &t_ZR = "\e[23m"

    " enable true color
    set termguicolors
endif

" Ignoring uppercase and lowercase when searching
set ignorecase
set smartcase

" Highlight syntax
syntax enable
syntax on

set list listchars=tab:»·,trail:· " Display extra whitespace
set lcs=eol:¬,nbsp:_

" Save file when it loses focus.
set autowrite

" Disable swap files.
set noswapfile

" ---- From https://secluded.site/vim-as-a-markdown-editor/ ----
" Treat all .md files as markdown
autocmd BufNewFile,BufRead *.md set filetype=markdown
" Hightlight the line the cursor is on
autocmd FileType markdown set cursorline
" Hide and format markdown element like **bold**
autocmd FileType markdown set conceallevel=2

" Set spell check to British English
"autocmd FileType markdown setlocal spell spelllang=en_gb
" Open Goyo for all markdown files
"autocmd FileType markdown Goyo
" ---------

" Limit line length
set textwidth=80
set colorcolumn=1

" Highlight current line
au WinLeave * set nocursorline nocursorcolumn
au WinEnter * set cursorline cursorcolumn
set cursorline

" Softtabs, 4 spaces
set tabstop=4
set shiftwidth=4
set shiftround
set expandtab

" Disable mouse support 
set mouse=

" Encoding open and close
set fileencodings=utf-8,ucs-bom,gb18030,gbk,gb2312,cp936

"let &t_ZH = "\e[3m"
"let &t_ZR = "\e23m"
"highlight Comment cterm=italic gui=italic

" template
autocmd BufNewFile *.cpp 0r ~/.vim/template/cppconfig.cpp
