local CONSTANTS = require "libs_project.constants"
local BaseScene = require "libs.sm.scene_with_ga"

---@class UpgradeModal:Scene
local Scene = BaseScene:subclass("UpgradeModal")
function Scene:initialize()
    BaseScene.initialize(self, "UpgradeModal", "/upgrade_modal#collectionproxy")
    self._config.modal = true
end

function Scene:load_done()
    BaseScene.load_done(self)
end

return Scene