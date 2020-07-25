local SM = require "libs.sm.scene_manager"
--MAIN SCENE MANAGER
local sm = SM()

local scenes = {
	require "scenes.scenes.game.game_scene",
	require "scenes.modal.upgrade.upgrade_modal",
}

sm.SCENES = {
	GAME = "GameScene",
}

sm.MODALS = {
	UPGRADE = "UpgradeModal"
}

function sm:register_scenes()
	local reg_scenes = {}
	for i, v in ipairs(scenes) do reg_scenes[i] = v() end --create instances
	self:register(reg_scenes)
end

return sm