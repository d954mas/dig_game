local COMMON = require "libs.common"
local URLS = {
	factory = {
		empty = msg.url("game:/factories#empty"),
		debug_physics_body_static = msg.url("game:/factories#debug_physics_body_static"),
		debug_physics_body_dynamic = msg.url("game:/factories#debug_physics_body_dynamic"),
		sprite = msg.url("game:/factories#sprite"),
		cell_sprite = msg.url("game:/factories#cell_sprite"),
		hero = msg.url("game:/factories#hero"),
	}
}

---@class DebugPhysicsBodyGo
---@field root url

---@class HeroGo
---@field root url
---@field sprite url
---@field dig_down url
---@field dig_left url
---@field dig_right url

---@class SpriteGo
---@field root url
---@field sprite url

local M = {}

M.URLS = URLS

function M.create_draw_object_with_sprite(sprite_factory_url, position, sprite_hash, scale)
	assert(sprite_factory_url)
	assert(position)
	assert(sprite_hash)
	local root = msg.url(factory.create(URLS.factory.empty, position, nil, nil, scale))
	local sprite_go = root
	sprite_go = msg.url(factory.create(sprite_factory_url))
	go.set_parent(sprite_go, root)
	go.set_position(vmath.vector3(0, 0, 0), sprite_go)

	local sprite_url = msg.url(sprite_go.socket, sprite_go.path, COMMON.HASHES.hash("sprite"))

	sprite.play_flipbook(sprite_url, sprite_hash)
	return { root = root, sprite = sprite_url }
end

---@return HeroGo
function M.create_hero(position)
	local nodes = collectionfactory.create(M.URLS.factory.hero,
			position, nil, nil, vmath.vector3(64 / 16))
	local root = msg.url(nodes[COMMON.HASHES.hash("/root")])
	local dig_down = msg.url(nodes[COMMON.HASHES.hash("/dig_down")])
	local dig_left = msg.url(nodes[COMMON.HASHES.hash("/dig_left")])
	local dig_right = msg.url(nodes[COMMON.HASHES.hash("/dig_right")])
	local sprite = msg.url(nodes[COMMON.HASHES.hash("/sprite")])

	msg.post(dig_down,COMMON.HASHES.MSG.DISABLE)
	msg.post(dig_left,COMMON.HASHES.MSG.DISABLE)
	msg.post(dig_right,COMMON.HASHES.MSG.DISABLE)

	local sprite_url = msg.url(sprite.socket, sprite.path, COMMON.HASHES.hash("sprite"))

	return { root = root, sprite = sprite_url, dig_down = dig_down, dig_left = dig_left, dig_right = dig_right }
end

---@param physics NativePhysicsRectBody
---@return DebugPhysicsBodyGo
function M.create_debug_physics_body(physics)
	local x, y, z = physics:get_position()
	local w, h, l = physics:get_size()
	local f = URLS.factory
	local root = msg.url(factory.create(physics:is_static() and f.debug_physics_body_static or f.debug_physics_body_dynamic,
			vmath.vector3(x, y, 32), nil, nil, vmath.vector3(w / 64, h / 64, l / 64)))
	return { root = root }
end

return M