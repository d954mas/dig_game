local COMMON = require "libs.common"
local GameEcs = require "model.game.ecs.game_ecs"
local CAMERAS = require "libs_project.cameras"
local CONSTANTS = require "libs_project.constants"
local Cells = require "model.level_cells"

---@class GameModel
local Model = COMMON.class("GameModel")

---@param world World
function Model:initialize(world)
	self.world = assert(world)
	self.time = 0
	self.ecs = GameEcs(self.world)
end

function Model:init()
	physics3d.init()
	self.ecs:init()
	self.cells = Cells(self.world, { w = 6, h = 12, cell_size = 540 / 6 })
	self:_create_borders()
	self.inited = true
end

function Model:_create_borders()
	self.ecs:add_entity(self.ecs.entities:create_border(-10, -4000, 20, 10000))
	self.ecs:add_entity(self.ecs.entities:create_border(540 + 10, -4000, 20, 10000))
end

function Model:update(dt)
	self.time = self.time + dt
	self.ecs:update(dt)
end

function Model:on_input(action, action_id) end

function Model:final()
	physics3d.clear()
end

function Model:upgrade_dig_power_is_can()
	local next_level = CONSTANTS.GAME_CONFIG.DIG.POWER_LEVELS[self.world.storage.data.hero.dig_power_level + 1]
	if (not next_level) then return false end
	return next_level.cost <= self.world.storage.data.resource.gold
end

function Model:upgrade_dig_power_upgrade()
	if (self:upgrade_dig_power_is_can()) then
		local data = self.world.storage.data
		local next_level = CONSTANTS.GAME_CONFIG.DIG.POWER_LEVELS[data.hero.dig_power_level + 1]
		data.resource.gold = data.resource.gold - next_level.cost
		data.hero.dig_power_level = data.hero.dig_power_level + 1
	end
end

function Model:upgrade_dig_speed_is_can()
	local next_level = CONSTANTS.GAME_CONFIG.DIG.SPEED_LEVELS[self.world.storage.data.hero.dig_speed_level + 1]
	if (not next_level) then return false end
	return next_level.cost <= self.world.storage.data.resource.gold
end

function Model:upgrade_dig_speed_upgrade()
	if (self:upgrade_dig_speed_is_can()) then
		local data = self.world.storage.data
		local next_level = CONSTANTS.GAME_CONFIG.DIG.SPEED_LEVELS[data.hero.dig_speed_level + 1]
		data.resource.gold = data.resource.gold - next_level.cost
		data.hero.dig_speed_level = data.hero.dig_speed_level + 1
	end
end

function Model:utils_pixels_pos_to_meters(pos)
	return self:utils_pixels_to_meters(vmath.vector3(pos.x, CONSTANTS.GAME_ZERO_Y - pos.y, pos.z))
end

function Model:utils_pixels_to_meters(pos)
	local cell_size = self.cells.config.cell_size
	return vmath.vector3(pos.x / cell_size, pos.y / cell_size, 0)
end

return Model