-- All plugins have lazy=true by default,to load a plugin on startup just lazy=false
-- List of all default plugins & their definitions
local plugins = {

{ 
  "nvim-lua/plenary.nvim",
  cmd = { "PlenaryBustedFile", "PlenaryBustedDirectory" },
},

  -- tokyonight
  -- {
  --   "folke/tokyonight.nvim",
  --   priority = 1000,
  --   opts = { style = "night" },
  --   config = function()
  --       -- vim.cmd("colorscheme tokyonight-night")
  --   end
  -- },

  -- catppuccin
  {
    "catppuccin/nvim", 
    name = "catppuccin", 
    priority = 1000,
    config = function()
      vim.cmd.colorscheme "catppuccin-frappe"
    end
  },
  -- { 
  --   "EdenEast/nightfox.nvim",
  --   config = function()
  --   --    vim.cmd('colorscheme carbonfox')
  --   end
  -- },
  -- {
  --   'rose-pine/neovim',
  --   name = 'rose-pine',
  --   priority = 1000,
  --   config = function()
  --       require("rose-pine").setup()
  --       -- vim.cmd('colorscheme rose-pine')
  --   end
  -- },

{
  "NvChad/nvim-colorizer.lua",
  init = function()
    require("core.utils").lazy_load "nvim-colorizer.lua"
  end,
  cmd = { "ColorizerToggle", "ColorizerAttachToBuffer", "ColorizerDetachFromBuffer", "ColorizerReloadAllBuffers" },
  config = function(_, opts)
    require("colorizer").setup(opts)

    -- execute colorizer as soon as possible
    vim.defer_fn(function()
      require("colorizer").attach_to_buffer(0)
    end, 0)
  end,
},

{
  "nvim-tree/nvim-web-devicons",
  config = function(_, opts)
    require("nvim-web-devicons").setup(opts)
  end,
},

-- indent-blankline

{
  "lukas-reineke/indent-blankline.nvim",
  init = function()
    require("core.utils").lazy_load "indent-blankline.nvim"
  end,
  opts = function()
    return require "plugins.configs.indent-blankline"
  end,
  config = function(_, opts)
    require("core.utils").load_mappings "blankline"
    require("indent_blankline").setup(opts)
  end,
},

-- Treesitter
{
  "nvim-treesitter/nvim-treesitter",
  init = function()
    require("core.utils").lazy_load "nvim-treesitter"
  end,
  cmd = { "TSInstall", "TSBufEnable", "TSBufDisable", "TSModuleInfo" },
  build = ":TSUpdate",
  opts = function()
    return require "plugins.configs.treesitter"
  end,
  config = function(_, opts)
    require("nvim-treesitter.configs").setup(opts)
  end,
},

-- git stuff
{
    "lewis6991/gitsigns.nvim",
    ft = { "gitcommit", "diff" },
    init = function()
      -- load gitsigns only when a git file is opened
      vim.api.nvim_create_autocmd({ "BufRead" }, {
        group = vim.api.nvim_create_augroup("GitSignsLazyLoad", { clear = true }),
        callback = function()
          vim.fn.system("git -C " .. '"' .. vim.fn.expand "%:p:h" .. '"' .. " rev-parse")
          if vim.v.shell_error == 0 then
            vim.api.nvim_del_augroup_by_name "GitSignsLazyLoad"
            vim.schedule(function()
              require("lazy").load { plugins = { "gitsigns.nvim" } }
            end)
          end
        end,
      })
    end,
    opts = function()
      return require "plugins.configs.gitsigns"
    end,
    config = function(_, opts)
      require("gitsigns").setup(opts)
    end,
},

-- cmp stuff
{
  "hrsh7th/nvim-cmp",
  event = "InsertEnter",
  dependencies = {
    {
      -- snippet plugin
      "L3MON4D3/LuaSnip",
      dependencies = "rafamadriz/friendly-snippets",
      opts = { history = true, updateevents = "TextChanged,TextChangedI" },
      config = function(_, opts)
        require("plugins.configs.luasnip").luasnip(opts)
      end,
    },

    -- autopairing of (){}[] etc
    {
      "windwp/nvim-autopairs",
      opts = {
        fast_wrap = {},
        disable_filetype = { "TelescopePrompt", "vim" },
      },
      config = function(_, opts)
        require("nvim-autopairs").setup(opts)

        -- setup cmp for autopairs
        local cmp_autopairs = require "nvim-autopairs.completion.cmp"
        require("cmp").event:on("confirm_done", cmp_autopairs.on_confirm_done())
      end,
    },
    -- Tabnine?
    -- Copilot?
    -- cmp sources plugins
    {
      "onsails/lspkind.nvim",
      "saadparwaiz1/cmp_luasnip",
      "ray-x/cmp-treesitter",
      "hrsh7th/cmp-nvim-lua",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
    },
  },
  opts = function()
    return require "plugins.configs.cmp"
  end,
  config = function(_, opts)
    require("cmp").setup(opts)
  end,
},

-- lsp stuff
-- Useful status updates for LSP
{
  "j-hui/fidget.nvim",
  tag = "legacy",
  config = true,
},
-- Additional lua configuration, makes nvim stuff amazing
{
  "folke/neodev.nvim",
  opts = {
      experimental = { pathStrict = true },
  },
  config = true,
},
{
  "williamboman/mason.nvim",
  cmd = { "Mason", "MasonUpdate", "MasonInstall", "MasonUninstall", "MasonInstallAll", "MasonUninstallAll", "MasonLog" },
  opts = function()
    return require "plugins.configs.mason"
  end,
  config = function(_, opts)
    require("mason").setup(opts)
    -- custom nvchad cmd to install all mason binaries listed
    vim.api.nvim_create_user_command("MasonInstallAll", function()
      vim.cmd("MasonInstall " .. table.concat(opts.ensure_installed, " "))
    end, {})

    vim.g.mason_binaries_list = opts.ensure_installed
  end,
},

-- mason-lspconfig
{ 
  "williamboman/mason-lspconfig.nvim",
  event = 'BufEnter', 
  -- cmd = { "LspInstall", "LspUninstall" },
  opts = function()
    return require "plugins.configs.mason-lspconfig"
  end,
  config = function(_, opts)
    require("mason-lspconfig").setup(opts)
  end
},

{
  "neovim/nvim-lspconfig",
  init = function()
    require("core.utils").lazy_load "nvim-lspconfig"
  end,
  config = function()
    require "plugins.configs.lspconfig"
  end,
},

-- ----------------------------------------------------------------------- }}}
-- {
--   "glepnir/lspsaga.nvim",
--   event = "BufRead",
--   lazy = true,
--   config = function()
--       require("lspsaga").setup({})
--   end,
--   dependencies = { { "nvim-web-devicons" } },
-- },
-- {
--   "folke/trouble.nvim",
--   lazy = true,
--   requires = "nvim-web-devicons",
--   config = true,
-- },

