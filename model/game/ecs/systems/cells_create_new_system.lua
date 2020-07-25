local ECS = require 'libs.ecs'
local CAMERAS = require "libs_project.cameras"
---@class CellsCreateNewSystem:ECSSystem
local System = ECS.system()
System.name = "CellsCreateNewSystem"

function System:update(dt)
	local cam = CAMERAS.main_camera
	local max_y = cam.wpos.y - cam.half_view_area.y
	local cells = self.world.game.world.game_model.cells

	if (cells.max_y_pixels > max_y) then
		cells:_create_cells(cells.max_y+1)
	end

end

return System