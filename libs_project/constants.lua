local HASHES = require "libs.hashes"

local SYS_INFO = sys.get_sys_info()

local M = {}

M.IS_DEBUG = SYS_INFO.system_name == "Windows"

M.GAME_SIZE = {
	width = 540,
	height = 960
}

M.GAME_ZERO_Y = 740

M.DEBUG = {
	draw_physics = true,
	draw_cells_debug = true,
}

---@class CellConfig
local _ = { type = "DIRT", image = HASHES.hash("cell_dirt_1"), hp = 10, cost = 0 }

M.GAME_CONFIG = {
	CELLS = {
		DIRT_1 = { type = "DIRT", image = HASHES.hash("cell_dirt_1"), hp = 10, cost = 0, },
		DIRT_2 = { type = "DIRT", image = HASHES.hash("cell_dirt_2"), hp = 10, cost = 0, },
		DIRT_3 = { type = "DIRT", image = HASHES.hash("cell_dirt_3"), hp = 10, cost = 0 },

		STONE_1 = { type = "STONE", image = HASHES.hash("cell_stone_1"), hp = 100, cost = 10 },
		STONE_2 = { type = "STONE", image = HASHES.hash("cell_stone_2"), hp = 100, cost = 10 },
		STONE_3 = { type = "STONE", image = HASHES.hash("cell_stone_3"), hp = 100, cost = 10 },
	},
	DIG = {
		POWER_LEVELS = {
			{ cost = 0, value = 20 },
			{ cost = 10, value = 30 },
			{ cost = 20, value = 40 },
			{ cost = 30, value = 50 },
			{ cost = 40, value = 60 },
			{ cost = 50, value = 70 },
			{ cost = 100, value = 80 },
			{ cost = 200, value = 90 },
			{ cost = 300, value = 100 },
			{ cost = 500, value = 110 },
			{ cost = 750, value = 125 },
			{ cost = 2500, value = 150 },
		},
		SPEED_LEVELS = {
			{ cost = 0, value = 5 },
			{ cost = 25, value = 5.5 },
			{ cost = 100, value = 6 },
			{ cost = 900, value = 6.5 },
			{ cost = 3000, value = 7 },
			{ cost = 10000, value = 7.5 },
		}
	}
}

return M
