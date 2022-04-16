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

local map = vim.api.nvim_set_keymap
local opts = { noremap=true, silent=true }
local nvim_lsp = require'lspconfig'
function on_attach(client, bufnr)
	local function map(...)
		vim.api.nvim_buf_set_keymap(bufnr, ...)
	end
    map('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', {})
	map('n', 'U', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
	map('n', '[c', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
	map('n', ']c', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
	map('n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
	map('n', '<leader>gs', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
	map('i', '<A-u>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
	map('n', '<leader>f', '<cmd>lua vim.lsp.buf.formatting_sync()<CR>', opts)
	--map('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
	vim.api.nvim_command("au BufWritePre <buffer> lua vim.lsp.buf.formatting_sync()")
end

-------------------------------------------------------------------------
--INSTALL LSP's
--_______________________________________________________________________

-- local servers = { 'gopls', 'rust_analyzer', 'jedi_language_server', 'sumneko_lua', 'jsonls'}
local servers = { 'gopls', 'rust_analyzer', 'pyright', 'sumneko_lua', 'jsonls'}
local lsp_installer_servers = require'nvim-lsp-installer.servers'

for _, srv in ipairs(servers) do
	local ok, srv = lsp_installer_servers.get_server(srv)
	if ok then
		if not srv:is_installed() then
			srv:install()
		end
	end
end



-------------------------------------------------------------------------
-- completion and lsp
--_______________________________________________________________________
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)


local lsp_installer = require("nvim-lsp-installer")
lsp_installer.on_server_ready(function(server)
	local opts = {
		on_attach = on_attach,
		capabilities = capabilities,
	}

	if server.name == "gopls" then
		opts.cmd = {"gopls"} -- gopls installed in gobin path
	end
    if server.name == "pyright" then
        opts.settings = {
            python = {
                analysis = {
                  typeCheckingMode = "basic",
                  autoSearchPaths = true,
                  useLibraryCodeForTypes = true
                }
            }
        }
    end
    if server.name =="rust_analyzer" then
        require("rust-tools").setup {
            -- The "server" property provided in rust-tools setup function are the
            -- settings rust-tools will provide to lspconfig during init.            -- 
            -- We merge the necessary settings from nvim-lsp-installer (server:get_default_options())
            -- with the user's own settings (opts).
            server = vim.tbl_deep_extend("force", server:get_default_options(), opts),
        }
        server:attach_buffers()
        -- Only if standalone support is needed
        require("rust-tools").start_standalone_if_required()
        -- require('rust-tools').setup({ server = {
        --     on_attach = on_attach,
        --     cmd=server._default_options.cmd,
        --     capabilities = capabilities,
        -- } })
        return
    end

	server:setup(opts)
	vim.cmd [[ do User LspAttachBuffers ]]
end)

vim.lsp.handlers['textDocument/publishDiagnostics'] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
  virtual_text = true,
  signs = true,
  underline = true,
  update_in_insert = true,
})

local function goto_definition(split_cmd)
  local util = vim.lsp.util
  local log = require("vim.lsp.log")
  local api = vim.api

  local handler = function(_, result, ctx) -- new style handles
  -- local handler = function(_, method, result)
    if result == nil or vim.tbl_isempty(result) then
      local _ = log.info() and log.info(ctx.method, "No location found")
      return nil
    end
    local uri = result[1]['uri'] or result[1]['targetUri'] -- for rust-analyzer
    if uri ~= nil then
        -- get full path (remove file:// prefix)
        local name = string.sub(uri, 8)
        -- find window(split) with this buffer
        local winid = vim.fn.bufwinid(name);
        -- if exists jump to it
        if winid ~= nil then
            vim.fn.win_gotoid(winid)
        end
    end

    if vim.tbl_islist(result) then
      util.jump_to_location(result[1])
      if #result > 1 then
        util.set_qflist(util.locations_to_items(result))
        api.nvim_command("copen")
        vim.cmd("lua require'telescope.builtin'.quickfix{}")
        api.nvim_command("cclose")
        api.nvim_command("wincmd p")
      end
    else
		-- jump to location
		util.jump_to_location(result)
    end
  end

  return handler
end

vim.lsp.handlers["textDocument/definition"] = goto_definition('split')


vim.o.completeopt = 'menuone,noselect,noinsert'
local luasnip = require 'luasnip'
-- prevent jumping to last snippet placeholder if esc before snippet ends
luasnip.config.setup{
  region_check_events = "CursorMoved",
  delete_check_events = "TextChanged",
}
local cmp = require 'cmp'
cmp.setup {
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },
  mapping = {
    ['<A-k>'] = cmp.mapping.select_prev_item(),
    ['<A-j>'] = cmp.mapping.select_next_item(),
    ['<C-k>'] = cmp.mapping.select_prev_item(),
    ['<C-j>'] = cmp.mapping.select_next_item(),
    --['<A-S-k>'] = cmp.mapping.scroll_docs(-4),
    --['<A-S-j>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.close(),
	['<CR>'] = cmp.mapping.confirm {
	  behavior = cmp.ConfirmBehavior.Replace,
	  select = true,
	},
    ['<Tab>'] = function(fallback)
      if cmp.visible() then
        cmp.confirm()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end,
    ['<S-Tab>'] = function(fallback)
      if cmp.visible() then
		  cmp.confirm()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end,
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  },
}

-------------------------------------------------------------------------
-- bufferline
--_______________________________________________________________________
vim.opt.termguicolors = true
require("bufferline").setup{
	--diagnostics = "nvim_lsp",
}

map('n', '<A-l>', ":BufferLineCycleNext<CR>", opts)
map('n', '<A-h>', ":BufferLineCyclePrev<CR>", opts)
map('n', '<C-l>', ":BufferLineCycleNext<CR>", opts)
map('n', '<C-h>', ":BufferLineCyclePrev<CR>", opts)
map('n', '<A-w>', ":bdelete<CR>", opts)
map('n', '<leader>w', ":Bdelete<CR>", opts)


-------------------------------------------------------------------------
-- telescope
--_______________________________________________________________________
local themes = require('telescope.themes')
require('telescope').setup{
  defaults = {
    -- Default configuration for telescope goes here:
    -- config_key = value,
    mappings = {
      i = {
		  ["<A-j>"] = "move_selection_next",
		  ["<A-k>"] = "move_selection_previous",
		  ["<C-j>"] = "move_selection_next",
		  ["<C-k>"] = "move_selection_previous",
		  -- ["<TAB>"] = "move_selection_next",
		  -- ["<S-TAB>"] = "move_selection_previous",
      },
	  n = {
	  }
    }
  },
  pickers = {
    -- Default configuration for builtin pickers goes here:
    -- picker_name = {
    --   picker_config_key = value,
    --   ...
    -- }
    -- Now the picker_config_key will be applied every time you call this
    -- builtin picker
  },
  extensions = {
    -- Your extension configuration goes here:
    -- extension_name = {
    --   extension_config_key = value,
    -- }
    -- please take a look at the readme of the extension you want to configure
  }
}
map('n', 'gr', ":lua require'telescope.builtin'.lsp_references{layout_strategy='vertical', layout_config={preview_height=0.7}}<CR>",opts)
map('n', '<leader>qf', ":lua require'telescope.builtin'.lsp_code_actions(require'telescope.themes'.get_cursor())<CR>",opts)
map('n', 'gi', ":lua require'telescope.builtin'.lsp_implementations{}<CR>",opts)
map('n', '<A-S-f>', ":lua require'telescope.builtin'.live_grep{layout_strategy='vertical', layout_config={preview_height=0.5}}<CR>",opts)
map('n', '<A-S-o>', ":lua require'telescope.builtin'.find_files{}<CR>",opts)
map('n', '<leader>ff', ":lua require'telescope.builtin'.live_grep{layout_strategy='vertical', layout_config={preview_height=0.5}}<CR>",opts)
map('n', '<leader>fb', ":lua require'telescope.builtin'.buffers{layout_strategy='vertical', layout_config={preview_height=0.5}}<CR>",opts)
map('n', '<leader>fo', ":lua require'telescope.builtin'.find_files{}<CR>",opts)
map('n', '<leader>ql', ":lua require'telescope.builtin'.quickfix{layout_strategy='vertical', layout_config={preview_height=0.5}}<CR>",opts)
-- <C-d> - preview down
-- <C-u> - preview up


-------------------------------------------------------------------------
-- nvim tree
--_______________________________________________________________________
require'nvim-tree'.setup {
    disable_netrw = false, -- for GBrowse
	diagnostics = {
		enable = true,
		icons = {
		  hint = "",
		  info = "",
		  warning = "",
		  error = "",
		}
	},
	update_focused_file = {
		enable      = true,
	},
	view = {
		width = 40,
       mappings = {
           list = {
               {key="J", cb='3j', mode='n'},
               {key="K", cb='3k', mode='n'},
           }
       }
	}
}
map('n', "<C-n>", "<cmd>NvimTreeToggle<CR>", opts)

-------------------------------------------------------------------------
-- treesitter
--_______________________________________________________________________

local ts = require('nvim-treesitter.configs')
ts.setup {
	ensure_installed = {"python", "go"},
	highlight = {
		enable = true,
	}
}

-------------------------------------------------------------------------
-- vgit
--_______________________________________________________________________
--require('vgit').setup()


-------------------------------------------------------------------------
-- nvim_comment
--_______________________________________________________________________
-- require('nvim_comment').setup({line_mapping = "<leader>cc", operator_mapping = "<leader>c"})
require("Comment").setup {
    toggler = {
        ---Line-comment toggle keymap
        line = '<leader>cc',
        ---Block-comment toggle keymap
        block = '<leader>bc',
    },

    ---LHS of operator-pending mappings in NORMAL + VISUAL mode
    ---@type table
    opleader = {
        ---Line-comment keymap
        line = '<leader>c',
        ---Block-comment keymap
        block = '<leader>b',
    },
}

-------------------------------------------------------------------------
-- rust_tools
--_______________________________________________________________________
-- not working with LspInstaller. Watch lsp installer section where is activated



-------------------------------------------------------------------------
-- auto-session
--_______________________________________________________________________
vim.o.sessionoptions="blank,buffers,curdir,folds,help,options,tabpages,winsize,resize,winpos,terminal"
require('auto-session').setup {
    log_level = 'info',
}

-------------------------------------------------------------------------
-- lint
--_______________________________________________________________________
require('lint').linters_by_ft = {
  go = {'golangcilint',},
  python = {'flake8'}
}

-------------------------------------------------------------------------
-- galaxyline
--_______________________________________________________________________
require("galaxy_line")

-------------------------------------------------------------------------
-- nightfox
--_______________________________________________________________________
local nightfox = require('nightfox')

-- This function set the configuration of nightfox. If a value is not passed in the setup function
-- it will be taken from the default configuration above
nightfox.setup({
  fox = "nightfox", -- change the colorscheme to use nordfox
  styles = {
    comments = "italic", -- change style of comments to be italic
    keywords = "bold", -- change style of keywords to be bold
    functions = "italic,bold" -- styles can be a comma separated list
  },
  inverse = {
    -- match_paren = true, -- inverse the highlighting of match_parens
    visual = true,
    search = true,
  },
  colors = {
    red = "#FF000", -- Override the red color for MAX POWER
    bg_alt = "#000000",
  },
  hlgroups = {
    TSPunctDelimiter = { fg = "${red}" }, -- Override a highlight group with the color red
    LspCodeLens = { bg = "#000000", style = "italic" },
  }
})

-- Load the configuration set above and apply the colorscheme
nightfox.load()

-------------------------------------------------------------------------
-- lualine
--_______________________________________________________________________
-- require('lualine').setup({
--     options = {
--         theme = "nightfox",
--     },
--     sections = {
--         lualine_c = {{'filename', path=1}},
-- 	}
-- })
