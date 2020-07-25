local ECS = require 'libs.ecs'
local FACTORIES = require "model.game.factories.factories"
local COMMON = require "libs.common"

---@class DrawCellsSystem:ECSSystem
local System = ECS.processingSystem()
System.filter = ECS.requireAll("cell")
System.name = "DrawCellsSystem"

---@param e Entity
function System:process(e)
	if e.visible and not e.cell_go then
		e.cell_go = FACTORIES.create_draw_object_with_sprite(FACTORIES.URLS.factory.cell_sprite ,vmath.vector3(e.position.x,e.position.y, e.position.z),
				e.cell_info.config.image,1)
		go.set_scale(vmath.vector3(e.cell_info.size/16),e.cell_go.sprite)
		self.world:addEntity(e)
	elseif not e.visible and e.cell_go then
		go.delete(e.cell_go.root, true)
		e.cell_go = nil
		self.world:addEntity(e)
	end
end

return System