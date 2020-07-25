local ECS = require 'libs.ecs'
---@class FlipSpriteToDirectionSystem:ECSSystem
local System = ECS.processingSystem()
System.filter = ECS.requireAll("flip_to_direction","movement")
System.name = "FlipSpriteToDirectionSystem"

---@param e Entity
function System:process(e, dt)
	local sprite_url = e.hero_go.sprite
	if(e.movement.direction.x~=0)then
		local flip = e.movement.direction.x < 0
		if(e.sprite_flip == nil or flip ~= e.sprite_flip)then
			e.sprite_flip =flip
			sprite.set_hflip(sprite_url,flip)
		end
	end
end


return System