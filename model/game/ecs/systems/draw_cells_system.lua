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
		e.cell_go = FACTORIES.create_cell(vmath.vector3(e.position.x, e.position.y, e.position.z),
				e.cell_info.config.image, 1)
		go.set_scale(vmath.vector3(e.cell_info.size / 16), e.cell_go.root)
		self.world:addEntity(e)
	elseif not e.visible and e.cell_go then
		go.delete(e.cell_go.root, true)
		e.cell_go = nil
		self.world:addEntity(e)
	end

	if (e.cell_go and not e.cell_info.tera_incognito and not e.cell_go.tera_incognito_changed) then
		e.cell_go.tera_incognito_changed = true
		if (e.cell_info.y == 1) then
			msg.post(e.cell_go.tera_incognito, COMMON.HASHES.MSG.DISABLE)
		else
			go.animate(e.cell_go.tera_incognito_sprite, "tint.w", go.PLAYBACK_ONCE_FORWARD, 0, go.EASING_INQUAD, 0.35, 0, function()
				msg.post(e.cell_go.tera_incognito, COMMON.HASHES.MSG.DISABLE)
			end)
		end
		msg.post(e.cell_go.cell, COMMON.HASHES.MSG.ENABLE)
	end
end

return System