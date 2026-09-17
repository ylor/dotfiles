return {
	"folke/snacks.nvim",
	opts = {
		picker = {
			sources = {
				explorer = {
					hidden = true,
					ignored = true,
					exclude = { ".git" },
				},
				files = {
					hidden = true,
					ignored = true,
				},
			},
		},
	},
}