-- cmp

-- Comments
{
  "numToStr/Comment.nvim",
  keys = {
    { "gcc", mode = "n", desc = "Comment toggle current line" },
    { "gc", mode = { "n", "v" }, desc = "Comment toggle linewise" },
    { "gc", mode = "x", desc = "Comment toggle linewise (visual)" },
    { "gbc", mode = "n", desc = "Comment toggle current block" },
    { "gb", mode = { "n", "v" }, desc = "Comment toggle blockwise" },
    { "gb", mode = "x", desc = "Comment toggle blockwise (visual)" },
  },
  config = function(_, opts)
    require("Comment").setup(opts)
  end,
},

-- File Explorer
{ 
  'nvim-tree/nvim-tree.lua',
  version = 'nightly',
  cmd = { "NvimTreeToggle", "NvimTreeFocus" },
  init = function()
    require("core.utils").load_mappings "nvimtree"
  end,
  opts = function()
    return {
      filters = {
        dotfiles = false,
        exclude = { vim.fn.stdpath "config" .. "/lua/custom" },
      },
      diagnostics = {
        enable = true,
      },
    }
  end,
  config = function(_, opts)
      local nvimtree = require 'nvim-tree'
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1
      vim.opt.termguicolors = true

      nvimtree.setup(opts)
  end
},

-- Tabline
{
  'akinsho/bufferline.nvim',
  event = "User FileOpen",
  init = function()
    require("core.utils").lazy_load "bufferline.nvim"
    require("core.utils").load_mappings "bufferline"
  end,
  opts = function()
    return {
      options = {
        diagnostics = "nvim_lsp",
        offsets = {
          {
              filetype = "NvimTree",
              text = "File Explorer",
              highlight = "Directory",
              text_align = "center",
          }
        },
      },
    }
  end,
  config = function(_, opts)
    require("bufferline").setup(opts)
  end,
},
-- Statusline
{
  'nvim-lualine/lualine.nvim',
  event = 'VimEnter',
  opts = function()
    return {
      options = {
        disabled_filetypes = { 
          statusline = { 
            "dashboard", 
            "alpha" 
          } 
        },
        theme = 'moonfly',
        -- theme = 'catppuccin',
        component_separators = '|',

        section_separators = '',
      },
      sections = {
          lualine_a = { 'mode' },
          lualine_b = { 'branch', 'diff', 'diagnostics' },
          lualine_c = { 'filename', 'lsp_progress' },
          lualine_x = { 'encoding', 'fileformat', 'filetype' },
          lualine_y = { 'progress' },
          lualine_z = { 'location' },
      },
    }
  end,
  config = function(_, opts)
    require("lualine").setup(opts)
  end,
},

-- Telescope
{
  "nvim-telescope/telescope.nvim",
  dependencies = { 
    "nvim-treesitter/nvim-treesitter",
    { "nvim-telescope/telescope-fzf-native.nvim", enabled = vim.fn.executable "make" == 1, build = "make" },
  },
  cmd = "Telescope",
  init = function()
    require("core.utils").load_mappings "telescope"
  end,
  opts = function()
    return require "plugins.configs.telescope"
  end,
  config = function(_, opts)
    local telescope = require "telescope"
    telescope.setup(opts)
    telescope.load_extension('fzf')
  end,
},

-- others
{
  "wakatime/vim-wakatime",
},
{
  "ThePrimeagen/vim-be-good",
  event = "VeryLazy",
},
{
  "ThePrimeagen/harpoon",
  event = "BufEnter",
  lazy = true,
},


-- TMUX
{
  "aserowy/tmux.nvim",
  config = function() 
    return require("tmux").setup() 
  end
},


-- Only load whichkey after all the gui
{
  "folke/which-key.nvim",
  keys = { "<leader>", '"', "'", "`", "c", "v", "g" },
  init = function()
    require("core.utils").load_mappings "whichkey"
  end,
  config = function(_, opts)
    require("which-key").setup(opts)
  end,
},
}

-- install plugins
local configs = require("core.bootstrap").lazy_config
require("lazy").setup(plugins, configs)