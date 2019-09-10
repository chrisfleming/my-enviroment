"neovim config
filetype off                   " required!
let g:python3_host_prog = glob('~/.virtualenvs/neovim3/bin/python3')
let g:python_host_prog = glob('~/.virtualenvs/neovim2/bin/python')
"let g:python2_host_prog = "$HOME/.pyenv/versions/neovim2/bin/python"

if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim-plugged')
Plug 'altercation/vim-colors-solarized'
Plug 'ervandew/supertab'
Plug 'dhruvasagar/vim-table-mode'

" VIM SNippits
Plug 'MarcWeber/vim-addon-mw-utils'
Plug 'tomtom/tlib_vim'
Plug 'garbas/vim-snipmate'
Plug 'honza/vim-snippets'
Plug 'pangloss/vim-javascript'
Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-git'
Plug 'tpope/vim-rails'
Plug 'tpope/vim-bundler'
Plug 'tpope/vim-abolish'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'majutsushi/tagbar'
Plug 'bling/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'sjl/gundo.vim'

" Completions
" Plug 'Shougo/deoplete.nvim'
" Plug 'zchee/deoplete-jedi'

"Plug 'neoclide/coc.nvim', { 'branch': 'release' }
"Plug 'neoclide/coc.nvim', { 'tag': '0.0.71' }

Plug 'neoclide/coc.nvim', {'do': 'yarn install --frozen-lockfile'}


Plug 'neomake/neomake'

" VOoM and vim notes for outlining and notes
Plug 'vim-voom/VOoM'
Plug 'chrisbra/NrrwRgn'
" vim and tmux
Plug 'christoomey/vim-tmux-navigator'
" RST  Files
Plug 'gu-fan/riv.vim'
Plug 'gu-fan/InstantRst'

call plug#end()

let g:deoplete#enable_at_startup = 1

filetype plugin indent on

set nowrap        " don't wrap lines
set tabstop=4     " a tab is two spaces
set backspace=indent,eol,start
                  " allow backspacing over everything in insert mode
set autoindent    " always set autoindenting on
set copyindent    " copy the previous indentation on autoindenting
set number        " always show line numbers
set shiftwidth=4  " number of spaces to use for autoindenting
set shiftround    " use multiple of shiftwidth when indenting with '<' and '>'
set showmatch     " set show matching parenthesis
set ignorecase    " ignore case when searching
set smartcase     " ignore case if search pattern is all lowercase,
                  "    case-sensitive otherwise
set smarttab      " insert tabs on the start of a line according to
                  "    shiftwidth, not tabstop
set hlsearch      " highlight search terms
set incsearch     " show search matches as you type

set history=1000         " remember more commands and search history
set undolevels=1000      " use many muchos levels of undo
set wildignore=*.swp,*.bak,*.pyc,*.class
set title                " change the terminal's title
set visualbell           " don't beep
set noerrorbells         " don't beep

let mapleader=","

" Fixing BackSpace from putty
set t_kb=

" Colour columns 80 onward:
execute "set colorcolumn=" . join(range(81,335), ',')


"show whitespace
set list
set listchars=tab:>.,trail:.,extends:#,nbsp:.

let g:Powerline_symbols = 'fancy'

"toggl ending of tabs for various file types
au BufRead,BufNewFile *.py set expandtab

"paste on F9
set pastetoggle=<F9>

set t_Co=256


syntax on

set background=dark
colorscheme solarized

" Reselect text after indent/oudent
vnoremap < <gv
vnoremap > >gv

" Enable mouse, useful for resizing splits
if has('mouse')
    set mouse=r
endif

" MOve through buffers
noremap <C-v> :bprev!<CR>
noremap <C-b> :bnext!<CR>

" Snipmate use a local directory as well:

" work with snipmate
let g:SuperTabDefaultCompletionType = "context"

call neomake#configure#automake('nrwi', 500)

" Python Settings
au FileType python setl sw=4 sts=4 et

" Email Settings
au FileType mail set tw=72 spell spelllang=en_gb fo+=aw

" Enable Tagbar
nnoremap <silent> <Leader>b :TagbarToggle<CR>

" Ctags map back to C-[ 
nnoremap <C-[> <C-t>

" Ctrlp shortcut:
nnoremap <leader>. :CtrlPTag<cr>

" Fix the naviagation shortcuts works in tandem with tmux. May need some work
" on the tmux config for nested tmux sessions.
let g:tmux_navigator_no_mappings = 1

nnoremap <silent> <C-l> :TmuxNavigateLeft<cr>
nnoremap <silent> <C-j> :TmuxNavigateDown<cr>
nnoremap <silent> <C-k> :TmuxNavigateUp<cr>
nnoremap <silent> <C-l> :TmuxNavigateRight<cr>
nnoremap <silent> <C-\> :TmuxNavigatePrevious<cr>

" Needed for airline
set laststatus=2
set ttimeoutlen=50
let g:airline#extensions#tabline#enabled = 1

let g:pad#dir = "~/Dropbox/pad-notes/"

let g:riv_python_rst_hl=1

let g:deoplete#enable_at_startup = 1

:tnoremap <Esc> <C-\><C-n>
:tnoremap <A-h> <C-\><C-N><C-w>h
:tnoremap <A-j> <C-\><C-N><C-w>j
:tnoremap <A-k> <C-\><C-N><C-w>k
:tnoremap <A-l> <C-\><C-N><C-w>l
:inoremap <A-h> <C-\><C-N><C-w>h
:inoremap <A-j> <C-\><C-N><C-w>j
:inoremap <A-k> <C-\><C-N><C-w>k
:inoremap <A-l> <C-\><C-N><C-w>l
:nnoremap <A-h> <C-w>h
:nnoremap <A-j> <C-w>j
:nnoremap <A-k> <C-w>k
:nnoremap <A-l> <C-w>l


" coc settings
" " Use `[c` and `]c` to navigate diagnostics
nmap <silent> [c <Plug>(coc-diagnostic-prev)
nmap <silent> ]c <Plug>(coc-diagnostic-next)

" Remap keys for gotos
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window
nnoremap <silent> K :call <SID>show_documentation()<CR>

" Relative line numbers depending on buffer focus
:set number relativenumber

:augroup numbertoggle
:  autocmd!
:  autocmd BufEnter,FocusGained,InsertLeave * set relativenumber
:  autocmd BufLeave,FocusLost,InsertEnter   * set norelativenumber
:augroup END


" Load project .vimrc
set exrc
set secure

