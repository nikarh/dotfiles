set nocompatible
set encoding=utf-8

if has('win32') || has('win64')
    set shell=powershell
    set shellcmdflag=-command
    set runtimepath^=~/.vim
	set viminfo="~/.viminfo"
endif

call plug#begin()
Plug 'tpope/vim-sensible'
Plug 'altercation/vim-colors-solarized'
Plug 'elzr/vim-json'
Plug 'pangloss/vim-javascript'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'airblade/vim-gitgutter'
Plug 'hashivim/vim-terraform'
call plug#end()

set nu                " line numbers

set expandtab         " expand tabs to spaces
set tabstop=4         " show tab as 4 spaces
set shiftwidth=4      " reindentation control

set hidden            " Do not force buffer saving when switching
set autochdir         " Change directory to the one edited file is in

let g:airline#extensions#tabline#enabled = 1
let g:airline_powerline_fonts = 1
colorsche solarized

if has('gui_running')
    set background=light
    set guifont=Hack\ 12

    set guioptions-=m  "remove menu bar
    set guioptions-=T  "remove toolbar
    set guioptions-=r  "remove right-hand scroll bar
    set guioptions-=L  "remove left-hand scroll bar
else
    set background=dark
endif

" Unmap arrows
map <up> <nop>
map <down> <nop>
map <left> <nop>
map <right> <nop>

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

" Jumping between buffers:
noremap <C-n> :bnext<CR>
noremap <C-p> :bprev<CR>
noremap <C-e> :b#<CR>

" Improve search
set incsearch  " While typing a search command, show pattern matches as it is typed
set ignorecase " Ignore case in search patterns
set smartcase  " Override the 'ignorecase' if the search pattern contains upper case characters
set hlsearch   " When there is a previous search pattern, highlight all its matches

" Change leader from backslash to space
let mapleader="\<Space>"

" Enable and disable search highlighting
nmap <leader>q :set hlsearch!<CR>

" Clear trailing whitespace
nnoremap <leader>W :%s/\s\+$//<CR><C-o>

" Toggle showing listchars
:nnoremap <leader><TAB> :set list!<CR>
if &encoding == "utf-8"
  exe "set listchars=eol:\u00ac,nbsp:\u2423,conceal:\u22ef,tab:\u25b8\u2014,precedes:\u2026,extends:\u2026"
else
  set listchars=eol:$,tab:>-,extends:>,precedes:<,conceal:+
endif

" sync clipboard
set clipboard=unnamed,unnamedplus
if has('unix')
    " Do not clear clipboard when exiting vim
    autocmd VimLeave * call system("xsel -ib", getreg('+'))
endif

" Enable mouse
set mouse=a

