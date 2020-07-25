local ECS = require 'libs.ecs'
---@class MovementSystem:ECSSystem
local System = ECS.processingSystem()
System.filter = ECS.requireAll("position", "movement")
System.name = "MovementSystem"

System.gravity = -400

---@param e Entity
function System:process(e, dt)
	--normalize keyboard input
	if e.movement.direction.x ~= 0 and e.movement.direction.y ~= 0 then
		--e.movement.direction = vmath.normalize(e.movement.direction)
	else
		e.movement.velocity.x = 0
	end

	--https://defold.com/tutorials/platformer/
	local target_speed = e.movement.direction.x * e.movement.max_speed


	-- calculate the difference between our current speed and the target speed
	local speed_diff = target_speed - e.movement.velocity.x

	-- the complete acceleration to integrate over this frame
	local acceleration = vmath.vector3(0, e.movement.gravity and System.gravity or 0, 0)

	if (e.movement.gravity) then
		local cell = physics3d.raycast(e.position.x, e.position.y, 0, e.position.x, e.position.y - 0.1, 0, physics3d.GROUPS.OBSTACLE)[1]
		if (cell) then
			acceleration.y = 0
			e.movement.velocity.y = 0
		end
	end

	if speed_diff ~= 0 then
		-- set the acceleration to work in the direction of the difference
		acceleration.x = speed_diff < 0 and -e.movement.acceleration or e.movement.acceleration
		if ((acceleration.x < 0 and e.movement.velocity.x > 0) or (acceleration.x > 0 and e.movement.velocity.x < 0)) then
			e.movement.velocity.x = 0
		end
	end

	-- calculate the velocity change this frame (dv is short for delta-velocity)
	local dv = acceleration * dt
	-- check if dv exceeds the intended speed difference, clamp it in that case
	if math.abs(dv.x) > math.abs(speed_diff) then dv.x = speed_diff end

	local v0 = e.movement.velocity
	-- calculate the new velocity by adding the velocity change
	e.movement.velocity = e.movement.velocity + dv

--	local right = e.movement.velocity.x > 0
	--e.movement.velocity.x = math.min(math.abs(e.movement.velocity.x),e.movement.max_speed)
--	if not right then e.movement.velocity.x = - e.movement.velocity.x end

	-- calculate the translation this frame by integrating the velocity
	local dp = (v0 + e.movement.velocity) * dt * 0.5



	if (e.movement.to_point) then
		local max_move_x = e.movement.to_point.x - e.position.x
		if math.abs(dp.x) > math.abs(max_move_x) then
			acceleration.x = 0
			e.movement.velocity.x = 0
			dp.x = max_move_x
		end
	end



	e.position.x = e.position.x + dp.x
	e.position.y = e.position.y + dp.y

end

return System