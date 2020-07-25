local ECS = require 'libs.ecs'
local COMMON = require "libs.common"
---@class GuiCellsUpdateSystem:ECSSystem
local System = ECS.processingSystem()
System.filter = ECS.filter("cell")
System.name = "GuiCellsUpdateSystem"

---@param e Entity
function System:process(e, dt)
	if (self.ctx) then
		if e.visible and not e.cell_gui then
			e.cell_gui = self.ctx.data:cell_view_create()
			e.cell_gui:set_entity(e)
			self.world:addEntity(e)
		elseif not e.visible and e.cell_go then
			e.cell_gui:dispose()
			e.cell_gui = nil
			self.world:addEntity(e)
		end

		if (e.cell_gui) then
			e.cell_gui:update_data(e)
		end
	end
end

function System:preProcess()
	if (COMMON.CONTEXT:exist(COMMON.CONTEXT.NAMES.GAME_CELLS_GUI)) then
		self.ctx = COMMON.CONTEXT:set_context_game_cells_gui()
	end

end
function System:postProcess()
	if (self.ctx) then
		self.ctx:remove()
		self.ctx = nil
	end

end

return System