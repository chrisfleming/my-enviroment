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
Plug 'dhruvasagar/vim-table-mode'
Plug 'vimwiki/vimwiki'

if !exists('g:vscode')
	Plug 'altercation/vim-colors-solarized'
	"Plug 'ervandew/supertab'

	" VIM SNippits
	Plug 'MarcWeber/vim-addon-mw-utils'
	Plug 'tomtom/tlib_vim'
	"Plug 'garbas/vim-snipmate'
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

	"	Plug 'neoclide/coc.nvim', {'do': 'yarn install --frozen-lockfile'}
	Plug 'neoclide/coc.nvim', {'branch': 'release'}


	Plug 'neomake/neomake'

	" VOoM and vim notes for outlining and notes
	Plug 'vim-voom/VOoM'
	Plug 'chrisbra/NrrwRgn'
	" vim and tmux
	Plug 'christoomey/vim-tmux-navigator'
	" RST  Files
	Plug 'gu-fan/riv.vim'
	Plug 'gu-fan/InstantRst'

	"All the synatax
	Plug 'sheerun/vim-polyglot'
endif

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
"au FileType mail set tw=72 spell spelllang=en_gb fo+=aw
au FileType mail set formatoptions-=t spell spelllang=en_gb fo+=aw

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
" if hidden is not set, TextEdit might fail.
set hidden

" Some servers have issues with backup files, see #649
set nobackup
set nowritebackup

" Better display for messages
set cmdheight=2

" You will have bad experience for diagnostic messages when it's default 4000.
set updatetime=300

" don't give |ins-completion-menu| messages.
set shortmess+=c

" always show signcolumns
set signcolumn=yes

" Use tab for trigger completion with characters ahead and navigate.
" Use command ':verbose imap <tab>' to make sure tab is not mapped by other plugin.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion.
inoremap <silent><expr> <c-space> coc#refresh()

" Use <cr> to confirm completion, `<C-g>u` means break undo chain at current position.
" Coc only does snippet and additional edit on confirm.
inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"

" Use `[c` and `]c` to navigate diagnostics
nmap <silent> [c <Plug>(coc-diagnostic-prev)
nmap <silent> ]c <Plug>(coc-diagnostic-next)

" Remap keys for gotos
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

" Highlight symbol under cursor on CursorHold
autocmd CursorHold * silent call CocActionAsync('highlight')

" Remap for rename current word
nmap <leader>rn <Plug>(coc-rename)

" Remap for format selected region
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Remap for do codeAction of selected region, ex: `<leader>aap` for current paragraph
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)

" Remap for do codeAction of current line
nmap <leader>ac  <Plug>(coc-codeaction)
" Fix autofix problem of current line
nmap <leader>qf  <Plug>(coc-fix-current)

" Use <tab> for select selections ranges, needs server support, like: coc-tsserver, coc-python
nmap <silent> <TAB> <Plug>(coc-range-select)
xmap <silent> <TAB> <Plug>(coc-range-select)
xmap <silent> <S-TAB> <Plug>(coc-range-select-backword)

" Use `:Format` to format current buffer
command! -nargs=0 Format :call CocAction('format')

" Use `:Fold` to fold current buffer
command! -nargs=? Fold :call     CocAction('fold', <f-args>)

" use `:OR` for organize import of current buffer
command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')

" Add status line support, for integration with other plugin, checkout `:h coc-status`
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

" Using CocList
" Show all diagnostics
nnoremap <silent> <space>a  :<C-u>CocList diagnostics<cr>
" Manage extensions
nnoremap <silent> <space>e  :<C-u>CocList extensions<cr>
" Show commands
nnoremap <silent> <space>c  :<C-u>CocList commands<cr>
" Find symbol of current document
nnoremap <silent> <space>o  :<C-u>CocList outline<cr>
" Search workspace symbols
nnoremap <silent> <space>s  :<C-u>CocList -I symbols<cr>
" Do default action for next item.
nnoremap <silent> <space>j  :<C-u>CocNext<CR>
" Do default action for previous item.
nnoremap <silent> <space>k  :<C-u>CocPrev<CR>
" Resume latest coc list
nnoremap <silent> <space>p  :<C-u>CocListResume<CR>


" Relative line numbers depending on buffer focus
:set number relativenumber

:augroup numbertoggle
:  autocmd!
:  autocmd BufEnter,FocusGained,InsertLeave * set relativenumber
:  autocmd BufLeave,FocusLost,InsertEnter   * set norelativenumber
:augroup END

" vim wiki
let g:vimwiki_list = [{'path': '~/vimwiki/',
                      \ 'syntax': 'markdown', 'ext': '.md'}]


" Load project .vimrc
set exrc
set secure

