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
			this.m.JSHandle.asyncCall("show", this.convertFallenToUIData());
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

	function queryPool(_name) {
		local ret_pool = []
		if (_name in ::Const.World.Spawn) {
			local pool = ::Const.World.Spawn[_name][0].Pool;
			foreach(i, unit in pool) {
				local arr = split(unit.Type.Script, "/")
				local name = arr[arr.len() - 1];
				local num = "Num" in unit ? unit.Num : 1;
				local dr_score = "DifficultyRating" in unit ? unit.DifficultyRating : null;
				local weight = "Weight" in unit ? unit.Weight : 1;
				ret_pool.append({
					Name = name,
					Num = num,
					DifficultyRating = dr_score,
					Weight = weight
				})
			}
			return ret_pool;
		} else {
			::logError(_name + " DOES NOT EXIST IN CONST.WORLD.SPAWN!");
			return [];
		}

	}

	function queryData() {
		local pool_name = "GauntletLate";
		local ret = {
			Name = pool_name,
			Data = this.queryPool(pool_name)
		}
		return ret
	}

	function convertFallenToUIData() {
		local result = {
			Pool = this.queryData()
		};
		return result;
	}
});