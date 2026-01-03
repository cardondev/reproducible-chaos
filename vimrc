" =============================================================================
" VIMRC - Vim Configuration
" Theme: Catppuccin Mocha
" Compatible: vim 7.4+, RHEL 7+
" =============================================================================

" -----------------------------------------------------------------------------
" Leader Key
" -----------------------------------------------------------------------------
let mapleader = " "

" -----------------------------------------------------------------------------
" General Settings
" -----------------------------------------------------------------------------
set nocompatible
set encoding=utf-8
set fileencoding=utf-8
set fileencodings=utf-8,latin1
set ttyfast
set lazyredraw
set updatetime=300
set timeoutlen=500
set history=1000
set undolevels=1000
set backspace=indent,eol,start
set hidden

" -----------------------------------------------------------------------------
" Display Settings
" -----------------------------------------------------------------------------
syntax on
set number
set relativenumber
set ruler
set cursorline
set showmatch
set matchtime=2
set scrolloff=5
set sidescrolloff=5
set display+=lastline
set laststatus=2
set showcmd
set showmode
set title

" -----------------------------------------------------------------------------
" Line Wrapping
" -----------------------------------------------------------------------------
set wrap
set linebreak
set textwidth=0
set wrapmargin=0

" -----------------------------------------------------------------------------
" Indentation
" -----------------------------------------------------------------------------
set expandtab
set shiftwidth=4
set tabstop=4
set softtabstop=4
set autoindent
set smartindent
set shiftround

" -----------------------------------------------------------------------------
" Search Settings
" -----------------------------------------------------------------------------
set incsearch
set hlsearch
set ignorecase
set smartcase
set wrapscan

" -----------------------------------------------------------------------------
" File Management
" -----------------------------------------------------------------------------
set autoread
set nobackup
set nowritebackup
set noswapfile
filetype plugin indent on

" Auto-reload on focus
au FocusGained,BufEnter * checktime

" -----------------------------------------------------------------------------
" Completion
" -----------------------------------------------------------------------------
set wildmenu
set wildmode=longest:full,full
set wildignore+=*.o,*.obj,*.pyc,*.pyo,*~,*.swp
set wildignore+=*.so,*.dll,*.exe
set wildignore+=*.tar,*.gz,*.zip,*.rar
set completeopt=menu,menuone,noselect

" -----------------------------------------------------------------------------
" Folding
" -----------------------------------------------------------------------------
set foldmethod=indent
set foldlevel=99
set nofoldenable

" -----------------------------------------------------------------------------
" Catppuccin Mocha Color Scheme (256-color compatible)
" -----------------------------------------------------------------------------
set background=dark
set t_Co=256

" Define colors
let s:rosewater = 224
let s:flamingo  = 210
let s:pink      = 218
let s:mauve     = 183
let s:red       = 203
let s:maroon    = 181
let s:peach     = 216
let s:yellow    = 223
let s:green     = 151
let s:teal      = 116
let s:sky       = 117
let s:sapphire  = 116
let s:blue      = 111
let s:lavender  = 183
let s:text      = 189
let s:subtext1  = 251
let s:subtext0  = 249
let s:overlay2  = 247
let s:overlay1  = 245
let s:overlay0  = 243
let s:surface2  = 241
let s:surface1  = 239
let s:surface0  = 237
let s:base      = 235
let s:mantle    = 234
let s:crust     = 233

" Clear existing highlights
highlight clear
if exists("syntax_on")
    syntax reset
endif

