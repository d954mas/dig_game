local ECS = require 'libs.ecs'
local CURSOR_HELPER = require "libs_project.cursor_helper"
local COMMON = require "libs.common"
local ENUMS = require "libs_project.enums"
local CAMERAS = require "libs_project.cameras"
local INPUT = require "libs.input_receiver"

---@class InputSystem:ECSSystem
local System = ECS.processingSystem()
System.filter = ECS.requireAll("input_info")
System.name = "InputSystem"

function System:init_input()
	self.input_handler = COMMON.INPUT()
	self.input_handler:add_mouse(self.update_player_direction)
	self.input_handler:add(COMMON.HASHES.INPUT.TOUCH,function (self,action_id, action)
		if(action.pressed)then self.touched = true end
		if(action.released)then self.touched = false end
	end)
end

function System:update_player_direction(action_id, action)
	self.touch_pos = vmath.vector3(action.screen_x, action.screen_y,0)
end

function System:preProcess()

	--self.input_handler:on_input(self,e.input_info.action_id,e.input_info.action)
end

---@param e Entity
function System:process(e, dt)
	self.input_handler:on_input(self, e.input_info.action_id, e.input_info.action)
end
function System:postProcess()
	if(self.touched and INPUT.PRESSED_KEYS[COMMON.HASHES.INPUT.TOUCH] and self.touch_pos) then
		self.touch_pos_world = CAMERAS.main_camera:screen_to_world_2d(self.touch_pos.x, self.touch_pos.y)
	else
		self.touch_pos_world = nil
	end
	if (self.touch_pos_world) then
		local hero = self.world.game.hero
		local dir = self.touch_pos_world - hero.position
		dir.y = dir.y - hero.physics_lpos.y
		hero.movement.direction.x = dir.x
		hero.movement.direction.y = dir.y
		hero.movement.to_point = self.touch_pos_world
	else
		local hero = self.world.game.hero
		hero.movement.direction.x = 0
		hero.movement.direction.y = 0
		hero.movement.to_point = nil
	end
end

System:init_input()

return System