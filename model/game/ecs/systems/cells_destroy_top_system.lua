local ECS = require 'libs.ecs'
local CAMERAS = require "libs_project.cameras"
local CONSTANTS = require "libs_project.constants"
---@class CellsDestroyTopSystem:ECSSystem
local System = ECS.system()
System.name = "CellsDestroyTopSystem"

function System:update(dt)
	local cam = CAMERAS.main_camera
	local min_y = cam.wpos.y + cam.half_view_area.y

	local cells = self.world.game.world.game_model.cells
	local cells_y = math.floor(-(min_y - CONSTANTS.GAME_ZERO_Y) / cells.config.cell_size)
	if (cells_y > cells.min_y) then
		cells:clear_to(cells_y)
	end

end

return System