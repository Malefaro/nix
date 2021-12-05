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

local servers = { 'gopls', 'rust_analyzer', 'jedi_language_server', 'sumneko_lua', 'jsonls'}
local lsp_installer_servers = require'nvim-lsp-installer.servers'

for _, srv in ipairs(servers) do
	local ok, srv = lsp_installer_servers.get_server(srv)
	if ok then
		if not srv:is_installed() then
			srv:install()
		end
	end
end



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
    if server.name =="rust_analyzer" then

        require('rust-tools').setup({ server = {
            on_attach = on_attach,
            cmd=server._default_options.cmd,
            capabilities = capabilities,
        } })
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
    --['<A-S-k>'] = cmp.mapping.scroll_docs(-4),
    --['<A-S-j>'] = cmp.mapping.scroll_docs(4),
    ['<A-Space>'] = cmp.mapping.complete(),
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
map('n', '<A-w>', ":bdelete<CR>", opts)


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
require('nvim_comment').setup({line_mapping = "<leader>cc", operator_mapping = "<leader>c"})

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
local gl = require("galaxyline")
local gls = gl.section

local fileinfo = require("galaxyline.provider_fileinfo")
local lspclient = require("galaxyline.provider_lsp")
local vcs = require("galaxyline.provider_vcs")

local colours = {
	bg = "#222222",
    -- bg = "#eeeeee",
	black = "#000000",
	white = "#ffffff",
	accent_light = "#c2d5ff",
	accent = "#5f87d7",
	accent_dark = "#00236e",
	alternate = "#8fbcbb",
	alternate_dark = "#005f5f",
	yellow = "#fabd2f",
	cyan = "#008080",
	darkblue = "#081633",
	green = "#afd700",
	orange = "#FF8800",
	purple = "#5d4d7a",
	magenta = "#d16d9e",
	grey = "#555555",
	blue = "#0087d7",
	red = "#ec5f67",
	pink = "#e6a1e2",
}

local function highlight(name, fg, bg, style)
	local cmd = "hi " .. name .. " guibg=" .. bg .. " guifg=" .. fg
	if style then
		cmd = cmd .. " gui=" .. style
	end
	vim.api.nvim_command(cmd)
end

local function hi_link(name1, name2)
	vim.api.nvim_command("hi link " .. name1 .. " " .. name2)
end

local function mix_colours(color_1, color_2, weight)
	local d2h = function(d) -- convert a decimal value to hex
		return string.format("%x", d)
	end
	local h2d = function(h) -- convert a hex value to decimal
		return tonumber(h, 16)
	end

	color_1 = string.sub(color_1, 1, -1)
	color_2 = string.sub(color_2, 1, -1)

	weight = weight or 50 -- set the weight to 50%, if that argument is omitted

	local color = "#";

	for i = 2, 6, 2 do -- loop through each of the 3 hex pairsred, green, and blue
		local v1 = h2d(string.sub(color_1, i, i+1)) -- extract the current pairs
		local v2 = h2d(string.sub(color_2, i, i+1))

		-- combine the current pairs from each source color, according to the specified weight
		local val = d2h(math.floor(v2 + (v1 - v2) * (weight / 100.0)))

		while(string.len(val) < 2) do val = '0' .. val end -- prepend a '0' if val results in a single digit

		color = color .. val -- concatenate val to our new color string
	end

	return color; -- PROFIT!
end

