-- "rcarriga/nvim-notify",
-- "stevearc/dressing.nvim",
-- "lukas-reineke/indent-blankline.nvim",
-- "folke/noice.nvim",
-- "goolord/alpha-nvim",
-- 'tpope/vim-sleuth'
-- bufferline ==> romgrk/barbar.nvim
return {
    {
        "nvim-lualine/lualine.nvim",
        event = "VimEnter",
        dependencies = {
            "nvim-web-devicons",
        },
        config = function()
            require("lualine").setup({
                options = {
                    theme = "moonfly",
                    component_separators = "|",
                    section_separators = "",
                },
                sections = {
                    lualine_a = { "mode" },
                    lualine_b = { "branch", "diff", "diagnostics" },
                    lualine_c = { "filename", "lsp_progress" },
                    lualine_x = { "encoding", "fileformat", "filetype" },
                    lualine_y = { "progress" },
                    lualine_z = { "location" },
                },
            })
        end,
    },

    {
        "romgrk/barbar.nvim",
        event = "BufWinEnter",
        dependencies = "nvim-web-devicons"
    },
    {
        "nvim-neo-tree/neo-tree.nvim",
        cmd = "Neotree",
        version = "v2.x",
        config = true,
        dependencies = {
            "plenary.nvim",
            "nvim-web-devicons", -- not strictly required, but recommended
            "nui.nvim",
        }
    },
    {
        "akinsho/toggleterm.nvim",
        branch = "main",
        config = true,
    },
    -- icons
    { "nvim-tree/nvim-web-devicons", lazy = true },

    -- ui components
    { "MunifTanjim/nui.nvim", lazy = true }
}
