" Python specific settings
setlocal tabstop=4
setlocal shiftwidth=4
setlocal expandtab
setlocal autoindent
setlocal smarttab
setlocal formatoptions=croql

" \b: 设置断点(python)
nmap <buffer> <leader>b oimport ipdb;ipdb.set_trace(context=5)<ESC>