local function generate_mode_colours()
	-- n   Normal
	-- no  Operator-pending
	-- v   Visual by character
	-- V   Visual by line
	-- CTRL-V  Visual blockwise
	-- s   Select by character
	-- S   Select by line
	-- CTRL-S  Select blockwise
	-- i   Insert
	-- ic  Insert mode completion |compl-generic|
	-- ix  Insert mode |i_CTRL-X| completion
	-- R   Replace |R|
	-- Rc  Replace mode completion |compl-generic|
	-- Rv  Virtual Replace |gR|
	-- Rx  Replace mode |i_CTRL-X| completion
	-- c   Command-line editing
	-- cv  Vim Ex mode |gQ|
	-- ce  Normal Ex mode |Q|
	-- r   Hit-enter prompt
	-- rm  The -- more -- prompt
	-- r?  A |:confirm| query of some sort
	-- !   Shell or external command is executing
	-- t   Terminal mode: keys go to the job

	local mode_colours = { -- fg, bg
		-- n      = {colours.black, colours.accent         },
		n      = {colours.accent_light, colours.accent         },
		no     = {colours.accent_light, colours.accent         },
		v      = {colours.black,        colours.yellow         },
		V      = {colours.black,        colours.yellow         },
		[""] = {colours.black,        colours.yellow         },
		s      = {colours.black,        colours.orange         },
		S      = {colours.black,        colours.orange         },
		[""] = {colours.black,        colours.orange         },
		i      = {colours.alternate,    colours.alternate_dark },
		ic     = {colours.alternate,    colours.alternate_dark },
		ix     = {colours.alternate,    colours.alternate_dark },
		R      = {colours.black,        colours.green          },
		Rc     = {colours.black,        colours.green          },
		Rv     = {colours.black,        colours.green          },
		Rx     = {colours.black,        colours.green          },
		c      = {colours.white,        colours.red            },
		cv     = {colours.white,        colours.red            },
		ce     = {colours.white,        colours.red            },
		r      = {colours.black,        colours.cyan           },
		rm     = {colours.black,        colours.cyan           },
		["r?"] = {colours.black,        colours.cyan           },
		["!"]  = {colours.black,        colours.white          },
		t      = {colours.black,        colours.white          },
	}

	local full_table = {}
	for mode, values in pairs(mode_colours) do
		local main_bg = values[2]
		local base_fg = values[1]
		local dim_bg
		local dimmer_bg = mix_colours(main_bg, colours.bg, 20)
		local main_fg
		local dim_fg
		if base_fg == colours.white or base_fg == colours.black then
			if base_fg == colours.black then
				dim_bg = mix_colours(main_bg, colours.bg, 40)
				main_fg = mix_colours(main_bg, colours.black, 50)
				dim_fg = main_bg
			else
				dim_bg = mix_colours(main_bg, colours.bg, 50)
				main_fg = mix_colours(main_bg, colours.white, 30)
				dim_fg = mix_colours(main_bg, colours.white, 50)
			end
		else
			main_fg = base_fg
			dim_bg = mix_colours(main_bg, colours.bg, 50)
			dim_fg = mix_colours(main_fg, dim_bg, 80)
		end
		full_table[mode] = {
			main_fg = main_fg,
			main_bg = main_bg,
			dim_fg = dim_fg,
			dim_bg = dim_bg,
			dimmer_bg = dimmer_bg,
		}
	end
	return full_table
end

local mode_colours = generate_mode_colours()

highlight("GalaxySearchResult", mix_colours(colours.yellow, colours.black, 50), colours.yellow)
highlight("GalaxyTrailing", mix_colours(colours.red, colours.white, 30), colours.red)
hi_link("GalaxyInnerSeparator1", "GalaxySection1")
hi_link("GalaxyInnerSeparator2", "GalaxySection2")

local function search(pattern)
  local line = vim.fn.search(pattern, "nw")
  if line == 0 then
    return ""
  end
  return string.format("%d", line)
end

local function check_trailing()
  return search([[\s$]])
end

local function search_results_available()
	local search_count = vim.fn.searchcount({
		recompute = 1,
		maxcount = -1,
	})
	return vim.v.hlsearch == 1 and search_count.total > 0
end

