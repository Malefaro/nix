require('neotest').setup({
    floating = {
        border = "rounded",
        max_height = 0.85,
        max_width = 0.85,
        options = {}
    },
    adapters = {
        require('neotest-python')({
            dap = { justMyCode = false },
            args = { "--dc=Local", "--ds=gateway.settings_local", "--color=yes", "--reuse-db" }
        }),
        require('neotest-go')({
        }),
        require('neotest-plenary'),
    },
})

local map = vim.api.nvim_set_keymap
map('n', '<leader>tn', '<cmd>lua require("neotest").run.run()<cr>', {})
map('n', '<leader>td', '<cmd>lua require("neotest").run.run({strategy="dap"})<cr>', {})
map('n', '<leader>ts', '<cmd>lua require("neotest").summary.open()<cr>', {})
map('n', '<leader>to', '<cmd>lua require("neotest").output.open({enter=true})<cr>', {})
map('n', '<leader>ta', '<cmd>lua require("neotest").run.attach()<cr>', {})
map('n', '<leader>tf', '<cmd>lua require("neotest").run.run(vim.fn.expand("%"))<cr>', {})
map('n', '<leader>te', '<cmd>lua require("neotest").run.stop()<cr>', {})
