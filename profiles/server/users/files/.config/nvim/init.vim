" vi: ft=vim

set nocompatible
set encoding=utf-8

set nu                " line numbers

set expandtab         " expand tabs to spaces
set tabstop=4         " show tab as 4 spaces
set shiftwidth=4      " reindentation control

set hidden            " Do not force buffer saving when switching
set autochdir         " Change directory to the one edited file is in

set background=dark

highlight clear SignColumn

" Make j and k move up and down better for wrapped lines
noremap k gk
noremap j gj
noremap gk k
noremap gj j

" Ctrl-<hjkl> to move windows
noremap <C-h> <C-w>h
noremap <C-j> <C-w>j
noremap <C-k> <C-w>k
noremap <C-l> <C-w>l

noremap <C-e> :History <Cr>

" Improve search
set incsearch  " While typing a search command, show pattern matches as it is typed
set ignorecase " Ignore case in search patterns
set smartcase  " Override the 'ignorecase' if the search pattern contains upper case characters
set hlsearch   " when there is a previous search pattern, highlight all its matches

" Enable mouse
set mouse=a

" sync clipboard
set clipboard=unnamed,unnamedplus
if has('unix') && !has('mac')
    " Do not clear clipboard when exiting vim
    if !empty($DISPLAY)
        autocmd VimLeave * call system("xsel -ib", getreg('+'))
    endif
endif

" Enable and disable search highlighting
nnoremap <leader>q :set hlsearch!<CR>