gls.left[1] = {
	ViMode = {
		provider = function()
			local alias = {
				n = "NORMAL",
				no = "N OPERATOR",
				v = "VISUAL",
				V = "V LINE",
				[""] = "V BLOCK",
				s = "SELECT",
				S = "S LINE",
				[""] = "S BLOCK",
				i = "INSERT",
				ic = "I COMPLETION",
				ix = "I X COMP",
				R = "REPLACE",
				Rc = "R COMPLETION",
				Rv = "R VIRTUAL",
				Rx = "R X COMP",
				c = "COMMAND",
				cv = "EX",
				r = "PROMPT",
				rm = "MORE",
				["r?"] = "CONFIRM",
				["!"] = "EXT COMMAND",
				t = "TERMINAL",
			}
			local mode = vim.fn.mode()
			local c = mode_colours[mode]

			local search_results = search_results_available()
			if search_results then
				highlight("GalaxySearchResultEdge", colours.yellow, c.main_bg)
				highlight("GalaxyTrailingEdge", colours.red, colours.yellow)
			else
				highlight("GalaxyTrailingEdge", colours.red, c.main_bg)
			end

			highlight("GalaxylineFillSection", c.dimmer_bg, c.dimmer_bg)
			-- highlight("StatusLine", c.dimmer_bg, c.dimmer_bg)
			highlight("GalaxyMidText", c.dim_fg, c.dimmer_bg)

			highlight("GalaxySection1", c.main_fg, c.main_bg)
			highlight("GalaxySection1Edge", c.main_bg, c.dim_bg)
			highlight("GalaxySection2", c.dim_fg, c.dim_bg)
			highlight("GalaxySection2Bright", colours.white, c.dim_bg)
			highlight("GalaxySection2Edge", c.dim_bg, c.dimmer_bg)

			highlight("GalaxyViMode", c.main_fg, c.main_bg, "bold")
			highlight("GalaxyFileIcon", fileinfo.get_file_icon_color(), c.dimmer_bg)
			highlight("GalaxyEditIcon", colours.red, c.dimmer_bg)

			return '  ' .. alias[vim.fn.mode()] .. ' '
		end,
		separator = "",
		separator_highlight = "GalaxySection1Edge",
		highlight = "GalaxySection1",
		-- highlight = { colours.accent_dark, colours.accent, "bold" },
	},
}

-- gls.left[2] = { -- lsp server
-- 	LspServer = {
-- 		provider = function()
-- 			local curr_client = lspclient.get_lsp_client()
-- 			if curr_client ~= "No Active Lsp" then
-- 				return ' ' .. curr_client .. ' '
-- 			end
-- 		end,
-- 		highlight = "GalaxySection2",
-- 	},
-- }

gls.left[2] = { -- git branch
	GitBranch = {
		provider = function()
			local curr_branch = vcs.get_git_branch()
			if curr_branch ~= nil then
				return ' ' .. curr_branch .. ' '
			end
		end,
		highlight = "GalaxySection2",
	},
}
gls.left[3] = {
	LspFunctionIcon = {
		provider = function()
			local current_function = vim.b.lsp_current_function
			if current_function and current_function ~= '' then
				return ' '
			end
		end,
		highlight = "GalaxySection2Bright",
	},
}

gls.left[4] = {
	LspFunction = {
		provider = function()
			local current_function = vim.b.lsp_current_function
			if current_function and current_function ~= '' then
				return ' ' .. current_function .. ' '
			end
		end,
		separator = "",
		separator_highlight = "GalaxySection2Edge",
		highlight = "GalaxySection2",
	},
}

gls.mid[1] = { -- file icon
	FileIcon = {
		provider = function()
			return ' ' .. fileinfo.get_file_icon()
		end,
		highlight = "GalaxyFileIcon",
	},
}

gls.mid[2] = { -- filename
	CurrentFile = {
		provider = function()
			-- local path = vim.fn.expand('%:p')
			local path = vim.fn.expand('%:r')
			-- local path = fileinfo.get_current_file_name()
			if not path or path == '' then
				path = "[No Name]"
			end
			return path
		end,
		highlight = "GalaxyMidText",
	},
}

gls.mid[3] = { -- ~ separator
	Tilde = {
		provider = function()
			local file_size = fileinfo.get_file_size()
			if file_size and file_size ~= '' then
				return '  ~ '
			else -- don't show ~ because there is no size following
				return ' ' -- for spacing edit icon
			end
		end,
		highlight = "GalaxyEditIcon",
	},
}

gls.mid[4] = { -- file size
	FileSize = {
		provider = fileinfo.get_file_size,
		highlight = "GalaxyMidText",
	},
}

gls.mid[5] = { -- modified/special icons
	Modified = {
		provider = function()
			if vim.bo.readonly then
				return ' '
			end
			if not vim.bo.modifiable then
				return ' '
			end
			if vim.bo.modified then
				return ' '
			end
		end,
		highlight = "GalaxyEditIcon",
	},
}

