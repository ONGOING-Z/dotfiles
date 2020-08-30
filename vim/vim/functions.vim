" ------------------------------------------------------------------- Function 
" CompileGcc()
func! CompileGcc()
    if &filetype == 'cpp'
        exec "!time g++ -std=c++11 -Wall % -o %<"
    endif
    if &filetype == 'c'
        exec "!time gcc -Wall % -o %<"
    endif
endfunc
" F9运行已经编译好的文件 20.3.16
map <F9> :call RunGcc()<CR>
func! RunGcc()
    if &filetype == 'cpp'
        exec "!time ./%<"
    endif
    if &filetype == 'c'
        exec "!time ./%<"
    endif
endfunc
