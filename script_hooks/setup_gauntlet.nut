this.setup_gauntlet <- {
	m = {
		Filename = "GauntletData",
		GauntletEventID = "event.mod_gauntlet_events",
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
	function getDebugInit() {
		return this.m.GauntletDebugInit;
	}
	function getGauntletEventID() {
		return this.m.GauntletEventID
	}

	function assertUnitDataIsCorrect(_unit) {
		try {
			assert("UnitKey" in _unit && _unit.UnitKey in ::Const.World.Spawn.Troops)
			assert("DifficultyRating" in _unit && _unit.DifficultyRating > 0)
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
			assert("Pool" in _pool && typeof _pool.Pool == "array")
		} catch (exception) {
			::logError(this.m.GauntletDebugInit + "ERROR WHILE READING THIS POOL DATA");
			::logError(exception);
			::logError("POOL OBJ DUMP!");
			::MSU.Log.printData(_pool, 1, false);
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
			if(typeof readData != "table"){
				throw "INVALID DATA IN FILE!";
			}
			foreach(poolName, poolProperty in readData) {
				if (!(this.assertPoolDataIsCorrect(poolProperty))) {
					return false
				}
			}
		} catch (exception) {
			::logError("Error while reading data in mod's file!");
			::logError(exception);
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

	function getModSettingValue(_name, _type = "int") {
		local value = ::ModGauntletEvents.Mod.ModSettings.getSetting(_name).getValue();
		switch (_type) {
			case "int":
				return value.tointeger();
			case "float":
				return value.tofloat()
		}
		return value
	}

	function getDifficultyModifierBasedOnCombatDifficulty() {
		switch (this.World.Assets.getCombatDifficulty()) {
			case 0:
				return 1.2;
			case 1:
				return 1.35;
			case 2:
				return 1.5;
		}
		return 1.5;
	}

	function calculateDifficultyScoreBasedOnDay(_days = null, _difficulty = null) {
		local event = ::World.Events.getEvent(this.getGauntletEventID());
		event.onPrepare();
		return event.calculateDifficultyScoreBasedOnDay(_days, _difficulty)
	}

	function startGauntletCombat(_combatSetting) {
		local event = ::World.Events.getEvent(this.getGauntletEventID());
		event.onPrepare();

		if(_combatSetting.GiveSupplies){
			::logDebug(this.getDebugInit() + "GIVING PLAYERS SUPPLIES")
			local supplies = _event.getSupplyFromSuppliesNum();
			
			this.World.Assets.addArmorParts(supplies.ArmorPart);
			this.World.Assets.addMedicine(supplies.Medicine);
			this.World.Assets.addAmmo(supplies.Ammo);
		}
		return _event.preparePropertiesAndStartCombat(
			_combatSetting.Days,
			_combatSetting.DifficultyScore,
			_combatSetting.AllowLooting
		)
	}
}