-- gls.mid[6] = {
-- 
--     DiagnosticWarn = {
--       provider = function()
--         local n = vim.lsp.diagnostic.get_count(0, 'Warning')
--         if n == 0 then return '' end
--         -- return string.format(' %s %d ', u 'f071', n)
--         return string.format(' %s %d ', 'f071', n)
--       end,
-- 	  highlight = "GalaxyMidText",
--       -- highlight = {'yellow', cl.bg},
--     },
--     DiagnosticError = {
--       provider = function()
--         local n = vim.lsp.diagnostic.get_count(0, 'Error')
--         if n == 0 then return '' end
--         -- return string.format(' %s %d ', u 'e009', n)
--         return string.format(' %s %d ', 'e009', n)
--       end,
--       highlight = "GalaxyMidText",
--       -- highlight = {'red', cl.bg},
--     },
-- }

-- gls.right[9] = { -- trailing indicator
-- 	Whitespace = {
-- 		provider = function()
-- 			local trailing = check_trailing()
-- 			if trailing ~= '' then
-- 				return "  tr " .. trailing .. ' '
-- 			end
-- 		end,
-- 		highlight = "GalaxyTrailing",
-- 	},
-- }
-- 
-- gls.right[8] = { -- trailing edge
-- 	WhitespaceEdge = {
-- 		provider = function()
-- 			local trailing = check_trailing()
-- 			if trailing ~= '' then
-- 				return ''
-- 			end
-- 		end,
-- 		highlight = "GalaxyTrailingEdge",
-- 	},
-- }

gls.right[7] = { -- search indicator
	Search = {
		provider = function()
			local search_count = vim.fn.searchcount({
				recompute = 1,
				maxcount = -1,
			})
			local active_result = vim.v.hlsearch == 1 and search_count.total > 0
			if active_result then
				return '   ' .. search_count.current .. '/' .. search_count.total .. ' '
			end
		end,
		highlight = "GalaxySearchResult",
	},
}

gls.right[6] = { -- search edge
	SearchEdge = {
		provider = function()
			if search_results_available() then
				return ''
			end
		end,
		highlight = "GalaxySearchResultEdge",
	},
}

gls.right[5] = { -- file percent
	Percent = {
		provider = function()
			return fileinfo.current_line_percent()
		end,
		highlight = "GalaxySection1",
		separator = "",
		separator_highlight = "GalaxyInnerSeparator1",
	},
}

gls.right[4] = { -- line & column
	LineColumn = {
		provider = function()
			local mode = vim.fn.mode()
			if mode == 'v' or mode == 'V' or mode == "" then -- visual mode (show selection)
				local lstart = vim.fn.line("v")
				local lend = vim.fn.line(".")
				local cstart = vim.fn.col("v")
				local cend = vim.fn.col(".")
				return '  ' .. lstart .. ':' .. lend .. '/' .. vim.fn.line('$') .. '  ' .. cstart .. ':' .. cend .. '/' .. vim.fn.col('$') .. ' '
			else
				return '  ' .. vim.fn.line(".") .. '/' .. vim.fn.line('$') .. '  ' .. vim.fn.col(".") .. '/' .. vim.fn.col('$') .. ' '
			end
		end,
		highlight = "GalaxySection1",
		separator = "",
		separator_highlight = "GalaxySection1Edge",
	},
}

gls.right[3] = { -- encoding (eg. utf-8)
	Encode = {
		provider = function()
			local encoding = vim.bo.fenc
			if encoding and encoding ~= '' then
				return ' ' .. encoding .. ' '
			end
		end,
		highlight = "GalaxySection2",
	},
}

gls.right[2] = { -- format (eg. unix)
	Format = {
		provider = function()
			local fformat = vim.bo.fileformat
			local icon
			if fformat == "unix" then
				icon = ''
			elseif fformat == "dos" then
				icon = ''
			elseif fformat == "mac" then
				icon = ''
			end
			return ' ' .. icon .. ' '
		end,
		highlight = "GalaxySection2Bright",
	},
}

gls.right[1] = { -- filetype (eg. python)
	FileType = {
		provider = function()
			local filetype = vim.bo.filetype
			if filetype and filetype ~= '' then
				return ' ' .. filetype .. ' '
			end
		end,
		highlight = "GalaxySection2",
		separator = "",
		separator_highlight = "GalaxySection2Edge",
	},
}


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
