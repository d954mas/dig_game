local COMMON = require "libs.common"
local GOOEY = require "gooey.themes.dirtylarry.dirtylarry"

---@class ButtonGUI
local Btn = COMMON.class("ButtonGUI")

function Btn:initialize(root_name)
	self.vh = {
		root = gui.get_node(root_name .. "/root"),
		lbl = gui.get_node(root_name .. "/lbl"),
	}
	self.root_name = root_name
	self.gooey_listener = function()
		if self.input_listener then self.input_listener() end
	end
end

function Btn:set_text(text)
	gui.set_text(self.vh.lbl, text)
end

function Btn:set_input_listener(listener)
	self.input_listener = listener
end

function Btn:on_input(action_id, action)
	return GOOEY.button(self.root_name, action_id, action, self.gooey_listener).consumed
end

return Btn



