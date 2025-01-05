set number
set tabstop=4
set autoindent
set expandtab
set mouse=v

syntax on

packadd! dracula
syntax enable
colorscheme dracula

autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab
