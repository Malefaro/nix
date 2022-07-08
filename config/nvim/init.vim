set nocompatible

set termencoding=UTF-8
set encoding=UTF-8

set backspace=2
set shiftwidth=4
set softtabstop=4
set tabstop=4
set expandtab
set autoread
" line length
set colorcolumn=119
" for gitgutter
set updatetime=100

" autocmd TextChanged,TextChangedI <buffer> silent write

set number

syntax enable

set mouse=a
set mousemodel=popup
set cursorline

set hlsearch
set incsearch

filetype plugin on

set list
" set listchars=tab:>-
set clipboard+=unnamedplus

if has('wsl')
    let g:clipboard = {
              \   'name': 'win32yank-wsl',
              \   'copy': {
              \      '+': 'win32yank.exe -i --crlf',
              \      '*': 'win32yank.exe -i --crlf',
              \    },
              \   'paste': {
              \      '+': 'win32yank.exe -o --lf',
              \      '*': 'win32yank.exe -o --lf',
              \   },
              \   'cache_enabled': 0,
              \ }
endif

let g:mapleader=','

call plug#begin(stdpath('data') . '/plugged')

" Color scheme
Plug 'morhetz/gruvbox'
Plug 'dracula/vim', { 'as': 'dracula' }
Plug 'crusoexia/vim-monokai'
Plug 'joshdick/onedark.vim'
Plug 'sonph/onehalf', { 'rtp': 'vim' }
Plug 'EdenEast/nightfox.nvim'

" vim-go for GoAddTags, GoImpl etc
Plug 'fatih/vim-go'

Plug 'ryanoasis/vim-devicons'
Plug 'kyazdani42/nvim-web-devicons' " lua
Plug 'numToStr/Comment.nvim'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'jiangmiao/auto-pairs'
Plug 'airblade/vim-gitgutter'
Plug 'tweekmonster/django-plus.vim'
Plug 'preservim/tagbar'
Plug 'tpope/vim-fugitive'
Plug 'shumphrey/fugitive-gitlab.vim'
Plug 'glepnir/galaxyline.nvim' , {'branch': 'main'}
" debugger
Plug 'mfussenegger/nvim-dap'
Plug 'leoluz/nvim-dap-go'
" tests
Plug 'antoinemadec/FixCursorHold.nvim'
Plug 'nvim-neotest/neotest'
Plug 'nvim-neotest/neotest-go'
Plug 'nvim-neotest/neotest-python'
Plug 'nvim-neotest/neotest-plenary'
Plug 'vim-test/vim-test'
" Plug 'rcarriga/vim-ultest', { 'do': ':UpdateRemotePlugins' }

" LSP
Plug 'neovim/nvim-lspconfig'
Plug 'williamboman/nvim-lsp-installer'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/nvim-cmp'
Plug 'L3MON4D3/LuaSnip'

Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-telescope/telescope-ui-select.nvim'
Plug 'akinsho/bufferline.nvim'
Plug 'kyazdani42/nvim-web-devicons'
Plug 'kyazdani42/nvim-tree.lua'
Plug 'mfussenegger/nvim-lint'
" Rust
Plug 'simrat39/rust-tools.nvim'
Plug 'nvim-lua/popup.nvim'
Plug 'mhinz/vim-crates'
Plug 'saecki/crates.nvim', { 'tag': 'v0.2.1' }

Plug 'LnL7/vim-nix'
Plug 'moll/vim-bbye'

call plug#end()

let g:fugitive_gitlab_domains = ['https://git.cryptology.com']

if has('nvim')
  autocmd BufRead Cargo.toml call crates#toggle()
endif

command RR :RustRunnables
command RD :RustDebuggables
" colorscheme dracula
"colorscheme monokai
" colorscheme onedark
"colorscheme gruvbox
" colorscheme dayfox

if executable("rg")
    set grepprg=rg\ --vimgrep\ --no-heading\ --smart-case
    set grepformat=%f:%l:%c:%m,%f:%l:%m
    command! -nargs=* Grep :grep! <args> | :lua require'telescope.builtin'.quickfix{layout_strategy='vertical', layout_config={preview_height=0.5}}<CR>
endif

"------------------------------------
" vim go
"------------------------------------
let g:go_highlight_types = 0
let g:go_highlight_fields = 0
let g:go_highlight_functions = 0
let g:go_highlight_function_calls = 0
let g:go_highlight_operators = 0
let g:go_highlight_extra_types = 0
let g:go_highlight_build_constraints = 0
let g:go_highlight_generate_tags = 0
let g:go_def_mapping_enabled = 0
let g:go_code_completion_enabled = 0
let g:go_doc_keywordprg_enabled = 0
"-------------------------------------

nmap <C-q> <C-[>
inoremap <C-q> <C-[>
nmap <C-s> <C-[>

inoremap <C-s> <C-[>
vnoremap <C-s> <C-[>
cnoremap <C-s> <C-[>
tnoremap <C-s> <C-[>
onoremap <C-s> <C-[>
snoremap <C-s> <C-[>
xnoremap <C-s> <C-[>

" Tagbar
nmap <F8> :TagbarToggle<CR>


map <Leader> <Plug>(easymotion-prefix)

inoremap <expr><A-j> pumvisible() ? "\<Down>" : "\<C-n>"
inoremap <expr><A-k> pumvisible() ? "\<Up>" : "\<C-p>"
inoremap <expr><C-j> pumvisible() ? "\<Down>" : "\<C-n>"
inoremap <expr><C-k> pumvisible() ? "\<Up>" : "\<C-p>"

" select in somethink like :Ag, :Files 
tmap <A-j> <Down>
tmap <A-k> <Up>
tmap <C-j> <Down>
tmap <C-k> <Up>

nmap J 5j
nmap K 5k
nmap L 3l
nmap H 3h
vmap J 5j
vmap K 5k
vmap L 3l
vmap H 3h


" exist to normal mode in terminal
tnoremap <Esc> <C-\><C-n>

nmap <silent> <ESC> :nohlsearch<CR>

nnoremap <silent><A-s> :w<CR>:lua require('lint').try_lint()<CR>
nnoremap <silent><C-s> :w<CR>:lua require('lint').try_lint()<CR>

" jump tabs
" map <C-j> <C-W>j
" map <C-k> <C-W>k
" map <C-h> <C-W>h
" map <C-l> <C-W>l

noremap <silent><C-A-j> :resize +3<CR>
noremap <silent><C-A-k> :resize -3<CR>
noremap <silent><C-A-h> :vertical resize -3<CR>
noremap <silent><C-A-l> :vertical resize +3<CR>
" resize
command -nargs=1 Vrs :vertical resize <args><CR>
command -nargs=1 Rs :resize <args><CR>


command Reload :source ~/.config/nvim/init.vim
"au BufWritePost *.go :silent !gofmt -w %
"autocmd BufWritePost *.go edit
set completeopt+=noinsert

" GitGutter
nmap <leader>hp <Plug>(GitGutterPreviewHunk)
nmap <leader>hu <Plug>(GitGutterUndoHunk)
nmap ]h <Plug>(GitGutterNextHunk)
nmap [h <Plug>(GitGutterPrevHunk)


" nvim-dap
" -----------------------------------------------------------------------------------------
nnoremap <silent> <leader>dc :lua require'dap'.continue()<CR>
nnoremap <silent> ]d :lua require'dap'.step_over()<CR>
nnoremap <silent> [d :lua require'dap'.step_out()<CR>
nnoremap <silent> ]i :lua require'dap'.step_into()<CR>
nnoremap <silent> <leader>db :lua require'dap'.toggle_breakpoint()<CR>
nnoremap <silent> <leader>dr :lua require'dap'.repl.open()<CR>
	" end debug
nnoremap <silent> <leader>de :lua require'dap'.disconnect()<CR>:lua require'dap'.close()<CR>
	" list breakpoints
nnoremap <silent> <leader>dl :lua require'dap'.list_breakpoints()<CR>:copen<CR>
" end nvim-dap
" -----------------------------------------------------------------------------------------
" ___________________________________________________________________________________
" LUA
" ___________________________________________________________________________________
lua <<EOF
-- require('lualine').setup({
-- sections = {
-- 	lualine_c = {{'filename', path=1}}
-- 	}
-- })
-- require("transparent").setup({
--   enable = true,
-- })

local widgets = require('dap.ui.widgets')
local scopes_sidebar = widgets.sidebar(widgets.scopes, {}, "45 vsplit")
local frames_sidebar = widgets.sidebar(widgets.frames, {}, "rightbelow 30 vsplit")
local dap = require('dap')
vim.fn.sign_define('DapBreakpoint', {text='🛑', texthl='', linehl='', numhl=''})
local repl = dap.repl
function setupDebug()
	scopes_sidebar.open()
	frames_sidebar.open()
	repl.open()
end

function closeDebug()
	scopes_sidebar.close()
	frames_sidebar.close()
	repl.close()
end
EOF

" ___________________________________________________________________________________
" END OF LUA
" ___________________________________________________________________________________

" open debug windows
nnoremap <silent> <leader>ds :lua setupDebug()<CR>
" close debug windows
nnoremap <silent> <leader>dx :lua closeDebug()<CR>

" vim-test
" let test#go#gotest#options = "-count=1 -timeout=60s -v"
" let test#python#runner = 'pytest'
" let test#python#pytest#options = "--dc=Local --ds=gateway.settings_local --color=yes --reuse-db"
" let test#rust#cargotest#options = "-- --nocapture"
" nmap <leader>tn <Plug>(ultest-run-nearest)
" nmap <leader>td <Plug>(ultest-debug-nearest)
" nmap <leader>ts <Plug>(ultest-summary-toggle)
" nmap <leader>to <Plug>(ultest-output-jump)
" nmap <leader>ta <Plug>(ultest-attach)
" nmap <leader>tf <Plug>(ultest-run-file)
" 	" end
" nmap <leader>te <Plug>(ultest-stop-file)

" ___________________________________________________________________________________
" LUA dap
" ___________________________________________________________________________________

lua <<EOF
local dap = require('dap')
dap.adapters.go = function(callback, config)
    local stdout = vim.loop.new_pipe(false)
    local handle
    local pid_or_err
    local port = 38697
    local opts = {
      stdio = {nil, stdout},
      args = {"dap", "-l", "127.0.0.1:" .. port},
      detached = true
    }
    handle, pid_or_err = vim.loop.spawn("dlv", opts, function(code)
      stdout:close()
      handle:close()
      if code ~= 0 then
        print('dlv exited with code', code)
      end
    end)
    assert(handle, 'Error running dlv: ' .. tostring(pid_or_err))
    stdout:read_start(function(err, chunk)
      assert(not err, err)
      if chunk then
        vim.schedule(function()
          require('dap.repl').append(chunk)
        end)
      end
    end)
    -- Wait for delve to start
    vim.defer_fn(
      function()
        callback({type = "server", host = "127.0.0.1", port = port})
      end,
      100)
  end
  -- https://github.com/go-delve/delve/blob/master/Documentation/usage/dlv_dap.md
  dap.configurations.go = {
    {
      type = "go",
      name = "Debug",
      request = "launch",
      program = "${file}"
    },
    {
      type = "go",
      name = "Debug test", -- configuration for debugging test files
      request = "launch",
      mode = "test",
      program = "${file}"
    },
    -- works with go.mod packages and sub packages 
    {
      type = "go",
      name = "Debug test (go.mod)",
      request = "launch",
      mode = "test",
      program = "./${relativeFileDirname}"
    } 
}


function dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end

EOF


" ___________________________________________________________________________________
" END OF LUA
" ___________________________________________________________________________________


" Import lua config

lua <<EOF
require('neotest_cfg')
require('debugger')
require('lsp_setup')
EOF
