local ECS = require 'libs.ecs'
local CAMERAS = require "libs_project.cameras"

---@class BorderFollowPlayerSystem:ECSSystem
local System = ECS.processingSystem()
System.filter = ECS.requireAll("border")
System.name = "BorderFollowPlayerSystem"

---@param e Entity
function System:process(e, dt)
	local hero_pos = self.world.game.world.game_model.ecs.hero.position
	e.position.y = hero_pos.y + e.border_position.y
end


return System