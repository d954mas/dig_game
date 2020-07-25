local COMMON = require "libs.common"

local Creator = COMMON.class("LevelCreator")

---@param world World
function Creator:initialize(world)
	self.world = world
	self.ecs = world.battle_model.ecs
	self.entities = self.ecs.entities
end

function Creator:create()

end

return Creator