local COMMON = require "libs.common"
local ANIMATIONS_CONFIGS = require "model.game.animation_configs"
local CONSTANTS = require "libs_project.constants"
local ENUMS = require "libs_project.enums"
local FACTORIES = require "model.game.factories.factories"

local Animations = require "libs.animation"
local TAG = "Entities"

---@class InputInfo
---@field action_id hash
---@field action table

---@class DigInfo
---@field up number
---@field down number
---@field left number
---@field right number
---@field speed number
---@field power number


---@class CellInfo
---@field x number
---@field y number
---@field config CellConfig
---@field size nil|number
---@field hp number
---@field tera_incognito boolean

---@class EntityMovement
---@field acceleration vector3
---@field velocity vector3
---@field direction vector3
---@field to_point nil|vector3
---@field max_speed number
---@field accel number
---@field deaccel number
---@field ignore_y boolean can't move up(hero)
---@field gravity boolean use gravity

---@class Entity
---@field tag string tag used for help when debug
---@field hero boolean true if it player entity
---@field cell boolean true if it cell entity
---@field obstacle boolean true if it obstacle entity
---@field visible boolean
---@field position vector3
---@field movement EntityMovement
---@field angle vector3 radians anticlockwise  x-horizontal y-vertical
---@field input_info InputInfo used for player input
---@field input_direction vector4 x y
---@field auto_destroy boolean if true will be destroyed
---@field auto_destroy_delay number when auto_destroy false and delay nil or 0 then destroy entity
---@field root_go nil|url
---@field hero_go nil|HeroGo
---@field cell_go nil|CellGo
---@field cell_gui nil|CellView
---@field cell_info nil|CellInfo
---@field hp nil|url
---@field physics_body NativePhysicsRectBody base collision. Not rotated.
---@field physics_static boolean|nil static bodies can't move.
---@field physics_dynamic boolean|nil dynamic bodies update their positions
---@field physics_lpos boolean|nil local pos for physics. go position = e.position + e.physics_lpos
---@field physics_obstacles_correction vector3
---@field flip_to_direction boolean
---@field dig_info DigInfo
---@field added_to_world boolean




---@class ENTITIES
local Entities = COMMON.class("Entities")

function Entities:initialize()
	---@type Entity[]
	self.by_tag = {}
	self.masks = {
		PLAYER = bit.bor(physics3d.GROUPS.ENEMY, physics3d.GROUPS.OBSTACLE, physics3d.GROUPS.PICKUPS),
		CELL = bit.bor(physics3d.GROUPS.ENEMY, physics3d.GROUPS.PLAYER, physics3d.GROUPS.BULLET_PLAYER),
	}
end

function Entities:find_by_id(id)
	return self.by_tag[assert(id)]
end

---@param world World
function Entities:set_world(world)
	self.world = assert(world)
	self.game_model = assert(world.game_model)
	self.ecs = assert(world.game_model.ecs)
end

--region ecs callbacks
---@param e Entity
function Entities:on_entity_removed(e)
	if e.root_go then go.delete(e.root_go, true) end
	if e.cell_go then go.delete(e.cell_go.root, true) end
	if e.debug_physics_body_go then go.delete(e.debug_physics_body_go, true) end
	if e.cell_gui then
		local ctx = COMMON.CONTEXT:set_context_game_cells_gui()
		e.cell_gui:dispose()
		ctx:remove()
	end
	if e.tag then self.by_tag[e.tag] = nil end
	if e.physics_body then physics3d.destroy_rect(e.physics_body) end
	e.added_to_world = false
end

---@param e Entity
function Entities:on_entity_added(e)
	if (e.tag) then
		COMMON.i("entity with tag:" .. e.tag, TAG)
		assert(not self.by_tag[e.tag])
		self.by_tag[e.tag] = e
	end
	e.added_to_world = true
end

---@param e Entity
function Entities:on_entity_updated(e)
end

---@return Entity
function Entities:create_input(action_id, action)
	return { input_info = { action_id = action_id, action = action }, auto_destroy = true }
end

---@return Entity
function Entities:create_hero()
	---@type Entity
	local e = {}
	e.position = vmath.vector3(270, CONSTANTS.GAME_ZERO_Y, 0.1)
	e.hero = true
	e.tag = "hero"
	e.hero_go = FACTORIES.create_hero(e.position)
	e.flip_to_direction = true
	e.movement = {
		velocity = vmath.vector3(0, 0, 0),
		direction = vmath.vector3(0, 0, 0),
		max_speed = 300,
		acceleration = 1000,
		deaccel = 4,
		ignore_y = true,
		gravity = true
	}

	e.dig_info = {
		left = false, right = false, up = false, down = false,
		time_delay = 0,
	}
	setmetatable(e.dig_info, {
		__index = function(_, k)
			if (k == "power") then
				return CONSTANTS.GAME_CONFIG.DIG.POWER_LEVELS[self.world.storage.data.hero.dig_power_level]
								.value
			elseif (k == "speed") then
				return CONSTANTS.GAME_CONFIG.DIG.SPEED_LEVELS[self.world.storage.data.hero.dig_speed_level]
								.value
			end
		end
	})

	e.physics_lpos = vmath.vector3(0, 17 * 4 / 2, 0)
	e.physics_body = physics3d.create_rect(e.position.x + e.physics_lpos.x, e.position.y + e.physics_lpos.y, e.position.z, 15 * 4, 17 * 4, 40,
			false, physics3d.GROUPS.PLAYER, self.masks.PLAYER)

	e.physics_dynamic = true
	e.physics_body:set_user_data(e)
	e.physics_obstacles_correction = vmath.vector3()
	return e
end

---@param config CellConfig
---@return Entity
function Entities:create_cell(config, position, cell_size, x, y)
	---@type Entity
	local e = {}
	e.position = position
	e.visible = false
	e.cell = true
	e.cell_info = {
		x = x,
		y = y,
		size = cell_size,
		config = assert(config),
		hp = config.hp,
		tera_incognito = true
	}
	e.physics_lpos = vmath.vector3(0, 0, 0)
	e.physics_body = physics3d.create_rect(e.position.x + e.physics_lpos.x, e.position.y + e.physics_lpos.y, e.position.z,
			e.cell_info.size, e.cell_info.size, 40, true, physics3d.GROUPS.OBSTACLE, self.masks.CELL)
	e.physics_static = true
	e.physics_body:set_user_data(e)
	e.physics_obstacles_correction = vmath.vector3()
	return e
end

function Entities:create_border(x, y, w, h)
	---@type Entity
	local e = {}
	e.border = true
	e.position = vmath.vector3(x, y, 0)
	e.border_position = vmath.vector3(e.position.x, e.position.y, 0)
	e.visible = false
	e.physics_lpos = vmath.vector3(0, 0, 0)
	e.physics_body = physics3d.create_rect(e.position.x + e.physics_lpos.x, e.position.y + e.physics_lpos.y, e.position.z,
			w, h, 40, false, physics3d.GROUPS.OBSTACLE, self.masks.CELL)
	e.physics_dynamic = true
	e.physics_body:set_user_data(e)
	e.physics_obstacles_correction = vmath.vector3()
	e.obstacle = true
	return e
end

return Entities




