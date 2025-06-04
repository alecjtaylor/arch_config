local alpha = require('alpha')
local dashboard = require("alpha.themes.dashboard")
dashboard.section.header.val = {


    [[   __ _| | ___  ___ (_) |_ __ _ _   _| | ___  _ __  ]],
    [[  / _` | |/ _ \/ __|| | __/ _` | | | | |/ _ \| '__| ]],
    [[ | (_| | |  __/ (__ | | || (_| | |_| | | (_) | |    ]],
    [[  \__,_|_|\___|\___|/ |\__\__,_|\__, |_|\___/|_|    ]],
    [[                 |__/          |___/                ]]

}

dashboard.section.buttons.val = {
	dashboard.button("e", "  New file", ":ene <BAR> startinsert <CR>"),
	dashboard.button("f", "󰍉  Find file", ":lua require('fzf-lua').files() <CR>"),
	dashboard.button("t", "  Browse cwd", ":NvimTreeOpen<CR>"),
	dashboard.button("r", "  Browse src", ":e ~/.local/src/<CR>"),
	dashboard.button("s", "󰯂  Browse scripts", ":e ~/scripts/<CR>"),
	dashboard.button("c", "  Config", ":e ~/.config/nvim/<CR>"),
	dashboard.button("m", "  Mappings", ":e ~/.config/nvim/lua/config/mappings.lua<CR>"),
	dashboard.button("p", "  Plugins", ":PlugInstall<CR>"),
	dashboard.button("q", "󰅙  Quit", ":q!<CR>"),
}

dashboard.section.footer.val = {
	[[   ]],
}

dashboard.section.buttons.opts.hl = "Keyword"
dashboard.opts.opts.noautocmd = true
alpha.setup(dashboard.opts)
