local COMMON = require "libs.common"
local EVENTS = require "libs_project.events"
local Camera = require "rendercam.rendercam_camera"

local Cameras = COMMON.class("Cameras")

function Cameras:initialize()

end

function Cameras:init()
	self.main_camera = Camera("main", {
		orthographic = true,
		near_z = -100,
		far_z = 100,
		view_distance = 0,
		fov = 60,
		ortho_scale = 1,
		fixed_aspect_ratio = false,
		aspect_ratio = vmath.vector3(540, 960, 0),
		use_view_area = true,
		view_area = vmath.vector3(540, 960, 0),
		scale_mode = Camera.SCALEMODE.FIXEDWIDTH
	})

	self.subscription = COMMON.EVENT_BUS:subscribe(EVENTS.WINDOW_RESIZED):subscribe(function()
		self:window_resized()
	end)

	self.current = self.main_camera
	self:window_resized()
end

function Cameras:update(dt)
	self.main_camera:update(dt)
end

function Cameras:set_current(camera)
	self.current = assert(camera)
end

function Cameras:set_fallback()
	self.current = self.main_camera
end

function Cameras:window_resized()
	self.main_camera:recalculate_viewport()
end

function Cameras:final()
	self.subscription:unsubscribe()
end

return Cameras()