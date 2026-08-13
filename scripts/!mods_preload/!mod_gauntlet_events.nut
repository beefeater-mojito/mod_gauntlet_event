// ::mods_registerMod("gauntlet_events", 1.0, "Gauntlet Event");
// ::mods_queue("gauntlet_events", null, function(){
// 	::include("script_hooks/hook_gauntlet")
// });

::ModGauntletEvents <- {
	ID = "mod_gauntlet_events",
	Name = "The Gauntlet",
	Version = "1.1.3",
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
		GauntletEnabled = true,
		BaseGauntletInterval = "10",
		AlwaysAllowLooting = false,
		AllowSuppliesAfterBattle = true,
		AllowChampions = false,
		AllowMiniBosses = false,
		AllowBosses = false,
		MinDifficultyScore = "10",
		MaxDifficultyScore = "120",
		MaxExpertDifficultyScoreOnDay = "110",
		EndofEarlyGameThreshold = "15",
		EndofMidGameThreshold = "35",
		SafeDaysUntilFirstGauntlet = "3",
		UsePresetSpawnlist = false,
		PresetSpawnlistScore = "30"
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

	local enableGauntlet = page.addBooleanSetting("enable_gauntlet", ::ModGauntletEvents.Settings.GauntletEnabled, "Enable Gauntlet Events")
	enableGauntlet.setDescription("Enable the gauntlet events to be fired.");
	enableGauntlet.addAfterChangeCallback(function (_oldValue) {
		if (this.getValue() == _oldValue) {
			return;
		}
		::logInfo("After change \'Enable Gauntlet Events\': Changed old value: " + _oldValue + " to new value: " + this.getValue());
		::ModGauntletEvents.Settings.GauntletEnabled = this.getValue();
	});

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

	local alwaysAllowLooting = page.addBooleanSetting("always_allow_looting", ::ModGauntletEvents.Settings.AlwaysAllowLooting, "Always Allow Looting");
	alwaysAllowLooting.setDescription("Allow looting from enemies corpses, ignoring economic difficulty settings. Does not work during mid-battle.")
	alwaysAllowLooting.addAfterChangeCallback(function (_oldValue) {
		if (this.getValue() == _oldValue) {
			return;
		}
		::logInfo("After change \'Always Allow Looting\': Changed old value: " + _oldValue + " to new value: " + this.getValue());
		::ModGauntletEvents.Settings.AlwaysAllowLooting = this.getValue();
	});

	local allowSuppliesAfterBattle = page.addBooleanSetting("allow_supplies_after_battle", ::ModGauntletEvents.Settings.AllowSuppliesAfterBattle, "Allow Supplies After Battles");
	allowSuppliesAfterBattle.setDescription("Allow giving some supplies after the gauntlet event's fight concludes.")
	allowSuppliesAfterBattle.addAfterChangeCallback(function (_oldValue) {
		if (this.getValue() == _oldValue) {
			return;
		}
		::logInfo("After change \'Allow Supplies After Battles\': Changed old value: " + _oldValue + " to new value: " + this.getValue());
		::ModGauntletEvents.Settings.AllowSuppliesAfterBattle = this.getValue();
	});

	local allowChampion = page.addBooleanSetting("allow_champions", ::ModGauntletEvents.Settings.AllowChampions, "Allow Champions spawn");
	allowChampion.setDescription("Allow champions to be spawn in LATEGAME gauntlet events. Range champions are not included. This setting isn't affected by global or bonus champion chance.")
	allowChampion.addAfterChangeCallback(function (_oldValue) {
		if (this.getValue() == _oldValue) {
			return;
		}
		::logInfo("After change \'Allow Champions spawn\': Changed old value: " + _oldValue + " to new value: " + this.getValue());
		::ModGauntletEvents.Settings.AllowChampions = this.getValue();
	});

	local allowMiniBoss = page.addBooleanSetting("allow_minibosses", ::ModGauntletEvents.Settings.AllowMiniBosses, "Allow Mini-Bosses spawn");
	allowMiniBoss.setDescription("Allow non-champion/non-boss but highly disruptive enemies to be spawn in LATEGAME gauntlet events, such as swordmasters, master archers and lindwurms.")
	allowMiniBoss.addAfterChangeCallback(function (_oldValue) {
		if (this.getValue() == _oldValue) {
			return;
		}
		::logInfo("After change \'Allow Mini-Bosses spawn\': Changed old value: " + _oldValue + " to new value: " + this.getValue());
		::ModGauntletEvents.Settings.AllowMiniBosses = this.getValue();
	});

	local allowBoss = page.addBooleanSetting("allow_bosses", ::ModGauntletEvents.Settings.AllowBosses, "Allow Bosses spawn");
	allowBoss.setDescription("Allow legendary bosses and dangerous champions to be spawn in LATEGAME gauntlet events. Range champions are not included.")
	allowBoss.addAfterChangeCallback(function (_oldValue) {
		if (this.getValue() == _oldValue) {
			return;
		}
		::logInfo("After change \'Allow Bosses spawn\': Changed old value: " + _oldValue + " to new value: " + this.getValue());
		::ModGauntletEvents.Settings.AllowBosses = this.getValue();
	});

	local minDifficultyScore = page.addStringSetting("min_difficulty_score", ::ModGauntletEvents.Settings.MinDifficultyScore, "Minimum Difficulty Score");
	minDifficultyScore.setDescription("The lower limit of difficulty score, used for creating the gauntlet's composition.");
	minDifficultyScore.addAfterChangeCallback(function (_oldValue) {
		if (this.getValue() == _oldValue) {
			return;
		}
		local ret = tools.processIntegerInput(this.getValue(), _oldValue);

		if (!ret.Result) {
			this.set(_oldValue);
		}
	});

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
		::ModGauntletEvents.Settings.MaxDifficultyScore = ret.Value;
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
		::ModGauntletEvents.Settings.MaxDifficultyScore = ret.Value;
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

	local usePresetSpawnlist = page.addBooleanSetting("use_preset_spawnlist", ::ModGauntletEvents.Settings.UsePresetSpawnlist, "Use a preset spawnlist (for debugging)");
	usePresetSpawnlist.setDescription("Use a preset spawnlist instead of randomly generated one. Intended usage is for debug only.")
	usePresetSpawnlist.addAfterChangeCallback(function (_oldValue) {
		if (this.getValue() == _oldValue) {
			return;
		}
		::logInfo("After change \'Use a preset spawnlist\': Changed old value: " + _oldValue + " to new value: " + this.getValue());
		::ModGauntletEvents.Settings.UsePresetSpawnlist = this.getValue();
	});

	local presetSpawnlistScore = page.addStringSetting("preset_spawnlist_score", ::ModGauntletEvents.Settings.PresetSpawnlistScore, "Preset Spawnlist's Difficulty Score");
	presetSpawnlistScore.setDescription("Difficulty score for the preset spawnlist. Intended usage is for debug only.");
	presetSpawnlistScore.addAfterChangeCallback(function (_oldValue) {
		if (this.getValue() == _oldValue) {
			return;
		}
		local ret = tools.processIntegerInput(this.getValue(), _oldValue);

		if (!ret.Result) {
			this.set(_oldValue);
		}

		::logInfo("After change \'Preset Spawnlist's Difficulty Score\': Changed old value: " + _oldValue + " to new value: " + this.getValue());
		::ModGauntletEvents.Settings.PresetSpawnlistScore = ret.Value;
	});

	// Includes the 'load' file of your private folder
	// Within this file, you can execute things or load more files (such as hooks)
	// as to better organise your mod, not clutter this file, and load things in order
	::include("script_hooks/hook_gauntlet.nut");
});