" Basic highlights
exe 'highlight Normal ctermfg=' . s:text . ' ctermbg=' . s:base
exe 'highlight Comment ctermfg=' . s:overlay1
exe 'highlight Constant ctermfg=' . s:peach
exe 'highlight String ctermfg=' . s:green
exe 'highlight Character ctermfg=' . s:teal
exe 'highlight Number ctermfg=' . s:peach
exe 'highlight Boolean ctermfg=' . s:peach
exe 'highlight Float ctermfg=' . s:peach
exe 'highlight Identifier ctermfg=' . s:flamingo
exe 'highlight Function ctermfg=' . s:blue
exe 'highlight Statement ctermfg=' . s:mauve
exe 'highlight Conditional ctermfg=' . s:mauve
exe 'highlight Repeat ctermfg=' . s:mauve
exe 'highlight Label ctermfg=' . s:sapphire
exe 'highlight Operator ctermfg=' . s:sky
exe 'highlight Keyword ctermfg=' . s:mauve
exe 'highlight Exception ctermfg=' . s:mauve
exe 'highlight PreProc ctermfg=' . s:pink
exe 'highlight Include ctermfg=' . s:mauve
exe 'highlight Define ctermfg=' . s:mauve
exe 'highlight Macro ctermfg=' . s:mauve
exe 'highlight PreCondit ctermfg=' . s:pink
exe 'highlight Type ctermfg=' . s:yellow
exe 'highlight StorageClass ctermfg=' . s:yellow
exe 'highlight Structure ctermfg=' . s:yellow
exe 'highlight Typedef ctermfg=' . s:yellow
exe 'highlight Special ctermfg=' . s:pink
exe 'highlight SpecialChar ctermfg=' . s:pink
exe 'highlight Tag ctermfg=' . s:lavender
exe 'highlight Delimiter ctermfg=' . s:overlay2
exe 'highlight SpecialComment ctermfg=' . s:overlay1
exe 'highlight Debug ctermfg=' . s:peach
exe 'highlight Underlined ctermfg=' . s:text . ' cterm=underline'
exe 'highlight Error ctermfg=' . s:red . ' ctermbg=' . s:base
exe 'highlight Todo ctermfg=' . s:base . ' ctermbg=' . s:yellow

" UI Elements
exe 'highlight CursorLine ctermbg=' . s:surface0 . ' cterm=NONE'
exe 'highlight CursorColumn ctermbg=' . s:surface0
exe 'highlight ColorColumn ctermbg=' . s:surface0
exe 'highlight LineNr ctermfg=' . s:surface1
exe 'highlight CursorLineNr ctermfg=' . s:lavender . ' ctermbg=' . s:surface0
exe 'highlight VertSplit ctermfg=' . s:surface1 . ' ctermbg=' . s:base
exe 'highlight Folded ctermfg=' . s:blue . ' ctermbg=' . s:surface1
exe 'highlight FoldColumn ctermfg=' . s:overlay0 . ' ctermbg=' . s:base
exe 'highlight SignColumn ctermfg=' . s:overlay0 . ' ctermbg=' . s:base
exe 'highlight Pmenu ctermfg=' . s:overlay2 . ' ctermbg=' . s:surface0
exe 'highlight PmenuSel ctermfg=' . s:text . ' ctermbg=' . s:surface1
exe 'highlight PmenuSbar ctermbg=' . s:surface1
exe 'highlight PmenuThumb ctermbg=' . s:overlay0
exe 'highlight StatusLine ctermfg=' . s:text . ' ctermbg=' . s:mantle
exe 'highlight StatusLineNC ctermfg=' . s:surface1 . ' ctermbg=' . s:mantle
exe 'highlight TabLine ctermfg=' . s:overlay0 . ' ctermbg=' . s:mantle
exe 'highlight TabLineFill ctermbg=' . s:mantle
exe 'highlight TabLineSel ctermfg=' . s:green . ' ctermbg=' . s:surface0
exe 'highlight Search ctermfg=' . s:base . ' ctermbg=' . s:yellow
exe 'highlight IncSearch ctermfg=' . s:base . ' ctermbg=' . s:mauve
exe 'highlight Visual ctermbg=' . s:surface1
exe 'highlight VisualNOS ctermbg=' . s:surface1
exe 'highlight MatchParen ctermfg=' . s:peach . ' ctermbg=' . s:surface1 . ' cterm=bold'
exe 'highlight NonText ctermfg=' . s:surface1
exe 'highlight SpecialKey ctermfg=' . s:surface1
exe 'highlight Directory ctermfg=' . s:blue
exe 'highlight Title ctermfg=' . s:blue . ' cterm=bold'
exe 'highlight ErrorMsg ctermfg=' . s:red . ' ctermbg=' . s:base
exe 'highlight WarningMsg ctermfg=' . s:yellow
exe 'highlight MoreMsg ctermfg=' . s:green
exe 'highlight Question ctermfg=' . s:green
exe 'highlight WildMenu ctermfg=' . s:base . ' ctermbg=' . s:mauve

" Diff highlights
exe 'highlight DiffAdd ctermfg=' . s:green . ' ctermbg=' . s:surface0
exe 'highlight DiffChange ctermfg=' . s:yellow . ' ctermbg=' . s:surface0
exe 'highlight DiffDelete ctermfg=' . s:red . ' ctermbg=' . s:surface0
exe 'highlight DiffText ctermfg=' . s:blue . ' ctermbg=' . s:surface0 . ' cterm=bold'

