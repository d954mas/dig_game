local WORLD = require "model.world"

--UPDATE SOME INFO.
--THAT INFO USED BY DEBUG GUI
local M = {}

M.entities = 0
M.hero_pos = vmath.vector3(0)

function M.init()
end


function M.update_entities()
	local have_ecs = WORLD.game_model and WORLD.game_model.ecs and WORLD.game_model.ecs
end

function M.update(dt)
	local have_ecs = WORLD.game_model and WORLD.game_model.ecs and WORLD.game_model.ecs
	M.entities = have_ecs and #have_ecs.ecs.entities or 0
	if(have_ecs) then
		if WORLD.game_model.ecs.hero then
			M.hero_pos.x = WORLD.game_model.ecs.hero.position.x
			M.hero_pos.y = WORLD.game_model.ecs.hero.position.y
			M.hero_pos.z = WORLD.game_model.ecs.hero.position.z
		end
	end
end

return M