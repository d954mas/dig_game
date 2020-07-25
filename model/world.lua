local COMMON = require "libs.common"
local STORAGE = require "libs_project.storage"
local GameModel = require "model.game.game_model"

local TAG = "World"

---@class World
---@field battle_model BattleModel|nil
local World = COMMON.class("World")

function World:initialize()
	self.storage = STORAGE
	self.game_model = GameModel(self)

end

function World:update(dt)
	self.storage:update(dt)
	self.game_model:update(dt)
end

function World:final()
end



return World()

