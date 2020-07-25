local Animation = require "libs.animation"

local M = {}

M.animations = {} 

function M.get_animation(key)
	assert(key)
	return assert(M.animations[key], "no animation:" .. key)
end

return M