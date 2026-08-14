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
			this.m.JSHandle.asyncCall("show", this.queryData());
		}
	}

	function hide(_withSlideAnimation = false) {
		if (this.m.JSHandle != null) {
			this.Tooltip.hide();
			this.m.JSHandle.asyncCall("hide", _withSlideAnimation);
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

	function queryPoolNames() {
		// TODO: implement fetching every gauntlet pool stored in files
		local mod = ::ModGauntletEvents.Mod;
		local arr = []
		arr.extend(mod.PersistentData.getFiles())
		return arr
	}

	function gatherUnitFlags(_unit) {
		local esssential_fields = ["Type", "Num", "Weight", "DifficultyRating"]
		local ret = []
		foreach(key, value in _unit){
			if(esssential_fields.find(key) != null
			|| !(value)){
				// ::logDebug("Key of unit: " + key)
				continue;
			}
			ret.append(key);
		}
		return ret
	}

	function queryCoSpawn(_unit) {
		if (!("CoSpawn" in _unit)){
			return [];
		}
		local arr = []
		foreach(co in _unit.CoSpawn){
			local name = this.getNameFromScriptPath(co.Type.Script);
			local num = "Num" in co ? co.Num : 1;
			arr.append({
				Name = name,
				Num = num
			})
		}
		return arr
	}

	function queryPool(_name) {
		local ret_pool = []
		if (_name in ::Const.World.Spawn) {
			local pool = ::Const.World.Spawn[_name][0].Pool;
			foreach(unit in pool) {
				local name = this.getNameFromScriptPath(unit.Type.Script)
				local num = "Num" in unit ? unit.Num : 1;
				local dr_score = "DifficultyRating" in unit ? unit.DifficultyRating : null;
				local weight = "Weight" in unit ? unit.Weight : 1;
				ret_pool.append({
					Name = name,
					Num = num,
					DifficultyRating = dr_score,
					Weight = weight,
					Flags = this.gatherUnitFlags(unit)
				})
			}
			return ret_pool;
		} else {
			::logError(_name + " DOES NOT EXIST IN CONST.WORLD.SPAWN!");
			return [];
		}

	}

	function getNameFromScriptPath(_path)
	{
		local arr = split(_path , "/")
		return arr[arr.len() - 1]
	}

	function queryUnitsFromSpawnlistMaster() {
		local ret = [];
		foreach(unitName, unitProperties in ::Const.World.Spawn.Troops){
			local unit = clone unitProperties;
			unit.DisplayName <- this.getNameFromScriptPath(unitProperties.Script)
			ret.append(unit)
		}
		return ret

	}

	function queryData() {
		// local pool_name = "GauntletLate";
		local pool_names = this.queryPoolNames();
		local ret = {
			AllUnits = this.queryUnitsFromSpawnlistMaster(),
			Pools = []
		}
		foreach(name in pool_names){
			ret.Pools.append({
				Name = name,
				Troops = this.queryPool(name)
			})
		}
		return ret
	}

});