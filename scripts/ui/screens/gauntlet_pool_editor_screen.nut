this.gauntlet_pool_editor_screen <- ::inherit("scripts/mods/msu/ui_screen", {
	m = {
		ID = "GauntletPoolEditorScreen",
		// OnConnectedListener = null,
		// OnDisconnectedListener = null,
		// OnClosePressedListener = null
	},

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
			local data = null
			try {
				data = this.queryData();
			} catch (exception){
				::logError("FAIL TO READ GAUNTLET DATA FILE!")
				::logError(exception)
				this.m.JSHandle.asyncCall("showFailedToFetchData")
				// throw exception;
				return;
			}
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

	function onClose() {
		if (this.m.OnClosePressedListener != null) {
			this.m.OnClosePressedListener();
		} else {
			this.hide()
		}
	}

	function onScreenShown() {
		this.m.Visible = true;
		this.m.Animating = false;
	}

	function onScreenHidden() {
		this.m.Visible = false;
		this.m.Animating = false;
	}

	function onScreenAnimating() {
		this.m.Animating = true;
	}


	function onScreenDisconnected() {
		if (this.m.OnDisconnectedListener != null) {
			this.m.OnDisconnectedListener();
		}
	}

	function onSaveGauntletPool(_pool) {
		local mod = ::ModGauntletEvents.Mod
		local filename = ::ModGauntletEvents.Setup.getFilename()
		local writeData = mod.PersistentData.readFile(filename)
		if (!(_pool.Name in writeData)) {
			writeData[_pool.Name] <- {
				Pool = []
			}
		}
		writeData[_pool.Name].Pool = this.constructPoolFromJSON(_pool.Troops)
		mod.PersistentData.createFile(filename, writeData)

		local readData = mod.PersistentData.readFile(filename)
		assert(::MSU.deepEquals(writeData, readData))
	}

	function onRestoreDefault() {
		::ModGauntletEvents.Setup.writeToFileWithDefaultData();
		if (this.m.JSHandle != null) {
			this.Tooltip.hide();
			this.m.JSHandle.asyncCall("show", this.queryData());
		}
	}

	function constructCoSpawnFromJSON(_JSONarr){
		local pool = []
		foreach(unit in _JSONarr){
			local data = {
				UnitKey = unit.Name,
				Num = unit.Num
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
				Num = unit.Num,
				DifficultyRating = unit.DifficultyRating,
				Weight = unit.Weight
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

	function gatherUnitFlags(_unit) {
		local esssential_fields = ["UnitKey", "Num", "Weight", "DifficultyRating", "CoSpawn"]
		local ret = []
		foreach(key, value in _unit) {
			if (esssential_fields.find(key) != null
			||	!(value)) {
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
				Num = num
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
				Num = "Num" in unit ? unit.Num : 1,
				DifficultyRating = "DifficultyRating" in unit ? unit.DifficultyRating : null,
				Weight = "Weight" in unit ? unit.Weight : 1,
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
			"ForceFlags" in _poolProperties
			? _poolProperties.ForceFlags
			: [];
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

	function queryData() {
		// local pool_name = "GauntletLate";

		local ret = {
			AllUnits = this.queryUnitsFromSpawnlistMaster(),
			Pools = this.queryPools()
		}

		return ret
	}

});