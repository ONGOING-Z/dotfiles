"---------------------------------------------------------------------Vim-Plug
call plug#begin('~/.vim/plugged')
Plug 'morhetz/gruvbox'
" Statusline
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
"Plug 'vim-syntastic/syntastic' " Syntax checking
Plug 'dense-analysis/ale'       " Another syntax checking 20.3.24
Plug 'majutsushi/tagbar'        " Display variables and functions in code
                                " Prepare:安装此插件同时需要安装ctags
                                " sudo apt-get install ctags
                                " ctags -R --c++-kinds=+p --fields=+iaS
                                " --extra=+q 

" 由于此插件太多庞大，一次安装并没有成功，未安装成功每次开启vim都会提示，
" 就将之卸载。
"Plug 'Valloric/YouCompleteMe', { 'do': './install.py' }

" Surroundings
Plug 'tpope/vim-surround'

" Debug
"Plug 'puremourning/vimspector'  " 20.3.8
Plug 'Yggdroot/indentLine'     " 20.3.8 对齐线
Plug 'jiangmiao/auto-pairs'    " 20.3.9
"Plug 'xolox/vim-notes'
"Plug 'xolox/vim-misc'          " 安装vim-note必须安装misc
Plug 'itchyny/calendar.vim'
"Plug 'vimwiki/vimwiki'
"Plug 'Yggdroot/LeaderF'        "20.3.14
                               " Attention this exten needs python envir.
Plug 'RRethy/vim-illuminate'   "20.3.16  高亮鼠标所在相同单词
"Plug 'tpope/vim-fugitive'      "20.3.20 Git
Plug 'preservim/nerdtree'      " 20.4.3
"Plug 'preservim/nerdcommenter' "20.3.20 Comment
Plug 'godlygeek/tabular'       "20.3.24 markdown
Plug 'plasticboy/vim-markdown' "20.3.24 markdown
"Plug 'iamcco/markdown-preview.vim'  " 20.7.13 markdown preview,
"下边这个star比较多
Plug 'suan/vim-instant-markdown', {'for': 'markdown'} " 20.7.13
"Plug 'junegunn/goyo.vim'       "20.4.12 concentrate
"Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
"Plug 'junegunn/fzf.vim'        "20.5.4
Plug 'wincent/command-t'       " 20.6.14
"Plug 'luochen1990/rainbow'      " 20.6.15 
" 20.7.13 注释掉此插件，觉得这个颜色对我干扰较大。
Plug 'mileszs/ack.vim'          " 20.6.15
Plug 'mhinz/vim-startify'       " 20.6.28
"Plug 'danilamihailov/beacon.nvim' " 20.6.28 This enable the cursor more realizable when jump more distance 没啥用。浪费资源。
Plug 'SirVer/ultisnips'         " 20.7.4
Plug 'honza/vim-snippets'       " 20.7.4
Plug 'dhruvasagar/vim-table-mode' " 20.7.5
Plug 'haya14busa/incsearch.vim'   " 20.7.7
Plug 'junegunn/vim-easy-align'    " 20.7.10
Plug 'easymotion/vim-easymotion'  " 20.7.10
"Plug 'neoclide/coc.nvim', {'branch': 'release'} " 20.7.13
"Plug 'neoclide/coc.nvim', {'do': 'yarn install --frozen-lockfile'}
"Plug 'neoclide/coc.nvim', {'tag': '*', 'branch': 'release'} " 20.7.30
"Plug 'wakatime/vim-wakatime'      " 20.7.15 wakatime tracking
Plug 'ferrine/md-img-paste.vim'    " 20.7.16 display the modification
if has('nvim') || has('patch-8.0.902')  " 20.7.30
  Plug 'mhinz/vim-signify'
else
  Plug 'mhinz/vim-signify', { 'branch': 'legacy' }
endif

Plug 'codota/tabnine-vim'  " 20.8.7

Plug 'tpope/vim-eunuch'
Plug 'sheerun/vim-polyglot'
Plug 'ervandew/supertab'
call plug#end()
