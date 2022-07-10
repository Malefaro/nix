local dap = require('dap')

dap.adapters.go = function(callback, config)
    local stdout = vim.loop.new_pipe(false)
    local handle
    local pid_or_err
    local port = 38697
    local opts = {
        stdio = { nil, stdout },
        args = { "dap", "-l", "127.0.0.1:" .. port },
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
            callback({ type = "server", host = "127.0.0.1", port = port })
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

local widgets = require('dap.ui.widgets')
local scopes_sidebar = widgets.sidebar(widgets.scopes, {}, "40 vsplit")
local frames_sidebar = widgets.sidebar(widgets.frames, {}, "rightbelow 30 vsplit")

vim.fn.sign_define('DapBreakpoint', { text = '🔴', texthl = '', linehl = '', numhl = '' })
local repl = dap.repl
function SetupDebug()
    scopes_sidebar.toggle()
    frames_sidebar.toggle()
    repl.toggle({ height = 10 })
end

local opts = { noremap = true, silent = true }
local map = vim.api.nvim_set_keymap

map('n', '<leader>dc', ':lua require"dap".continue()<CR>', opts)
map('n', ']d', ':lua require"dap".step_over()<CR>', opts)
map('n', '[d', ':lua require"dap".step_out()<CR>', opts)
map('n', ']i', ':lua require"dap".step_into()<CR>', opts)
map('n', '<leader>db', ':lua require"dap".toggle_breakpoint()<CR>', opts)
map('n', '<leader>de', ':lua require"dap".disconnect()<CR>:lua require"dap".close()<CR>', opts)
map('n', '<leader>dl', ':lua require"dap".list_breakpoints()<CR>:lua require"telescope.builtin".quickfix{}<CR>', opts)
map('n', '<leader>ds', ':lua SetupDebug()<CR>', opts)

require('dap-go').setup()
