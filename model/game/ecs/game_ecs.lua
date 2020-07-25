local COMMON = require "libs.common"
local ECS = require "libs.ecs"
local SYSTEMS = require "model.game.ecs.systems"
local Entities = require "model.game.ecs.entities.entities"

---@class GameEcsWorld
local EcsWorld = COMMON.class("EcsWorld")

---@param world World
function EcsWorld:initialize(world)
	self.ecs = ECS.world()
	self.ecs.game = self
	self.world = assert(world)
	self.entities = Entities(world)


	self:_init_systems()
	self.ecs.on_entity_added = function(_, ...) self.entities:on_entity_added(...) end
	self.ecs.on_entity_updated = function(_, ...) self.entities:on_entity_updated(...) end
	self.ecs.on_entity_removed = function(_, ...) self.entities:on_entity_removed(...) end
end

function EcsWorld:init()
	self.entities:set_world(self.world)
	self.hero = self.entities:create_hero()
	self.ecs:add(self.hero)
end

function EcsWorld:find_by_id(id)
	return self.entities:find_by_id(assert(id))
end

function EcsWorld:_init_systems()
	SYSTEMS.load()

	self.ecs:addSystem(SYSTEMS.CameraUpdateSystem)

	self.ecs:addSystem(SYSTEMS.CellsCreateNewSystem)

	self.ecs:addSystem(SYSTEMS.InputSystem)

	self.ecs:addSystem(SYSTEMS.MovementSystem)


	--region physics
	self.ecs:addSystem(SYSTEMS.PhysicsUpdateBodyPositionsSystem)
	self.ecs:addSystem(SYSTEMS.PhysicsResetCorrectionSystem)
	self.ecs:addSystem(SYSTEMS.PhysicsUpdateSystem)
	self.ecs:addSystem(SYSTEMS.PhysicsCollisionWallSystem)
	--endregion

	self.ecs:addSystem(SYSTEMS.DigSystem)
	self.ecs:addSystem(SYSTEMS.CellRemoveDigSystem)

	self.ecs:addSystem(SYSTEMS.UpdateGoSystem)

	self.ecs:addSystem(SYSTEMS.CheckVisibleSystem)--after all movement before draw

	--region gui
	self.ecs:addSystem(SYSTEMS.GuiCellsUpdate)
	--endregion

	--region draw
	self.ecs:addSystem(SYSTEMS.FlipSpriteToDirectionSystem)
	self.ecs:addSystem(SYSTEMS.DrawCellsSystem)
	self.ecs:addSystem(SYSTEMS.DrawDebugPhysicsBodiesSystem)
	--endregion

	self.ecs:addSystem(SYSTEMS.CellsDestroyTopSystem)
	self.ecs:addSystem(SYSTEMS.AutoDestroySystem)
end

function EcsWorld:update(dt)
	if COMMON.CONTEXT:exist(COMMON.CONTEXT.NAMES.GAME) then
		local ctx = COMMON.CONTEXT:set_context_top_by_name(COMMON.CONTEXT.NAMES.GAME)
		self.ecs:update(dt)
		ctx:remove()
	end
end

function EcsWorld:clear()
	self.ecs:clear()
	self.ecs:refresh()
end

function EcsWorld:add(...)
	self.ecs:add(...)
end

function EcsWorld:add_entity(e)
	self.ecs:addEntity(e)
end

function EcsWorld:remove_entity(e)
	self.ecs:removeEntity(e)
end

return EcsWorld



