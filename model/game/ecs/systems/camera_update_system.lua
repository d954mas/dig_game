local ECS = require 'libs.ecs'
local CAMERAS = require "libs_project.cameras"
---@class CameraUpdateSystem:ECSSystem
local System = ECS.system()
System.name = "CameraUpdateSystem"

---@param e Entity
function System:update(dt)
	local dy = 960 - CAMERAS.main_camera.view_area.y
	CAMERAS.main_camera:set_position(vmath.vector3(270, CAMERAS.main_camera.half_view_area.y + dy, 0))

	if(self.world.game.hero.position.y< CAMERAS.main_camera.wpos.y) then
		CAMERAS.main_camera:set_position(vmath.vector3(270, self.world.game.hero.position.y, 0))

	end

end


return System