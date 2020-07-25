local ECS = require 'libs.ecs'
local CAMERAS = require "libs_project.cameras"

---@class CheckVisibleSystem:ECSSystem
local System = ECS.processingSystem()
System.filter = ECS.requireAll("visible")
System.name = "CheckVisibleSystem"

---@param e Entity
function System:process(e, dt)
	local e_bbox
	if e.cell then
		local size = e.cell_info.size
		e_bbox = vmath.vector4(e.position.x - size / 2, e.position.y - size, e.position.x + size, e.position.y + size)
	elseif(e.obstacle)then
		local x,y = e.physics_body:get_position()
		local w,h = e.physics_body:get_size()
		e_bbox = vmath.vector4(x - w / 2, y - h, x + w, y + h)
	end

	if e_bbox then
		local collide = self.bbox.x < e_bbox.z and self.bbox.z > e_bbox.x and self.bbox.y < e_bbox.w and self.bbox.w > e_bbox.y
		e.visible = collide
	end
end

function System:preProcess()
	local cam = CAMERAS.main_camera
	local cam_p = cam.wpos
	local cam_view = cam.view_area
	self.bbox = vmath.vector4(cam_p.x - cam_view.x / 2, cam_p.y - cam_view.y / 2, cam_p.x + cam_view.x / 2, cam_p.y + cam_view.y / 2)
end

return System