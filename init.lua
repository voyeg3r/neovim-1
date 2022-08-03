local cmd = vim.cmd
local g = vim.g
local opt = vim.opt
local hl = vim.api.nvim_set_hl


--
-- Options
--
opt.backup = false
opt.completeopt = { 'menuone', 'noselect' }
opt.fileencoding = 'utf-8'
opt.swapfile = false
opt.undofile = true

-- Visual
opt.cursorline = true
opt.fillchars = { eob = ' ', vert = ' ' }
opt.hlsearch = false
opt.number = true
opt.relativenumber = true
opt.ruler = false
opt.scrolloff = 2
opt.shortmess:append('I')
opt.showmode = false
opt.sidescrolloff = 2
opt.splitbelow = true
opt.splitright = true
opt.termguicolors = true
opt.wrap = false

-- Formatting
opt.expandtab = true
opt.shiftwidth = 2
opt.smartindent = true
opt.timeoutlen = 500


--
-- Keymaps
--
local map = vim.keymap.set

g.mapleader = ' '
g.maplocalleader = ' '

-- Vim built-in modifcations
map('n', '<c-h>', '<c-w>h')
map('n', '<c-j>', '<c-w>j')
map('n', '<c-k>', '<c-w>k')
map('n', '<c-l>', '<c-w>l')

-- Search
pcall(function()
  require('telescope')
  map('n', '<leader>ff', function() require('telescope.builtin').find_files({ previewer = false }) end)
  map('n', '<leader>fb', function() require('telescope.builtin').current_buffer_fuzzy_find() end)
  map('n', '<leader>fh', function() require('telescope.builtin').help_tags() end)
  map('n', '<leader>ft', function() require('telescope.builtin').tags() end)
  map('n', '<leader>fg', function() require('telescope.builtin').live_grep() end)
end)

-- Git
pcall(function()
  require('gitsigns')
  map('n', '<leader>gb', function() require('gitsigns').blame_line() end)
end)

-- Explore
pcall(function()
  require('neo-tree')
  map('n', '<leader>ef', '<cmd>Neotree focus<cr>')
  map('n', '<leader>et', '<cmd>Neotree toggle<cr>')
end)


--
-- Plugins
--
require('packer').init({
  display = {
    open_fn = function() return require('packer.util').float({ border = 'single' }) end,
    prompt_border = 'single'
  }
})
require('packer').startup({
  function(use)
    use {
      'VonHeikemen/lsp-zero.nvim',
      requires = {
        -- LSP Support
        { 'neovim/nvim-lspconfig' },
        { 'williamboman/mason.nvim' },
        { 'williamboman/mason-lspconfig.nvim' },

        -- Autocompletion
        { 'hrsh7th/nvim-cmp' },
        { 'hrsh7th/cmp-buffer' },
        { 'hrsh7th/cmp-path' },
        { 'saadparwaiz1/cmp_luasnip' },
        { 'hrsh7th/cmp-nvim-lsp' },
        { 'hrsh7th/cmp-nvim-lua' },

        -- Snippets
        { 'L3MON4D3/LuaSnip' },
        { 'rafamadriz/friendly-snippets' },
      }
    }
    use({ 'wbthomason/packer.nvim' })
    use({ 'chriskempson/base16-vim' })
    use({ 'nvim-telescope/telescope.nvim', requires = 'nvim-lua/plenary.nvim' })
    use({ 'nvim-telescope/telescope-fzf-native.nvim', requires = 'nvim-telescope/telescope.nvim', run = 'make' })
    use({ 'nvim-telescope/telescope-file-browser.nvim', requires = 'nvim-telescope/telescope.nvim' })
    use({ 'nvim-telescope/telescope-packer.nvim', requires = 'nvim-telescope/telescope.nvim' })
    use({ 'nvim-treesitter/nvim-treesitter' })
    use({ 'nvim-neo-tree/neo-tree.nvim', branch = 'v2.x',
      requires = { 'nvim-lua/plenary.nvim', 'kyazdani42/nvim-web-devicons', 'MunifTanjim/nui.nvim' } })
    use({ 'lewis6991/gitsigns.nvim' })
    use({ 'feline-nvim/feline.nvim', requires = 'kyazdani42/nvim-web-devicons' })
  end
})


