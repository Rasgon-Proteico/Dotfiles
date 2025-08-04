-- ~/.config/nvim/init.lua

-- -------------------------------------------------------------------
-- Opciones Generales
-- -------------------------------------------------------------------
vim.opt.number = true             -- Muestra los números de línea
vim.opt.mouse = 'a'               -- Habilita el uso del ratón en todos los modos
vim.opt.tabstop = 2               -- Un tabulador ocupa 2 espacios
vim.opt.shiftwidth = 2            -- La indentación automática usa 2 espacios
vim.opt.expandtab = true          -- Convierte los tabuladores en espacios
vim.cmd('syntax on')              -- Activa el resaltado de sintaxis
vim.opt.termguicolors = true      -- Habilita colores True Color
--vim.o.guicursor = 'a:hor20-blinkon100'-- Configuración del cursor
vim.o.guicursor='a:hor20-blinkwait700-blinkoff400-blinkon250'
-- -------------------------------------------------------------------
-- Función para compilar y ejecutar en tmux
-- -------------------------------------------------------------------
-- Función para C/C++ (sin cambios)
local function compile_and_run_cpp_in_tmux()
  -- Para saber el índice del panel, presiona Ctrl-b y luego q.
  local target_pane = "1"
  local current_file = vim.fn.expand('%:p')
  local executable = vim.fn.expand('%:p:r')
  local command_to_send = "clear && g++ -Wall " .. current_file .. " -o " .. executable .. " && " .. executable
  vim.fn.system("tmux send-keys -t " .. target_pane .. " '" .. command_to_send .. "' Enter")
  vim.notify("Comando de C++ enviado a tmux", vim.log.levels.INFO)
end

-- Nueva función para Python estándar
local function run_python_in_tmux()
  local target_pane = "1"
  local current_file = vim.fn.expand('%:p')
  -- Usamos 'python3', que es el estándar recomendado hoy en día
  local command_to_send = "clear && python3 " .. current_file
  vim.fn.system("tmux send-keys -t " .. target_pane .. " '" .. command_to_send .. "' Enter")
  vim.notify("Comando de Python enviado a tmux", vim.log.levels.INFO)
end

-- Función "despachadora" que elige qué hacer según el tipo de archivo
local function compile_or_run_file()
  local filetype = vim.bo.filetype
  if filetype == 'cpp' or filetype == 'c' then
    compile_and_run_cpp_in_tmux()
  elseif filetype == 'python' then
    run_python_in_tmux() -- <-- Ahora llama a la función de Python normal
  else
    vim.notify("No hay acción definida para el tipo de archivo: " .. filetype, vim.log.levels.WARN)
  end
end

-- -------------------------------------------------------------------
-- Atajos de Teclado (Keymaps)
-- -------------------------------------------------------------------
vim.keymap.set('n', '<C-a>', 'ggVG', { desc = 'Seleccionar todo el buffer' })
--vim.keymap.set({'n', 'v'}, '<C-f>', '/', { desc = 'Abrir búsqueda' })

-- Mapeos para seleccionar con Shift + Flechas
vim.keymap.set({'n', 'i', 'v'}, '<S-Up>', 'v<Up>', { noremap = true })
vim.keymap.set({'n', 'i', 'v'}, '<S-Down>', 'v<Down>', { noremap = true })
vim.keymap.set({'n', 'i', 'v'}, '<S-Left>', 'v<Left>', { noremap = true })
vim.keymap.set({'n', 'i', 'v'}, '<S-Right>', 'v<Right>', { noremap = true })

-- Mapeo para la función "inteligente" de compilación/ejecución
vim.keymap.set('n', '<F5>', compile_or_run_file, {
  noremap = true,
  silent = true,
  desc = "Compilar/Ejecutar en tmux (C++/Python)"
})-- -------------------------------------------------------------------
-- Solución para el Portapapeles en Wayland (Hyprland)
-- -------------------------------------------------------------------
if vim.fn.executable('wl-copy') == 1 then
  vim.opt.clipboard = 'unnamedplus'
end

-- -------------------------------------------------------------------
-- Gestor de Plugins: lazy.nvim
-- -------------------------------------------------------------------
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable',
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- -------------------------------------------------------------------
-- Lista de Plugins
-- -------------------------------------------------------------------
require('lazy').setup({
  -- Plugins básicos
  'tpope/vim-sensible',
  'github/copilot.vim',

  -- Autocompletado de paréntesis, comillas, etc.
  {
    'windwp/nvim-autopairs',
    event = "InsertEnter",
    config = function()
      require('nvim-autopairs').setup({
        check_ts = true,
        ts_config = {
          lua = {'string'},
          javascript = {'template_string'},
          java = false,
        }
      })
    end,
  },

  {
    'catppuccin/nvim',
    name = 'catppuccin',
    priority = 1000,
    config = function()
      require('catppuccin').setup({
        flavour = "mocha", -- "latte", "frappe", "macchiato", "mocha"
        --transparent_background = true,
        highlights = function(colors)
          return {
            -- Funciones como digitalWrite, print, println
            ["@function.call"] = { fg = colors.mauve },
            
            -- El objeto "Serial" (identificado como una variable/constante incorporada)
            ["@variable.builtin"] = { fg = colors.peach, style = "italic" },

            -- Números
            ["@number"] = { fg = colors.peach },

            -- Cadenas de texto (dentro de comillas)
            ["@string"] = { fg = colors.green },

            -- Constantes de Arduino como HIGH, LOW, OUTPUT, INPUT
            ["@constant.builtin"] = { fg = colors.peach },
          }
        end,
      })
      -- Carga el tema de colores al iniciar
      vim.cmd('colorscheme catppuccin')
    end,
  },
  
  -- El motor de resaltado de sintaxis Tree-sitter
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate', -- Comando para instalar y actualizar los parsers
    config = function()
      require('nvim-treesitter.configs').setup({
        -- Asegúrate de que los parsers para C++ (usado por Arduino) estén instalados
        ensure_installed = { 'c', 'cpp', 'lua', 'vim', 'vimdoc', 'python' },

        -- Activa el resaltado de sintaxis basado en Tree-sitter
        highlight = {
          enable = true,
        },
        
        -- Opcional: Activa la indentación basada en Tree-sitter
        indent = {
          enable = true,
        },
      })
    end,
  },
})

