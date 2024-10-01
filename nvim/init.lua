-- modern way
vim.o.compatible = false

-- enable syntax highlight
vim.cmd [[syntax on]]

-- skip intro message
vim.o.shortness = vim.o.shortmess .. 'I'

-- show line numbers relative to the current line
vim.wo.relativenumber = true

-- make status line always shown
vim.o.laststatus = 2

-- backspace everywhere in insert mode
vim.o.backspace = "indent,eol,start"

-- switch buffer without having to save them first
vim.o.hidden = true

-- search case-sensitive if search pattern contains uppercase characters
vim.o.ignorecase = true
vim.o.smartcase = true

-- highlight search result when typing
vim.o.incsearch = true

-- disable the 'Q' key in normal mode
vim.api.nvim_set_keymap('n', 'Q', '<Nop>', {})

-- turn off errorbells and instead flash the screen for errors
vim.o.errorbells = false
vim.o.visualbell = true
vim.o.t_vb = ""

-- enable mouse support
vim.o.mouse = "a"

-- integrate system clipboard
vim.o.clipboard = "unnamedplus"

-- highlight on yank
vim.api.nvim_create_autocmd({ "TextYankPost" }, {
	pattern = { "*" },
	callback = function()
		vim.highlight.on_yank({
			timeout = 500,
		})
	end,
})

-- enable visual next line
vim.keymap.set("n", "j", [[v:count ? 'j' : 'gj']], { noremap = true, expr = true })
vim.keymap.set("n", "k", [[v:count ? 'k' : 'gk']], { noremap = true, expr = true })

-- enable word warpping at space
vim.opt.wrap = true
vim.opt.linebreak = true


-- Theme related settings
vim.o.background = "dark" -- "dark" or "light" for dark or light mode