--
-- Telescope
--
pcall(function()
  local telescope = require('telescope')
  local options = {
    defaults = {
      prompt_prefix = '   ',
      selection_caret = '  ',
      entry_prefix = '  ',
      borderchars = { '─', '│', '─', '│', '┌', '┐', '┘', '└' }
    }
  }
  telescope.setup(options)
  telescope.load_extension('fzf')
  telescope.load_extension('file_browser')
  telescope.load_extension('packer')
end)


--
-- Treesitter
--
pcall(function()
  require('nvim-treesitter.configs').setup({
    highlight = { enable = true },
    ensure_installed = { 'bash', 'c', 'cpp', 'go', 'json', 'lua', 'markdown', 'yaml' }
  })
end)


--
-- LSP
--
pcall(function()
  local lsp = require('lsp-zero')
  lsp.preset('recommended')
  lsp.setup()
end)


--
-- Git
--
pcall(function()
  require('gitsigns').setup()
end)


--
-- Statusline
--
pcall(function()
  local feline = require('feline')

  local options = {
    lsp = require 'feline.providers.lsp',
    lsp_severity = vim.diagnostic.severity,
  }

  options.separator_style = {
    left = '',
    right = ' ',
    main_icon = '  ',
    vi_mode_icon = '',
    position_icon = ''
  }

  options.main_icon = {
    provider = options.separator_style.main_icon,
    hl = 'FelineIcon',
    right_sep = {
      str = options.separator_style.right,
      hl = 'FelineIconSeparator',
    }
  }

  options.file_name = {
    provider = function()
      local filename = vim.fn.expand '%:t'
      local extension = vim.fn.expand '%:e'
      local icon = require('nvim-web-devicons').get_icon(filename, extension)
      if icon == nil then
        icon = ''
        return icon
      end
      return icon .. ' ' .. filename .. ' '
    end,
    hl = 'FelineFileName',
    right_sep = {
      str = options.separator_style.right,
      hl = 'FelineFileNameSeparator'
    }
  }

  options.dir_name = {
    provider = function()
      local dir_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':t')
      return ' ' .. dir_name .. ' '
    end,
    hl = 'FelineDirName',
    right_sep = {
      str = options.separator_style.right,
      hl = 'FelineDirNameSeparator'
    }
  }

  options.diff = {
    add = {
      provider = 'git_diff_added',
      hl = 'FelineGitAddIcon',
      icon = ' '
    },
    change = {
      provider = 'git_diff_changed',
      hl = 'FelineGitChangeIcon',
      icon = '  '
    },
    remove = {
      provider = 'git_diff_removed',
      hl = 'FelineGitRemoveIcon',
      icon = '  '
    }
  }

  options.git_branch = {
    provider = 'git_branch',
    hl = 'FelineGitBranchIcon',
    icon = '  '
  }

  options.diagnostic = {
    error = {
      provider = 'diagnostic_errors',
      enabled = function()
        return options.lsp.diagnostics_exist(options.lsp_severity.ERROR)
      end,
      hl = 'FelineLspError',
      icon = '  '
    },
    warning = {
      provider = 'diagnostic_warnings',
      enabled = function()
        return options.lsp.diagnostics_exist(options.lsp_severity.WARN)
      end,
      hl = 'FelineLspWarning',
      icon = '  '
    },
    hint = {
      provider = 'diagnostic_hints',
      enabled = function()
        return options.lsp.diagnostics_exist(options.lsp_severity.HINT)
      end,
      hl = 'FelineLspHints',
      icon = '  '
    },
    info = {
      provider = 'diagnostic_info',
      enabled = function()
        return options.lsp.diagnostics_exist(options.lsp_severity.INFO)
      end,
      hl = 'FelineLspInfo',
      icon = '  '
    }
  }

  options.lsp_icon = {
    provider = function()
      if next(vim.lsp.buf_get_clients()) ~= nil then
        local lsp_name = vim.lsp.get_active_clients()[1].name
        return ' ' .. lsp_name .. ' (lsp)'
      else
        return ''
      end
    end,
    hl = 'FelineLspIcon'
  }

  options.lsp_progress = {
    provider = function()
      local Lsp = vim.lsp.util.get_progress_messages()[1]

      if Lsp then
        local msg = Lsp.message or ''
        local percentage = Lsp.percentage or 0
        local title = Lsp.title or ''
        local spinners = { '⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏' }
        local success_icon = { '', '', '' }

        local ms = vim.loop.hrtime() / 1000000
        local frame = math.floor(ms / 120) % #spinners

        if percentage >= 70 then
          return string.format(' %%<%s %s %s (%s%%%%) ', success_icon[frame + 1], title, msg, percentage)
        end

        return string.format(' %%<%s %s %s (%s%%%%) ', spinners[frame + 1], title, msg, percentage)
      end

      return ''
    end,
    hl = 'FelineLspProgress'
  }

  options.mode_hlgroups = {
    ['n'] = { 'NORMAL', 'FelineNormalMode' },
    ['no'] = { 'N-PENDING', 'FelineNormalMode' },
    ['i'] = { 'INSERT', 'FelineInsertMode' },
    ['ic'] = { 'INSERT', 'FelineInsertMode' },
    ['t'] = { 'TERMINAL', 'FelineTerminalMode' },
    ['v'] = { 'VISUAL', 'FelineVisualMode' },
    ['V'] = { 'V-LINE', 'FelineVisualMode' },
    [''] = { 'V-BLOCK', 'FelineVisualMode' },
    ['R'] = { 'REPLACE', 'FelineReplaceMode' },
    ['Rv'] = { 'V-REPLACE', 'FelineReplaceMode' },
    ['s'] = { 'SELECT', 'FelineSelectMode' },
    ['S'] = { 'S-LINE', 'FelineSelectMode' },
    [''] = { 'S-BLOCK', 'FelineSelectMode' },
    ['c'] = { 'COMMAND', 'FelineCommandMode' },
    ['cv'] = { 'COMMAND', 'FelineCommandMode' },
    ['ce'] = { 'COMMAND', 'FelineCommandMode' },
    ['r'] = { 'PROMPT', 'FelineConfirmMode' },
    ['rm'] = { 'MORE', 'FelineConfirmMode' },
    ['r?'] = { 'CONFIRM', 'FelineConfirmMode' },
    ['!'] = { 'SHELL', 'FelineTerminalMode' }
  }

  local fn = vim.fn
  local function get_color(group, attr)
    return fn.synIDattr(fn.synIDtrans(fn.hlID(group)), attr)
  end

  options.separator_git = {
    provider = options.separator_style.left,
    hl = function()
      return {
        fg = get_color('FelineGit', 'bg#'),
        bg = get_color('Feline', 'bg#')
      }
    end
  }

  options.git_empty_space = {
    provider = ' ',
    hl = 'FelineGit'
  }

  options.separator_mode = {
    provider = options.separator_style.left,
    hl = function()
      return {
        fg = get_color(options.mode_hlgroups[vim.fn.mode()][2], 'fg#'),
        bg = get_color('FelineGit', 'bg#')
      }
    end
  }

  options.mode_icon = {
    provider = options.separator_style.vi_mode_icon,
    hl = function()
      return {
        fg = get_color('Feline', 'bg#'),
        bg = get_color(options.mode_hlgroups[vim.fn.mode()][2], 'fg#')
      }
    end
  }

  options.mode_name = {
    provider = function()
      return ' ' .. options.mode_hlgroups[vim.fn.mode()][1]
    end,
    hl = function()
      return {
        fg = get_color('Feline', 'bg#'),
        bg = get_color(options.mode_hlgroups[vim.fn.mode()][2], 'fg#')
      }
    end
  }

  options.mode_empty_space = {
    provider = options.separator_style.left,
    hl = function()
      return {
        fg = get_color(options.mode_hlgroups[vim.fn.mode()][2], 'fg#'),
        bg = get_color(options.mode_hlgroups[vim.fn.mode()][2], 'fg#')
      }
    end
  }

  options.separator_position = {
    provider = options.separator_style.left,
    hl = function()
      return {
        fg = get_color('FelinePositionSeparator', 'fg#'),
        bg = get_color(options.mode_hlgroups[vim.fn.mode()][2], 'fg#')
      }
    end
  }

  options.position_icon = {
    provider = options.separator_style.position_icon,
    hl = 'FelinePositionIcon'
  }

  options.current_line = {
    provider = function()
      local current_line = vim.fn.line '.'
      local total_line = vim.fn.line '$'

      if current_line == 1 then
        return ' Top '
      elseif current_line == vim.fn.line '$' then
        return ' Bot '
      end
      local result, _ = math.modf((current_line / total_line) * 100)
      return ' ' .. result .. '%% '
    end,

    hl = 'FelineCurrentLine'
  }

  local function add_table(tbl, inject)
    if inject then
      table.insert(tbl, inject)
    end
  end

  -- components are divided in 3 sections
  options.left = {}
  options.middle = {}
  options.right = {}

  -- left
  add_table(options.left, options.main_icon)
  add_table(options.left, options.file_name)
  add_table(options.left, options.dir_name)

  add_table(options.left, options.lsp_icon)
  add_table(options.left, options.diagnostic.error)
  add_table(options.left, options.diagnostic.warning)
  add_table(options.left, options.diagnostic.hint)
  add_table(options.left, options.diagnostic.info)

  -- middle
  add_table(options.middle, options.lsp_progress)

  -- right
  add_table(options.right, options.separator_git)
  add_table(options.right, options.diff.add)
  add_table(options.right, options.diff.change)
  add_table(options.right, options.diff.remove)
  add_table(options.right, options.git_branch)

  add_table(options.right, options.git_empty_space)
  add_table(options.right, options.separator_mode)
  add_table(options.right, options.mode_icon)
  add_table(options.right, options.mode_name)
  add_table(options.right, options.mode_empty_space)
  add_table(options.right, options.separator_position)
  add_table(options.right, options.position_icon)
  add_table(options.right, options.current_line)

  -- Initialize the components table
  options.components = { active = {} }

  options.components.active[1] = options.left
  options.components.active[2] = options.middle
  options.components.active[3] = options.right

  options.theme = {
    fg = get_color('Feline', 'fg#'),
    bg = get_color('Feline', 'bg#')
  }

  feline.setup({
    theme = options.theme,
    components = options.components
  })
