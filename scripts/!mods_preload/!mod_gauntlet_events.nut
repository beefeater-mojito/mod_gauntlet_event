// ::mods_registerMod("gauntlet_events", 1.0, "Gauntlet Event");
// ::mods_queue("gauntlet_events", null, function(){
// 	::include("script_hooks/hook_gauntlet")
// });

::ModGauntletEvents <- {
	ID = "mod_gauntlet_events",
	Name = "The Gauntlet",
	Version = "1.1.0",
}
// Instantiate the Modern Hooks object, add MSU as a requirement, and queue after MSU
// https://bbmodding.enduriel.com/docs/modern-hooks/mod-object/
::ModGauntletEvents.MH <- ::Hooks.register(::ModGauntletEvents.ID, ::ModGauntletEvents.Version, ::ModGauntletEvents.Name);
::ModGauntletEvents.MH.require("mod_msu");
::ModGauntletEvents.MH.queue(">mod_msu", function () {
	// Instantiate the MSU Object
	// https://github.com/MSUTeam/MSU/wiki/Mod
	::ModGauntletEvents.Mod <- ::MSU.Class.Mod(::ModGauntletEvents.ID, ::ModGauntletEvents.Version, ::ModGauntletEvents.Name);

	::ModGauntletEvents.Settings <- {
		BaseGauntletInterval = "10",
		AlwaysAllowLooting = false,
		MaxDifficultyScore = "90",
		MaxExpertDifficultyScoreOnDay = "120",
		EndofEarlyGameThreshold = "15",
		EndofMidGameThreshold = "35",
		SafeDaysUntilFirstGauntlet = "3"
	};

	local tools = {
		processIntegerInput = function (_input, _oldValue) {
			if (typeof _input != "string") {
				return {
					Value = _oldValue.tointeger(),
					Result = false,
				};
			}

			local ret = _input.tointeger();

			if (typeof ret != "integer") {
				return {
					Value = _oldValue.tointeger(),
					Result = false,
				};
			}

			return {
				Value = ret,
				Result = true,
			};
		},

		processFloatInput = function (_input, _oldValue) {
			if (typeof _input != "string") {
				return {
					Value = _oldValue.tofloat(),
					Result = false,
				};
			}

			local ret = _input.tofloat();

			if (typeof ret != "float") {
				return {
					Value = _oldValue.tofloat(),
					Result = false,
				};
			}

			return {
				Value = ret,
				Result = true,
			};
		}
	};

	local formatValue = function (v) {
		return typeof v == "string" ? "\"" + v + "\"" : v;
	}

	local dumpCustom;
	dumpCustom = function (value, indent = "") {
		switch (typeof value) {
			case "table":
				this.logDebug(indent + "{");
				foreach (k, v in value) {
					if (typeof v == "table" || typeof v == "array") {
						this.logDebug(indent + "  " + k + " =");
						dumpCustom(v, indent + "  ");
					} else {
						this.logDebug(indent + "  " + k + " = " + formatValue(v));
					}
				}
				this.logDebug(indent + "}");
				break;

			case "array":
				this.logDebug(indent + "[");
				foreach (i, v in value) {
					if (typeof v == "table" || typeof v == "array") {
						this.logDebug(indent + "  [" + i + "] =");
						dumpCustom(v, indent + "  ");
					} else {
						this.logDebug(indent + "  [" + i + "] = " + formatValue(v));
					}
				}
				this.logDebug(indent + "]");
				break;

			default:
				this.logDebug(indent + formatValue(value));
				break;
		}
		return "Dump done!"
	}

	local page = ::ModGauntletEvents.Mod.ModSettings.addPage("general_page", "General");

	local baseGauntletInterval = page.addStringSetting("base_gauntlet_interval", ::ModGauntletEvents.Settings.BaseGauntletInterval, "Gauntlet Cooldown");
	baseGauntletInterval.setDescription("Days cooldown between two gauntlet events.");
	baseGauntletInterval.addAfterChangeCallback(function (_oldValue) {
		if (this.getValue() == _oldValue) {
			return;
		}
		local ret = tools.processIntegerInput(this.getValue(), _oldValue);

		if (!ret.Result) {
			this.set(_oldValue);
		}

		::logInfo("After change \'Gauntlet Cooldown\': Changed old value: " + _oldValue + " to new value: " + this.getValue());
		::ModGauntletEvents.Settings.BaseGauntletInterval = ret.Value;
	});

	local AlwaysAllowLooting = page.addBooleanSetting("always_allow_looting", ::ModGauntletEvents.Settings.AlwaysAllowLooting, "Always Allow Looting");
	AlwaysAllowLooting.setDescription("Allow looting from enemies corpses, ignoring economic difficulty settings. Does not work during mid-battle.")

	local maxDifficultyScore = page.addStringSetting("max_difficulty_score", ::ModGauntletEvents.Settings.MaxDifficultyScore, "Maximum Difficulty Score");
	maxDifficultyScore.setDescription("The upper limit of difficulty score, used for creating the gauntlet's composition.");
	maxDifficultyScore.addAfterChangeCallback(function (_oldValue) {
		if (this.getValue() == _oldValue) {
			return;
		}
		local ret = tools.processIntegerInput(this.getValue(), _oldValue);

		if (!ret.Result) {
			this.set(_oldValue);
		}

		::logInfo("After change \'Maximum Difficulty Score\': Changed old value: " + _oldValue + " to new value: " + this.getValue());
		::ModGauntletEvents.Settings.maxDifficultyScore = ret.Value;
	});

	local maxScoreOnDay = page.addStringSetting("max_score_on_day", ::ModGauntletEvents.Settings.MaxExpertDifficultyScoreOnDay, "Maximum Difficulty Score reached on Days (Expert)");
	maxScoreOnDay.setDescription("The day where the maximum difficulty score is reached, on Expert combat difficulty.");
	maxScoreOnDay.addAfterChangeCallback(function (_oldValue) {
		if (this.getValue() == _oldValue) {
			return;
		}
		local ret = tools.processIntegerInput(this.getValue(), _oldValue);

		if (!ret.Result) {
			this.set(_oldValue);
		}

		::logInfo("After change \'Maximum Difficulty Score reached on Days (Expert)\': Changed old value: " + _oldValue + " to new value: " + this.getValue());
		::ModGauntletEvents.Settings.maxScoreOnDay = ret.Value;
	});

	local earlyEndOnDay = page.addStringSetting("early_end_on_day", ::ModGauntletEvents.Settings.EndofEarlyGameThreshold, "Earlygame ends on Days");
	earlyEndOnDay.setDescription("The day to switch the gauntlet's enemies pool from an earlygame pool to a midgame one.");
	earlyEndOnDay.addAfterChangeCallback(function (_oldValue) {
		if (this.getValue() == _oldValue) {
			return;
		}
		local ret = tools.processIntegerInput(this.getValue(), _oldValue);

		if (!ret.Result) {
			this.set(_oldValue);
		}

		::logInfo("After change \'Earlygame ends on Days\': Changed old value: " + _oldValue + " to new value: " + this.getValue());
		::ModGauntletEvents.Settings.EndofEarlyGameThreshold = ret.Value;
	});

	local midEndOnDay = page.addStringSetting("mid_end_on_day", ::ModGauntletEvents.Settings.EndofMidGameThreshold, "Midgame ends on Days");
	midEndOnDay.setDescription("The day to switch the gauntlet's enemies pool from an midgame pool to a lategame one.");
	midEndOnDay.addAfterChangeCallback(function (_oldValue) {
		if (this.getValue() == _oldValue) {
			return;
		}
		local ret = tools.processIntegerInput(this.getValue(), _oldValue);

		if (!ret.Result) {
			this.set(_oldValue);
		}

		::logInfo("After change \'Midgame ends on Days\': Changed old value: " + _oldValue + " to new value: " + this.getValue());
		::ModGauntletEvents.Settings.EndofMidGameThreshold = ret.Value;
	});

	local safeDaysUntilFirstGauntlet = page.addStringSetting("safe_day_until_1st_gauntlet", ::ModGauntletEvents.Settings.SafeDaysUntilFirstGauntlet, "Days until 1st gauntlet starts");
	safeDaysUntilFirstGauntlet.setDescription("Number of days before launching the 1st gauntlet events.");
	safeDaysUntilFirstGauntlet.addAfterChangeCallback(function (_oldValue) {
		if (this.getValue() == _oldValue) {
			return;
		}
		local ret = tools.processIntegerInput(this.getValue(), _oldValue);

		if (!ret.Result) {
			this.set(_oldValue);
		}

		::logInfo("After change \'Days until 1st gauntlet starts\': Changed old value: " + _oldValue + " to new value: " + this.getValue());
		::ModGauntletEvents.Settings.SafeDaysUntilFirstGauntlet = ret.Value;
	});

	// Includes the 'load' file of your private folder
	// Within this file, you can execute things or load more files (such as hooks)
	// as to better organise your mod, not clutter this file, and load things in order
	::include("script_hooks/hook_gauntlet.nut");

	// Disable retreat on the gauntlet fight
	::ModGauntletEvents.MH.hookTree("scripts/ai/tactical/agent", function (q) {
		q.onAddBehaviors = @(__original) function () {
			__original();
			if (World.Statistics.getFlags().get("HasGauntletInit")) {
				this.removeBehavior(::Const.AI.Behavior.ID.Retreat);
			}
		}
	});

	// Disallow player's resurrection in Gauntlet mode, to prevent item lost
	::ModGauntletEvents.MH.hookTree("scripts/entity/tactical/human", function (q) {
		q.generateCorpse = @(__original) function ( _tile, _fatalityType, _killer) {
			local corpse = __original( _tile, _fatalityType, _killer);
			if (World.Statistics.getFlags().get("HasGauntletInit")){
				::logDebug("GAUNTLET HOOK DEBUG: CHECKING SPAWN CORPSE!")
				if (corpse.Faction == this.Const.Faction.Player){
					::logDebug("GAUNTLET HOOK DEBUG: MAKE PLAYER'S CORPSE NON-RESURRECTABLE IN GAUNTLET MODE!")
					corpse.IsResurrectable = false;
				}
			}
			return corpse
		}
	});

});
