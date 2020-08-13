" --------------------------------------------------------Plugin Configuration 
" Configuration for vim-markdown
" Markdown disable conceal
" 禁止隐藏代码围栏的标志
let g:vim_markdown_conceal = 0
"let g:vim_markdown_conceal = 2
let g:vim_markdown_conceal_code_blocks = 0
let g:vim_markdown_math = 1
let g:vim_markdown_toml_frontmatter = 1
let g:vim_markdown_frontmatter = 1
let g:vim_markdown_strikethrough = 1
let g:vim_markdown_autowrite = 1
let g:vim_markdown_edit_url_in = 'tab'
let g:vim_markdown_follow_anchor = 1

" Statusline
let g:syntastic_check_on_open = 1
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_wq = 0
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

" Leaderf
"let g:Lf_WindowPosition = 'popup'
"let g:Lf_PreviewInPopup = 1

" Ale config
let g:ale_sign_error = '>>'
let g:ale_sign_warning = '⚠ '
" The format for echo messages 
let g:ale_echo_msg_error_str = 'E'
let g:ale_echo_msg_warning_str = 'W'
let g:ale_echo_msg_format = '[%linter%] %s [%severity%]'

" NERDTree config
let NERDTreeQuitOnOpen = 1 " automatically close NerdTree when you open a file
let NERDTreeAutoDeleteBuffer = 1 " Automatically delete the buffer of the file you just deleted with NerdTree:
let NERDTreeMinimalUI = 1  " disable that old “Press ? for help”
let NERDTreeDirArrows = 1

let NERDChristmasTree=0
let NERDTreeWinSize=35
let NERDTreeChDirMode=2
let NERDTreeIgnore=['\~$', '\.pyc$', '\.swp$']
let NERDTreeWinPos="left"

" rainbow
"let g:rainbow_active = 1 "set to 0 if you want to enable it later via :RainbowToggle
"let g:rainbow_conf = {
"\	'guifgs': ['royalblue3', 'darkorange3', 'seagreen3', 'firebrick'],
"\	'ctermfgs': ['lightblue', 'lightyellow', 'lightcyan', 'lightmagenta'],
"\	'operators': '_,_',
"\	'parentheses': ['start=/(/ end=/)/ fold', 'start=/\[/ end=/\]/ fold', 'start=/{/ end=/}/ fold'],
"\	'separately': {
"\		'*': {},
"\		'tex': {
"\			'parentheses': ['start=/(/ end=/)/', 'start=/\[/ end=/\]/'],
"\		},
"\		'lisp': {
"\			'guifgs': ['royalblue3', 'darkorange3', 'seagreen3', 'firebrick', 'darkorchid3'],
"\		},
"\		'vim': {
"\			'parentheses': ['start=/(/ end=/)/', 'start=/\[/ end=/\]/', 'start=/{/ end=/}/ fold', 'start=/(/ end=/)/ containedin=vimFuncBody', 'start=/\[/ end=/\]/ containedin=vimFuncBody', 'start=/{/ end=/}/ fold containedin=vimFuncBody'],
"\		},
"\		'html': {
"\			'parentheses': ['start=/\v\<((area|base|br|col|embed|hr|img|input|keygen|link|menuitem|meta|param|source|track|wbr)[ >])@!\z([-_:a-zA-Z0-9]+)(\s+[-_:a-zA-Z0-9]+(\=("[^"]*"|'."'".'[^'."'".']*'."'".'|[^ '."'".'"><=`]*))?)*\>/ end=#</\z1># fold'],
"\		},
"\		'css': 0,
"\	}
"\}

" ack.vim
let g:ackprg = 'ag --nogroup --nocolor --column'


" snippets
" Trigger configuration. Do not use <tab> if you use https://github.com/Valloric/YouCompleteMe.
let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsJumpForwardTrigger="<c-b>"
let g:UltiSnipsJumpBackwardTrigger="<c-z>"

" If you want :UltiSnipsEdit to split your window.
let g:UltiSnipsEditSplit="vertical"

" incsearch
map /  <Plug>(incsearch-forward)
map ?  <Plug>(incsearch-backward)
map g/ <Plug>(incsearch-stay)
let g:incsearch#auto_nohlsearch = 1
map n  <Plug>(incsearch-nohl-n)
map N  <Plug>(incsearch-nohl-N)
map *  <Plug>(incsearch-nohl-*)
map #  <Plug>(incsearch-nohl-#)
map g* <Plug>(incsearch-nohl-g*)
map g# <Plug>(incsearch-nohl-g#)

" vim-instant-markdown
"let g:instant_markdown_slow = 1
"let g:instant_markdown_autostart = 0
"let g:instant_markdown_open_to_the_world = 1
"let g:instant_markdown_allow_unsafe_content = 1
"let g:instant_markdown_allow_external_content = 0
"let g:instant_markdown_mathjax = 1
"let g:instant_markdown_logfile = '/tmp/instant_markdown.log'
"let g:instant_markdown_autoscroll = 0
"let g:instant_markdown_port = 8888
"let g:instant_markdown_python = 1
"let g:instant_markdown_browser = "chrome --new-window"