end)


--
-- Neotree
--
pcall(function() vim.cmd('let g:neo_tree_remove_legacy_commands = 1') end)


--
-- Colorscheme
--
pcall(function() cmd('source ~/.vimrc_background') end)

-- base16-classic-dark color table
local base_16 = {
  base00 = '#151515', -- 00 Black
  base01 = '#202020', -- 01
  base02 = '#303030', -- 02
  base03 = '#505050', -- 03 Bright Black
  base04 = '#B0B0B0', -- 04
  base05 = '#D0D0D0', -- 05 White
  base06 = '#E0E0E0', -- 06
  base07 = '#F5F5F5', -- 07 Bright White
  base08 = '#AC4142', -- 08 Red
  base09 = '#D28445', -- 09
  base0A = '#F4BF75', -- 0A Yellow
  base0B = '#90A959', -- 0B Green
  base0C = '#75B5AA', -- 0C Cyan
  base0D = '#6A9FB5', -- 0D Blue
  base0E = '#AA759F', -- 0E Magenta
  base0F = '#8F5536' -- 0F
}


-- Packer
hl(0, 'VertSplit', { default = false, fg = base_16.base0C, bg = base_16.base01 }) -- border

-- Telescope
hl(0, 'TelescopePreviewBorder', { fg = base_16.base0B, bg = base_16.base00 })
hl(0, 'TelescopePromptBorder', { fg = base_16.base0A, bg = base_16.base00 })
hl(0, 'TelescopeResultsBorder', { fg = base_16.base0C, bg = base_16.base00 })

