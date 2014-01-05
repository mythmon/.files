set nocompatible " Vim defaults, instead of vi
" automatic syntax highlighting
filetype plugin indent on
syntax on

set background=dark
"colorscheme zellner

" Local vimrc files
set exrc                    " Enable per directory .vimrc files
set secure                  " Disable unsafe commands in local .vimrc files

" make searching nicer
set hlsearch
set incsearch
set ignorecase
set smartcase
set shiftwidth=4            " Tabs for auto indent
set tabstop=4               " Tabs for the tab character
set cindent                 " Indent like Ck
set autoindent              " Auto indent
set smartindent             " Intelligently
set cinkeys=0{,0},:,0#,!^F
set smarttab
set expandtab               " Tabs instead of spaces
set magic                   " For regular expressions
nma <leader>e :set lbr!<CR> " Break on words, not chars
set mouse=a

" line numbers toggle
nma <leader>n :set invnumber<CR>
" wrapping toggle
nma <leader>w :set wrap!<CR>
" remove search highlights
nma <leader>h :noh<CR>

set hidden
set history=1000
set wildmenu
set wildmode=list:longest

set title
set scrolloff=3
set ruler
set number

" Spell checking on command
if has("spell")
    " toggle spelling
    map <F7> :set spell!<CR><Bar>:echo "Spell Check: " .strpart("OffOn", 3 * &spell, 3)<CR>
endif

autocmd BufWinLeave * call clearmatches()

:highlight ExtraWhitespace ctermbg=red guibg=red
autocmd Syntax * syn match ExtraWhitespace /\s\+$\| \+\ze\t/ containedin=ALL
autocmd BufWinLeave * call clearmatches()

" Disable powerline
let g:powerline_loaded = 1
