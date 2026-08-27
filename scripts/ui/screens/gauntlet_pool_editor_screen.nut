this.gauntlet_pool_editor_screen <- ::inherit("scripts/mods/msu/ui_screen", {
	m = {
		ID = "GauntletPoolEditorScreen",
	},

	// basic functionality
	function toggle() {
		if (this.m.Animating) {
			return false
		}
		this.isVisible() ? this.hide() : this.show();
		return true;
	}

	function create() {
		this.ui_screen.create();
	}

	function show(_withSlideAnimation = false) {
		local activeState = ::MSU.Utils.getActiveState();
		activeState.onHide();
		this.Cursor.setCursor(this.Const.UI.Cursor.Hand);

		switch (activeState.ClassName) {
			case "world_state":
				activeState.setAutoPause(true);
				activeState.m.MenuStack.push(function() {
					::ModGauntletEvents.Screen.hide();
					this.onShow();
					this.setAutoPause(false);
				});
				break;

			case "main_menu_state":
				activeState.m.MenuStack.push(function() {
					::ModGauntletEvents.Screen.hide();
					this.onShow();
				});
				break;
		}

		if (this.m.JSHandle != null) {
			this.Tooltip.hide();
			local data = this.queryData();
			this.m.JSHandle.asyncCall("show", data);
		}
	}

	function hide(_withSlideAnimation = true) {
		if (this.m.JSHandle != null && this.isVisible()) {
			local activeState = ::MSU.Utils.getActiveState();
			this.m.JSHandle.asyncCall("hide", _withSlideAnimation)
			activeState.m.MenuStack.pop();
			return false
		}
	}

	// jshandle
	function onClose(_withSlideAnimation = true) {
		if (this.m.OnClosePressedListener != null) {
			this.m.OnClosePressedListener();
		} else {
			this.hide();
		}
	}

	function onSaveGauntletPool(_pool) {
		// ::logDebug("Received unit's weight: " + _pool.Troops[0].Weight);
		// ::logDebug("Received unit's DR: " + _pool.Troops[0].DifficultyRating);
		local poolKey = _pool.Name;
		local poolProperty = {
			Pool = []
		};
		poolProperty.Pool = this.constructPoolFromJSON(_pool.Troops);

		::ModGauntletEvents.Setup.writePoolToFile(poolKey, poolProperty);
	}

	function onRestoreDefault(_name) {
		::ModGauntletEvents.Setup.defaultOverwritePool(_name)
		if (this.m.JSHandle != null) {
			this.Tooltip.hide();
			this.m.JSHandle.asyncCall("show", this.queryData(_name));
		}
	}

	function onRestoreDefaultAll() {
		::ModGauntletEvents.Setup.defaultOverwriteAll();
		if (this.m.JSHandle != null) {
			this.Tooltip.hide();
			this.m.JSHandle.asyncCall("show", this.queryData());
		}
	}

	function onStartCombat(_combatSetting) {
		this.hide();

		::ModGauntletEvents.Setup.startGauntletCombat(_combatSetting);
	}

	function extractValueFromStr(_value, _type) {
		try {
			if (typeof _value != "string") {
				::logError("INVALID VALUE'S TYPE: " + typeof _value)
			}
			if (_type == "integer") {
				return _value.tointeger();
			}
			if (_type == "float") {
				return _value.tofloat();
			}
			if (_type == "number") {
				if (_value.find(".") == null) {
					return _value.tointeger();
				}
				return _value.tofloat();
			}
			return _value;
		} catch (exception) {
			throw exception;
		}
		return null;
	}

	function constructCoSpawnFromJSON(_JSONarr) {
		local pool = []
		foreach(unit in _JSONarr) {
			local data = {
				UnitKey = unit.Name,
				Num = this.extractValueFromStr(unit.Num, "integer")
			}
			pool.append(data);
		}
		return pool;
	}

	function constructPoolFromJSON(_JSONpool) {
		local pool = []
		foreach(unit in _JSONpool) {
			local data = {
				UnitKey = unit.Name,
				Num = this.extractValueFromStr(unit.Num, "integer"),
				DifficultyRating = this.extractValueFromStr(unit.DifficultyRating, "number"),
				Weight = this.extractValueFromStr(unit.Weight, "number"),
				CoSpawn = this.constructCoSpawnFromJSON(unit.CoSpawn)
			}
			foreach(flag in unit.Flags) {
				if (!flag) {
					continue;
				} else {
					data[flag] <- true
				}
			}
			pool.append(data)
		}
		return pool
	}

	// data query
	function gatherUnitFlags(_unit) {
		local esssential_fields = ["UnitKey", "Num", "Weight", "DifficultyRating", "CoSpawn"]
		local ret = []
		foreach(key, value in _unit) {
			if (esssential_fields.find(key) != null ||
				!(value)) {
				// ::logDebug("Key of unit: " + key)
				continue;
			}
			ret.append(key);
		}
		return ret
	}


	function queryCoSpawn(_unit) {
		if (!("CoSpawn" in _unit)) {
			return [];
		}
		local arr = []
		foreach(co in _unit.CoSpawn) {
			local num = "Num" in co ? co.Num : 1;
			arr.append({
				Name = co.UnitKey,
				Num = num.tostring()
			})
		}
		return arr
	}

	function queryTroops(_troops, _forceFlags = []) {
		local ret_pool = []
		foreach(unit in _troops) {
			local unitFlags = this.gatherUnitFlags(unit);
			unitFlags.extend(_forceFlags)

			ret_pool.append({
				Name = unit.UnitKey,
				Num = "Num" in unit ? unit.Num.tostring() : 1,
				DifficultyRating = "DifficultyRating" in unit ? unit.DifficultyRating.tostring() : null,
				Weight = "Weight" in unit ? unit.Weight.tostring() : 1,
				Flags = unitFlags,
				CoSpawn = this.queryCoSpawn(unit)
			})
		}
		return ret_pool
	}

	function getNameFromScriptPath(_path) {
		local arr = split(_path, "/")
		return arr[arr.len() - 1]
	}

	function getFormattedPool(_poolName, _poolProperties) {
		local forceFlags =
			"ForceFlags" in _poolProperties ?
			_poolProperties.ForceFlags : [];
		local pool = {
			Name = _poolName,
			ForceFlags = forceFlags,
			Troops = this.queryTroops(_poolProperties.Pool, forceFlags)
		}
		return pool
	}

	function queryPools() {
		local mod = ::ModGauntletEvents.Mod;
		local filename = ::ModGauntletEvents.Setup.getFilename()
		if (!(mod.PersistentData.hasFile(filename))) {
			::logError("GAUNTLET DATA FILE DOES NOT EXIST")
			return []
		}
		local pools = []
		local readData = mod.PersistentData.readFile(filename);
		foreach(poolName, poolProperties in readData) {
			pools.append(this.getFormattedPool(poolName, poolProperties))
		}
		return pools
	}

	function queryUnitsFromSpawnlistMaster() {
		local ret = [];
		foreach(unitName, unitProperties in ::Const.World.Spawn.Troops) {
			local unit = clone unitProperties;
			unit.DisplayName <- unitName
			ret.append(unit)
		}
		return ret
	}

	function querytInitialCombatSetting() {
		local current_day = ::World.getTime().Days;
		local difficultyScore = ::ModGauntletEvents.Setup.calculateDifficultyScoreBasedOnDay(current_day);
		local ret = {
			Days = current_day,
			DifficultyScore = difficultyScore,
			AllowLooting = false,
			GiveSupplies = true
		}
		return ret
	}

	function queryData(_prevPool = null) {
		local ret = {
			AllUnits = this.queryUnitsFromSpawnlistMaster(),
			Pools = this.queryPools(),
			PreviousPoolPicked = _prevPool,
			InitialCombatSetting = this.querytInitialCombatSetting()
		}

		return ret
	}

});