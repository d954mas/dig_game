local COMMON = require "libs.common"
local CONSTANTS = require "libs_project.constants"
local JSON = require "libs.json"

local TAG = "Storage"

local Storage = COMMON.class("Storage")

Storage.VERSION = 3
Storage.AUTOSAVE = 30
Storage.CLEAR = CONSTANTS.IS_DEBUG and false --BE CAREFUL. Do not use in prod
Storage.LOCAL = CONSTANTS.IS_DEBUG and true --BE CAREFUL. Do not use in prod

function Storage:initialize()
	self:_load_storage()
	self.prev_save_time = os.clock()
end

function Storage:_get_path()
	if (Storage.LOCAL) then
		return "storage.json"
	end
	return sys.get_save_file("game_name", "storage.json")
end

function Storage:_load_storage()
	local data = self:_get_path()
	local file = io.open(data, "r")
	if (file and not Storage.CLEAR) then
		COMMON.i("load", TAG)
		local contents, read_err = file:read("*a")
		COMMON.i("from file:\n" .. contents, TAG)
		local result, data = pcall(JSON.decode,contents)
		if(result)then
			self.data = assert(data)
		else
			print("can't load from file")
			self:_init_storage()
			self:save()
		end
	else
		self:_init_storage()
		self:save()
	end
	self:_migration()

	CONSTANTS.DEBUG.draw_cells_debug = self.data.debug.draw_cells_debug
	CONSTANTS.DEBUG.draw_physics = self.data.debug.draw_physics
	COMMON.i("loaded", TAG)
end

function Storage:update(dt)
	if (Storage.AUTOSAVE ~= -1) then
		if (os.clock() - self.prev_save_time > Storage.AUTOSAVE) then
			COMMON.i("autosave", TAG)
			self:save()
		end
	end

end

function Storage:_init_storage()
	COMMON.i("init new", TAG)
	self.data = {
		profile = {
			user_name = "d954mas"
		},
		resource = {
			gold = 0
		},
		hero = {
			dig_power_level = 1,
			dig_speed_level = 1
		},
		debug = {
			draw_physics = false,
			draw_cells_debug = false,
		},
		version = Storage.VERSION
	}
end

function Storage:_migration()
	if (self.data.version < Storage.VERSION) then
		COMMON.i(string.format("migrate from:%s to %s", self.data.version, Storage.VERSION), TAG)
		-- 1->2
		if (self.data.version < 3) then
			self:_init_storage()
		end

		self.data.version = Storage.VERSION
	end
end

function Storage:save()
	COMMON.i("save", TAG)
	self.prev_save_time = os.clock()
	local data = self:_get_path()
	local file = io.open(data, "w+")
	file:write(JSON.encode(self.data, true))

end

return Storage()