" Spell checking
exe 'highlight SpellBad ctermfg=' . s:red . ' cterm=underline'
exe 'highlight SpellCap ctermfg=' . s:yellow . ' cterm=underline'
exe 'highlight SpellRare ctermfg=' . s:mauve . ' cterm=underline'
exe 'highlight SpellLocal ctermfg=' . s:teal . ' cterm=underline'

" -----------------------------------------------------------------------------
" Status Line
" -----------------------------------------------------------------------------
set statusline=
set statusline+=%#PmenuSel#
set statusline+=\ %{toupper(mode())}\ 
set statusline+=%#StatusLine#
set statusline+=\ %n\ 
set statusline+=%#CursorLine#
set statusline+=\ %f
set statusline+=%m
set statusline+=%r
set statusline+=%=
set statusline+=%#StatusLine#
set statusline+=\ %y\ 
set statusline+=%#PmenuSel#
set statusline+=\ %l:%c\ 
set statusline+=%#StatusLine#
set statusline+=\ %p%%\ 

" -----------------------------------------------------------------------------
" Trailing Whitespace Highlight
" -----------------------------------------------------------------------------
exe 'highlight ExtraWhitespace ctermbg=' . s:red
match ExtraWhitespace /\s\+$/
autocmd BufWinEnter * match ExtraWhitespace /\s\+$/
autocmd InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/
autocmd InsertLeave * match ExtraWhitespace /\s\+$/
autocmd BufWinLeave * call clearmatches()

" -----------------------------------------------------------------------------
" Show Invisible Characters (disabled by default)
" -----------------------------------------------------------------------------
set nolist
set listchars=tab:>-,trail:~,extends:>,precedes:<,space:.

" -----------------------------------------------------------------------------
" Key Mappings
" -----------------------------------------------------------------------------
" Quick save and quit
nnoremap <leader>w :w<CR>
nnoremap <leader>q :q<CR>
nnoremap <leader>x :x<CR>
nnoremap <leader>Q :q!<CR>

" Clear search highlight
nnoremap <leader><space> :nohlsearch<CR>

" Window navigation
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Window splits
nnoremap <leader>v :vsplit<CR>
nnoremap <leader>s :split<CR>

" Buffer navigation
nnoremap <leader>bn :bnext<CR>
nnoremap <leader>bp :bprev<CR>
nnoremap <leader>bd :bdelete<CR>

" Tab navigation
nnoremap <leader>tn :tabnew<CR>
nnoremap <leader>tc :tabclose<CR>
nnoremap <Tab> :tabnext<CR>
nnoremap <S-Tab> :tabprev<CR>

" Move lines up/down
nnoremap <A-j> :m .+1<CR>==
nnoremap <A-k> :m .-2<CR>==
vnoremap <A-j> :m '>+1<CR>gv=gv
vnoremap <A-k> :m '<-2<CR>gv=gv

" Indent in visual mode stays in visual mode
vnoremap < <gv
vnoremap > >gv

" Toggle line numbers
nnoremap <leader>n :set number! relativenumber!<CR>

" Toggle paste mode
set pastetoggle=<F2>

" Toggle invisible characters
nnoremap <leader>l :set list!<CR>

" Strip trailing whitespace
nnoremap <leader>W :%s/\s\+$//e<CR>

" Quick escape from insert mode
inoremap jk <Esc>

" Center screen after search
nnoremap n nzzzv
nnoremap N Nzzzv

" Yank to end of line
nnoremap Y y$

" -----------------------------------------------------------------------------
" Auto Commands
" -----------------------------------------------------------------------------
augroup filetypes
    autocmd!
    autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab
    autocmd FileType json setlocal ts=2 sts=2 sw=2 expandtab
    autocmd FileType html setlocal ts=2 sts=2 sw=2 expandtab
    autocmd FileType css setlocal ts=2 sts=2 sw=2 expandtab
    autocmd FileType javascript setlocal ts=2 sts=2 sw=2 expandtab
    autocmd FileType sh setlocal ts=4 sts=4 sw=4 expandtab
    autocmd FileType python setlocal ts=4 sts=4 sw=4 expandtab
    autocmd FileType make setlocal noexpandtab
augroup END

" Return to last edit position
augroup remember_position
    autocmd!
    autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
augroup END

" -----------------------------------------------------------------------------
" netrw (built-in file browser)
" -----------------------------------------------------------------------------
let g:netrw_banner = 0
let g:netrw_liststyle = 3
let g:netrw_browse_split = 4
let g:netrw_altv = 1
let g:netrw_winsize = 25

" Toggle file browser
nnoremap <leader>e :Lexplore<CR>
