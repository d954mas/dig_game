local ECS = require 'libs.ecs'
local HASHES = require "libs.hashes"
---@class DigSystem:ECSSystem
local System = ECS.processingSystem()
System.filter = ECS.requireAll("dig_info")
System.name = "DigSystem"

---@param e Entity
function System:process(e, dt)
	local prev_dig_dir = {
		up = e.dig_info.up, down = e.dig_info.down,
		left = e.dig_info.left, right = e.dig_info.right
	}

	e.dig_info.time_delay = math.max(0, e.dig_info.time_delay - dt)

	e.dig_info.up = false
	e.dig_info.down = false
	e.dig_info.left = false
	e.dig_info.right = false
	if (e.movement.direction.y < 0) then
		e.dig_info.down = true
	end
	if (e.movement.direction.y > 0) then
		e.dig_info.up = true
	end

	if (e.movement.direction.x ~= 0) then
		e.dig_info.down = false
		e.dig_info.right = e.movement.direction.x > 0
		e.dig_info.left = e.movement.direction.x < 0
	end

	if (e.dig_info.up ~= prev_dig_dir.up) then msg.post(e.hero_go.dig_up, e.dig_info.up and HASHES.MSG.ENABLE or HASHES.MSG.DISABLE) end
	if (e.dig_info.down ~= prev_dig_dir.down) then msg.post(e.hero_go.dig_down, e.dig_info.down and HASHES.MSG.ENABLE or HASHES.MSG.DISABLE) end
	if (e.dig_info.left ~= prev_dig_dir.left) then msg.post(e.hero_go.dig_left, e.dig_info.left and HASHES.MSG.ENABLE or HASHES.MSG.DISABLE) end
	if (e.dig_info.right ~= prev_dig_dir.right) then msg.post(e.hero_go.dig_right, e.dig_info.right and HASHES.MSG.ENABLE or HASHES.MSG.DISABLE) end

	local dir
	if e.dig_info.up then dir = vmath.vector3(0, 1, 0) end
	if e.dig_info.down then dir = vmath.vector3(0, -1, 0) end
	if e.dig_info.left then dir = vmath.vector3(-1, 0, 0) end
	if e.dig_info.right then dir = vmath.vector3(1, 0, 0) end

	local start_point = vmath.vector3(e.position.x,e.position.y+32,0)
	local power_y = (dir and dir.y>0) and 60 or 45
	local power_x = 45
	if dir then
		msg.post("@render:", "draw_line", { start_point =start_point, end_point = start_point + vmath.vector3(dir.x * power_x, dir.y * power_y, 0),
											color = vmath.vector4(1, 0, 0, 0.5) })
	end

	if (dir and e.dig_info.time_delay == 0) then

		local cell = physics3d.raycast(start_point.x, start_point.y, 0, start_point.x + dir.x * power_x, start_point.y + dir.y * power_y, 0, physics3d.GROUPS.OBSTACLE)[1]
		if(not cell or not cell.body:get_user_data().cell) then
			cell = physics3d.raycast(start_point.x-30, start_point.y, 0, start_point.x-30 + dir.x * power_x, start_point.y + dir.y * power_y, 0, physics3d.GROUPS.OBSTACLE)[1]
		end
		if(not cell or not cell.body:get_user_data().cell) then
			cell = physics3d.raycast(start_point.x+30, start_point.y , 0, start_point.x+30 + dir.x * power_x, start_point.y + dir.y * power_y, 0, physics3d.GROUPS.OBSTACLE)[1]
		end

		if (cell and cell.body:get_user_data().cell) then
			local cell_e = cell.body:get_user_data()
			cell_e.cell_info.hp = math.max(0, cell_e.cell_info.hp - e.dig_info.power)
			e.dig_info.time_delay = 1 / e.dig_info.speed
		end
	end
end

return System