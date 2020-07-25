local CONSTANTS = require "libs_project.constants"
local BaseScene = require "libs.sm.scene_with_ga"

---@class SelectLevelScene:Scene
local Scene = BaseScene:subclass("GameScene")
function Scene:initialize()
    BaseScene.initialize(self, "GameScene", "/game#collectionproxy")
end

function Scene:load_done()
    BaseScene.load_done(self)
end

return Scene