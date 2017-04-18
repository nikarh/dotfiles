set nocompatible
set encoding=utf-8

if has('win32') || has('win64')
    set shell=powershell
    set shellcmdflag=-command
    set runtimepath^=~/.vim
	set viminfo="~/.viminfo"
endif

call plug#begin()
if !has('nvim')
    Plug 'tpope/vim-sensible'
endif

" UI
Plug 'altercation/vim-colors-solarized'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'scrooloose/nerdtree'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }

" Integrations
Plug 'airblade/vim-gitgutter'
Plug 'editorconfig/editorconfig-vim'

" Language support
Plug 'elzr/vim-json'
Plug 'pangloss/vim-javascript'
Plug 'hashivim/vim-terraform'
Plug 'plasticboy/vim-markdown'
Plug 'fatih/vim-go', { 'do': ':GoInstallBinaries' }
Plug 'direnv/direnv.vim'

call plug#end()

set nu                " line numbers

set expandtab         " expand tabs to spaces
set tabstop=4         " show tab as 4 spaces
set shiftwidth=4      " reindentation control

set hidden            " Do not force buffer saving when switching
set autochdir         " Change directory to the one edited file is in

let g:airline#extensions#tabline#enabled = 1
let g:airline_powerline_fonts = 1
colorscheme solarized

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
set hlsearch   " when there is a previous search pattern, highlight all its matches

" sync clipboard
set clipboard=unnamed,unnamedplus
if has('unix') && !has('mac')
    " Do not clear clipboard when exiting vim
    autocmd VimLeave * call system("xsel -ib", getreg('+'))
endif

" Enable mouse
set mouse=a

" Change leader from backslash to space
let mapleader="\<Space>"
let maplocalleader="\\"

" Enable and disable search highlighting
nnoremap <leader>q :set hlsearch!<CR>

" Clear trailing whitespace
nnoremap <leader>W :%s/\s\+$//<CR><C-o>

" Toggle showing listchars
nnoremap <leader><TAB> :set list!<CR>
if &encoding == "utf-8"
    exe "set listchars=eol:\u00ac,nbsp:\u2423,conceal:\u22ef,tab:\u25b8\u2014,precedes:\u2026,extends:\u2026"
else
    set listchars=eol:$,tab:>-,extends:>,precedes:<,conceal:+
endif

nnoremap <leader>n :NERDTreeToggle<CR>

let g:vim_markdown_folding_disabled = 1

" Close VIM if NERDTree is last open window
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

" Go key bindings
au FileType go nmap <localleader>r <Plug>(go-run)
au FileType go nmap <localleader>b <Plug>(go-build)
au FileType go nmap <localleader>t <Plug>(go-test)
au FileType go nmap <localleader>c <Plug>(go-coverage)

if has('nvim') 
    au FileType go nmap <localleader>rt <Plug>(go-run-tab)
    au FileType go nmap <localleader>rs <Plug>(go-run-split)
    au FileType go nmap <localleader>rv <Plug>(go-run-vertical)
endif


au FileType go nmap <localleader>ds <Plug>(go-def-split)
au FileType go nmap <localleader>dv <Plug>(go-def-vertical)
au FileType go nmap <localleader>dt <Plug>(go-def-tab)

au FileType go nmap <localleader>gd <Plug>(go-doc)
au FileType go nmap <localleader>gv <Plug>(go-doc-vertical)
au FileType go nmap <localleader>gb <Plug>(go-doc-browser)
au FileType go nmap <localleader>s <Plug>(go-implements)
au FileType go nmap <localleader>i <Plug>(go-info)
au FileType go nmap <localleader>e <Plug>(go-rename)

let g:go_list_type = "quickfix"
let g:go_fmt_command = "goimports"
let g:go_fmt_fail_silently = 1

let g:go_highlight_functions = 1
let g:go_highlight_methods = 1
let g:go_highlight_fields = 1
let g:go_highlight_types = 1
let g:go_highlight_operators = 1
let g:go_highlight_build_constraints = 1
