local M = {}

--ecs systems created in require.
--so do not cache then
local require_old = require
local require = function(k)
	local m = require_old(k)
	package.loaded[k] = nil
	return m
end

function M.load()
	M.AutoDestroySystem = require "model.game.ecs.systems.auto_destroy_system"
	M.CheckVisibleSystem = require "model.game.ecs.systems.check_visible_system"
	M.DrawCellsSystem = require "model.game.ecs.systems.draw_cells_system"
	M.DrawDebugPhysicsBodiesSystem = require "model.game.ecs.systems.draw_debug_physics_bodies_system"
	M.InputSystem = require "model.game.ecs.systems.input_system"
	M.MovementSystem = require "model.game.ecs.systems.movement_system"

	M.CellsCreateNewSystem = require "model.game.ecs.systems.cells_create_new_system"
	M.CellsDestroyTopSystem = require "model.game.ecs.systems.cells_destroy_top_system"

	M.GuiCellsUpdate = require "model.game.ecs.systems.gui_cells_update"

	M.DigSystem = require "model.game.ecs.systems.dig_system"
	M.CellRemoveDigSystem = require "model.game.ecs.systems.cell_remove_dig_system"

	M.PhysicsUpdateBodyPositionsSystem = require "model.game.ecs.systems.physics_update_body_positions_system"
	M.PhysicsUpdateSystem = require "model.game.ecs.systems.physics_update_system"
	M.PhysicsCollisionWallSystem = require "model.game.ecs.systems.physics_collision_obstacle_system"
	M.PhysicsResetCorrectionSystem = require "model.game.ecs.systems.physics_reset_correction_system"

	M.FlipSpriteToDirectionSystem = require "model.game.ecs.systems.flip_sprite_to_direction_system"

	M.UpdateGoSystem = require "model.game.ecs.systems.update_go_system"
	M.CameraUpdateSystem = require "model.game.ecs.systems.camera_update_system"
end

return M