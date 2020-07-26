local COMMON = require "libs.common"
local CONSTANTS = require "libs_project.constants"

local Cells = COMMON.CLASS("Cells")

---@class CELLS_CONFIG
local CELLS_CONFIG = {
	w = "number",
	h = "number",
	cell_size = "number"
}

---@param world World
---@param config CELLS_CONFIG
function Cells:initialize(world, config)
	checks("?", "World", CELLS_CONFIG)
	self.world = world
	self.config = config
	self.ecs = self.world.game_model.ecs
	---@type Entity[][]
	self.cells = {}
	self.max_y = 0
	self.min_y = 1
	self.max_y_pixels = 0
	self:_create_cells(1)
end

function Cells:clear_to(start_y)
	start_y = math.floor(start_y)
	for y = self.min_y, start_y do
		local line = self.cells[y]
		if (line) then
			for x = 1, self.config.w do
				local cell = self.cells[y][x]
				if (cell.added_to_world) then
					cell.auto_destroy = true
					self.ecs:add_entity(cell)
				end

			end
			self.cells[y] = nil
		end
		self.min_y = y
	end
end

function Cells:valid_coords(x, y)
	return x >= 1 and x <= self.config.w and y >= self.min_y and y <= self.max_y and self.cells[y] ~= nil
end

function Cells:is_empty(x, y)
	if (y == 0) then return true end
	if (not self:valid_coords(x, y)) then return false end
	local cell = self.cells[y][x]
	return cell.added_to_world == false
end

function Cells:tera_incognito_update()
	for y = self.min_y, self.max_y do
		local line = self.cells[y]
		if (line) then
			for x = 1, self.config.w do
				local cell = self.cells[y][x]
				if (cell and cell.cell_info.tera_incognito) then
					local opened = self:is_empty(x - 1, y - 1) or self:is_empty(x, y - 1) or self:is_empty(x + 1, y - 1) or
							self:is_empty(x - 1, y) or self:is_empty(x, y) or self:is_empty(x + 1, y) or
							self:is_empty(x - 1, y + 1) or self:is_empty(x, y + 1) or self:is_empty(x + 1, y + 1)
					cell.cell_info.tera_incognito = not opened
				end

			end
		end
	end
end

function Cells:_create_cells(start_y)
	--fill all with base dirt
	local CELLS = CONSTANTS.GAME_CONFIG.CELLS
	---@type CellConfig[]
	local DIRTS = { CELLS.DIRT_1, CELLS.DIRT_2, CELLS.DIRT_3 }
	---@type CellConfig[]
	local STONES = { CELLS.STONE_1, CELLS.STONE_2, CELLS.STONE_3 }
	for y = start_y, start_y + self.config.h - 1 do
		self.cells[y] = {}
		for x = 1, self.config.w do
			local cell_pos = vmath.vector3(0)
			cell_pos.y = CONSTANTS.GAME_ZERO_Y - (y) * self.config.cell_size + self.config.cell_size / 2
			cell_pos.x = (x - 1) * self.config.cell_size + self.config.cell_size / 2
			local cell_config = COMMON.LUME.randomchoice(DIRTS)
			local cell = self.ecs.entities:create_cell(cell_config, cell_pos, self.config.cell_size, x, y)
			self.cells[y][x] = cell
			self.ecs:add_entity(cell)
		end
	end
	local stones = math.random(5, 20)
	for i = 1, stones do
		local y = math.random(start_y, start_y + self.config.h - 1)
		local x = math.random(1, self.config.w)
		local cell = self.cells[y][x]
		local cell_config = COMMON.LUME.randomchoice(STONES)
		cell.cell_info.config = cell_config
		cell.cell_info.hp = cell_config.hp
	end

	self.max_y = start_y + self.config.h - 1
	self.max_y_pixels = CONSTANTS.GAME_ZERO_Y - self.max_y * self.config.cell_size
end

function Cells:final()
	for y = 1, self.config.h do
		for x = 1, self.config.w do
			self.ecs:remove_entity(self.cells[y][x])
		end
	end
	self.cells = nil
end

return Cells