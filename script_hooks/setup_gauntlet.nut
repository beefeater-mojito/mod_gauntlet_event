this.setup_gauntlet <- {
	m = {
		Filename = "GauntletData",
		DefaultPoolNames = [
			"GauntletEarly",
			"GauntletMid",
			"GauntletLate",
			"GauntletChampion",
			"GauntletMiniBoss",
			"GauntletBoss",
			"GauntletPreset"
		],
		GauntletDebugInit = "GAUNTLET DEBUG: "
	}
	function getFilename() {
		return this.m.Filename;
	}
	function getDefaultPoolNames() {
		return this.m.DefaultPoolNames;
	}

	function assertUnitDataIsCorrect(_unit) {
		try {
			assert("UnitKey" in _unit && _unit.UnitKey in ::Const.World.Spawn.Troops, "UNITKEY INVALID")
			assert("DifficultyRating" in _unit && _unit.DifficultyRating > 0, "DIFFICULTYRATING INVALID")
			assert("Weight" in _unit && _unit.Weight > 0, "WEIGHT INVALID")
		} catch (exception) {
			::logError(this.m.GauntletDebugInit + "ERROR WHILE READING THIS UNIT DATA");
			::logError(exception);
			::logError("UNIT DUMP!");
			::MSU.Log.printData(_unit, 5, false)
			return false;
		}
		return true;
	}

	function assertPoolDataIsCorrect(_pool) {
		try {
			assert("Pool" in _pool && typeof _pool.Pool == "array", "TROOPS INVALID")
		} catch (exception) {
			::logError(this.m.GauntletDebugInit + "ERROR WHILE READING THIS POOL DATA");
			::logError(exception)
			return false;
		}
		foreach(unit in _pool.Pool) {
			if (!(this.assertUnitDataIsCorrect(unit))) {
				return false
			}
		}
		return true;
	}

	function assertFileDataIsCorrect() {
		local readData = null;
		try {
			local mod = ::ModGauntletEvents.Mod;
			local filename = this.getFilename();
			readData = mod.PersistentData.readFile(filename);
			assert(typeof readData == "table", "INVALID DATA IN FILE!")
			foreach(poolName, poolProperty in readData) {
				if (!(this.assertPoolDataIsCorrect(poolProperty))) {
					return false
				}
			}
		} catch (exception) {
			::logError("Error while reading data in mod's file!");::logError(exception)
			return false;
		}

		return true
	}

	function defaultOverwritePool(_poolName) {
		if (!(_poolName in ::Const.World.Spawn)) {
			::logError(_poolName + " DOESN'T EXIST IN Const.World.Spawn");
			return;
		}

		local mod = ::ModGauntletEvents.Mod;
		local filename = this.getFilename();
		local writeData = mod.PersistentData.readFile(filename);

		writeData[_poolName] <- ::Const.World.Spawn[_poolName][0]

		mod.PersistentData.createFile(filename, writeData)
		local readData = mod.PersistentData.readFile(filename)
		assert(::MSU.deepEquals(readData, writeData))
	}

	function defaultOverwriteAll() {
		local filename = this.getFilename();
		local writeData = {}

		foreach(name in this.getDefaultPoolNames()) {
			// Get the default data from config/spawnlist_gauntlet file
			if (!(name in ::Const.World.Spawn)) {
				::logError(name + " DOESN'T EXIST IN Const.World.Spawn");
				continue;
			}
			writeData[name] <- ::Const.World.Spawn[name][0]
		}

		local mod = ::ModGauntletEvents.Mod;
		mod.PersistentData.createFile(filename, writeData)
		local readData = mod.PersistentData.readFile(filename)
		assert(::MSU.deepEquals(readData, writeData))
	}
}