local ECS = require 'libs.ecs'
local CAMERAS = require "libs_project.cameras"
---@class CellsTeraIncognitoUpdateSystem:ECSSystem
local System = ECS.system()
System.name = "CellsTeraIncognitoUpdateSystem"

function System:update(dt)
	self.world.game.world.game_model.cells:tera_incognito_update()
end

return System