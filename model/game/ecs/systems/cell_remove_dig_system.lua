local ECS = require 'libs.ecs'
local HASHES = require "libs.hashes"

---@class CellRemoveDigSystem:ECSSystem
local System = ECS.processingSystem()
System.filter = ECS.requireAll("cell")
System.name = "CellRemoveDigSystem"

---@param e Entity
function System:process(e, dt)
	if e.cell_info.hp == 0 and not e.auto_destroy then
		e.auto_destroy = true
		self.world:addEntity(e)
		local ds = self.world.game.world.storage.data
		ds.resource.gold = ds.resource.gold + e.cell_info.config.cost
	end
end

return System