hl(0, 'TelescopePreviewTitle', { fg = base_16.base0B, bg = base_16.base00 })
hl(0, 'TelescopePromptTitle', { fg = base_16.base0A, bg = base_16.base00 })
hl(0, 'TelescopeResultsTitle', { fg = base_16.base0C, bg = base_16.base00 })

-- CMP
hl(0, 'CmpBorder', { fg = base_16.base0A, bg = base_16.base00 })
hl(0, 'CmpDocBorder', { fg = base_16.base0A, bg = base_16.base00 })

-- Feline
hl(0, 'Feline', { fg = base_16.base05, bg = base_16.base01 })
hl(0, 'FelineIcon', { fg = base_16.base01, bg = base_16.base0D })
hl(0, 'FelineIconSeparator', { fg = base_16.base0D, bg = base_16.base03 })
hl(0, 'FelineFileName', { fg = base_16.base06, bg = base_16.base03 })
hl(0, 'FelineFileNameSeparator', { fg = base_16.base03, bg = base_16.base02 })
hl(0, 'FelineDirName', { fg = base_16.base05, bg = base_16.base02 })
hl(0, 'FelineDirNameSeparator', { fg = base_16.base02, bg = base_16.base01 })
hl(0, 'FelineGit', { fg = base_16.base05, bg = base_16.base02 })
hl(0, 'FelineGitAddIcon', { fg = base_16.base0B, bg = base_16.base02 })
hl(0, 'FelineGitBranchIcon', { fg = base_16.base05, bg = base_16.base02 })
hl(0, 'FelineGitChangeIcon', { fg = base_16.base0A, bg = base_16.base02 })
hl(0, 'FelineGitRemoveIcon', { fg = base_16.base08, bg = base_16.base02 })
hl(0, 'FelineLspError', { fg = base_16.base08, bg = base_16.base01 })
hl(0, 'FelineLspWarning', { fg = base_16.base0A, bg = base_16.base01 })
hl(0, 'FelineLspHints', { fg = base_16.base0E, bg = base_16.base01 })
hl(0, 'FelineLspInfo', { fg = base_16.base0B, bg = base_16.base01 })
hl(0, 'FelineLspIcon', { fg = base_16.base0B, bg = base_16.base01 })
hl(0, 'FelineLspProgress', { fg = base_16.base0D, bg = base_16.base01 })
hl(0, 'FelineNormalMode', { fg = base_16.base08, bg = base_16.base00 })
hl(0, 'FelineInsertMode', { fg = base_16.base0E, bg = base_16.base00 })
hl(0, 'FelineTerminalMode', { fg = base_16.base0B, bg = base_16.base00 })
hl(0, 'FelineVisualMode', { fg = base_16.base0C, bg = base_16.base00 })
hl(0, 'FelineReplaceMode', { fg = base_16.base0A, bg = base_16.base00 })
hl(0, 'FelineConfirmMode', { fg = base_16.base0C, bg = base_16.base00 })
hl(0, 'FelineCommandMode', { fg = base_16.base0E, bg = base_16.base00 })
hl(0, 'FelineSelectMode', { fg = base_16.base0D, bg = base_16.base00 })
hl(0, 'FelineEmptySpace', { fg = base_16.base01, bg = base_16.base01 })
hl(0, 'FelineCurrentLine', { fg = base_16.base00, bg = base_16.base0B })
hl(0, 'FelinePositionIcon', { fg = base_16.base00, bg = base_16.base0B })
hl(0, 'FelinePositionSeparator', { fg = base_16.base0B, bg = base_16.base01 })

-- Gitsigns
hl(0, 'GitSignsChange', { fg = base_16.base0A, bg = base_16.base01 })
