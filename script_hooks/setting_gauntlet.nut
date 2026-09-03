::ModGauntletEvents.Settings <- {
	EnableGauntlet = true,
	BaseGauntletInterval = "10",
	AllowLootingRegardlessEcoDiff = false,
	AllowSuppliesAfterCombat = true,
	AllowChampions = false,
	AllowMiniBosses = false,
	AllowBosses = false,
	MinDifficultyScore = "10",
	MaxDifficultyScore = "120",
	MaxExpertDifficultyScoreOnDay = "115",
	AdditionalScore = "2",
	EndofEarlyGameThreshold = "12",
	EndofMidGameThreshold = "35",
	SafeDaysUntilFirstGauntlet = "3",
	UsePresetSpawnlist = false,
	PresetSpawnlistScore = "30",
	SquishyLimit = 0.45,
	BossLimit = 0.5,
	DifficultyModifierBeginner = 1.0,
	DifficultyModifierVeteran = 1.15,
	DifficultyModifierExpert = 1.3,
	ExtraDayBeginner = 40,
	ExtraDaysVeteran = 20,
	StartCombatSetLastGauntlet = false
};


local tools = {
	processIntegerInput = function(_input, _oldValue) {
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

	processFloatInput = function(_input, _oldValue) {
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

local printChangedValue = function(_oldValue) {
	if (this.getValue() == _oldValue) {
		return;
	}

	local id = "getSerDeFlag" in this ? this.getSerDeFlag() : null;

	::logInfo("After changed " + id + ": Changed old value: " + _oldValue + " to new value: " + this.getValue());
}

local processIntegerAndPrintChangedValue = function(_oldValue) {
	// value must be user's input string
	if (this.getValue() == _oldValue) {
		return;
	}
	local ret = tools.processIntegerInput(this.getValue(), _oldValue);
	if (!ret.Result) {
		this.set(_oldValue)
	}
	local id = "getSerDeFlag" in this ? this.getSerDeFlag() : null;

	::logInfo("After changed " + id + ": Changed old value: " + _oldValue + " to new value: " + this.getValue());
}

local processFloatAndPrintChangedValue = function(_oldValue) {
	if (this.getValue() == _oldValue) {
		return;
	}
	local ret = tools.processFloatInput(this.getValue(), _oldValue);
	if (!ret.Result) {
		this.set(_oldValue)
	}
	local id = "getSerDeFlag" in this ? this.getSerDeFlag() : null;

	::logInfo("After changed " + id + ": Changed old value: " + _oldValue + " to new value: " + this.getValue());
}

local page = ::ModGauntletEvents.Mod.ModSettings.addPage("general_page", "General");
page.addTitle("titleGeneral", "General")

local enableGauntlet = page.addBooleanSetting("enable_gauntlet", ::ModGauntletEvents.Settings.EnableGauntlet, "Enable Gauntlet Events");
enableGauntlet.setDescription("Enable the gauntlet events to be fired.");
enableGauntlet.addAfterChangeCallback(printChangedValue);

local baseGauntletInterval = page.addStringSetting("base_gauntlet_interval", ::ModGauntletEvents.Settings.BaseGauntletInterval, "Gauntlet Cooldown");
baseGauntletInterval.setDescription("Days cooldown between two gauntlet events.");
baseGauntletInterval.addAfterChangeCallback(processIntegerAndPrintChangedValue);

local safeDaysUntilFirstGauntlet = page.addStringSetting("safe_day_until_1st_gauntlet", ::ModGauntletEvents.Settings.SafeDaysUntilFirstGauntlet, "Days until 1st gauntlet starts");
safeDaysUntilFirstGauntlet.setDescription("Number of safe days before launching the 1st gauntlet events.");
safeDaysUntilFirstGauntlet.addAfterChangeCallback(processIntegerAndPrintChangedValue);

page.addTitle("suppliesGauntlet", "Combat Reward");

local allowLootingRegardlessEcoDiff = page.addBooleanSetting("allow_looting_regardless_ecodiff", ::ModGauntletEvents.Settings.AllowLootingRegardlessEcoDiff, "Allow Looting, regardless of Economy Difficulty");
allowLootingRegardlessEcoDiff.setDescription("Allow looting from enemies corpses, ignoring the economic difficulty settings. Does not work during mid-battle.");
allowLootingRegardlessEcoDiff.addAfterChangeCallback(printChangedValue);

local allowSuppliesAfterBattle = page.addBooleanSetting("allow_supplies_after_battle", ::ModGauntletEvents.Settings.AllowSuppliesAfterCombat, "Allow Supplies After Battles");
allowSuppliesAfterBattle.setDescription("Allow giving some supplies after the gauntlet event's fight concludes.");
allowSuppliesAfterBattle.addAfterChangeCallback(printChangedValue);

page.addTitle("extraEnemiesGauntlet", "Extra Enemies");

local allowChampion = page.addBooleanSetting("allow_champions", ::ModGauntletEvents.Settings.AllowChampions, "Allow Champions spawn");
allowChampion.setDescription("Allow champions to be spawn in LATEGAME gauntlet events. Range champions are not included. This setting isn't affected by global or bonus champion chance.");
allowChampion.addAfterChangeCallback(printChangedValue);

local allowMiniBoss = page.addBooleanSetting("allow_minibosses", ::ModGauntletEvents.Settings.AllowMiniBosses, "Allow Mini-Bosses spawn");
allowMiniBoss.setDescription("Allow non-champion/non-boss but highly disruptive enemies to be spawn in LATEGAME gauntlet events, such as swordmasters, master archers and lindwurms.")
allowMiniBoss.addAfterChangeCallback(printChangedValue);

local allowBoss = page.addBooleanSetting("allow_bosses", ::ModGauntletEvents.Settings.AllowBosses, "Allow Bosses spawn");
allowBoss.setDescription("Allow legendary bosses and dangerous champions to be spawn in LATEGAME gauntlet events. Range champions are not included.");
allowBoss.addAfterChangeCallback(printChangedValue);

// difficulty & composition
local pageScaling = ::ModGauntletEvents.Mod.ModSettings.addPage("scaling_page", "Scaling");

pageScaling.addTitle("scalingGauntlet", "Scaling Function");

local earlyEndOnDay = pageScaling.addStringSetting("early_end_on_day", ::ModGauntletEvents.Settings.EndofEarlyGameThreshold, "Earlygame ends on Days");
earlyEndOnDay.setDescription("The day to switch the gauntlet's enemies pool from an earlygame pool to a midgame one.");
earlyEndOnDay.addAfterChangeCallback(processIntegerAndPrintChangedValue);

local midEndOnDay = pageScaling.addStringSetting("mid_end_on_day", ::ModGauntletEvents.Settings.EndofMidGameThreshold, "Midgame ends on Days");
midEndOnDay.setDescription("The day to switch the gauntlet's enemies pool from an midgame pool to a lategame one.");
midEndOnDay.addAfterChangeCallback(processIntegerAndPrintChangedValue);

local minDifficultyScore = pageScaling.addStringSetting("min_difficulty_score", ::ModGauntletEvents.Settings.MinDifficultyScore, "Minimum Difficulty Score");
minDifficultyScore.setDescription("The lower limit of difficulty score, used for creating the gauntlet's composition. This limit is applied last after the calculation of difficulty score.");
minDifficultyScore.addAfterChangeCallback(processIntegerAndPrintChangedValue);

local maxDifficultyScore = pageScaling.addStringSetting("max_difficulty_score", ::ModGauntletEvents.Settings.MaxDifficultyScore, "Maximum Difficulty Score");
maxDifficultyScore.setDescription("The upper limit of difficulty score, used for creating the gauntlet's composition. This limit is applied last after the calculation of difficulty score.");
maxDifficultyScore.addAfterChangeCallback(processIntegerAndPrintChangedValue);

local maxScoreOnDay = pageScaling.addStringSetting("max_score_on_day", ::ModGauntletEvents.Settings.MaxExpertDifficultyScoreOnDay, "Maximum Difficulty Score reached on Days (Expert)");
maxScoreOnDay.setDescription("The day when the maximum difficulty score is reached, on Expert combat difficulty.");
maxScoreOnDay.addAfterChangeCallback(processIntegerAndPrintChangedValue);

local additionalScore = pageScaling.addStringSetting("additional_score", ::ModGauntletEvents.Settings.AdditionalScore, "Additional Difficulty Score");
additionalScore.setDescription("Flat score value to the Difficulty Score. Can also be interpreted as Difficulty Score on day 0.");
additionalScore.addAfterChangeCallback(processIntegerAndPrintChangedValue);

pageScaling.addTitle("compositionGauntlet", "Composition");

local squishyLimit = pageScaling.addRangeSetting("squishy_limit", ::ModGauntletEvents.Settings.SquishyLimit, 0, 1, 0.05, "Squishy Unit's Limit")
squishyLimit.setDescription("The limit for the percentage of total Diffculty Score, from units with Squishy Melee, Range or Crowd Control flags.")
squishyLimit.addAfterChangeCallback(printChangedValue) // value here is accepted as float, so no need to process

local bossLimit = pageScaling.addRangeSetting("boss_limit", ::ModGauntletEvents.Settings.BossLimit, 0, 1, 0.05, "Boss Unit's Limit")
bossLimit.setDescription("The limit for the percentage of total Diffculty Score, from units with Boss flags.")
bossLimit.addAfterChangeCallback(printChangedValue) // same here

pageScaling.addSpacer("spacerGauntlet", "72rem", "4rem")
pageScaling.addTitle("difficultyBasedGauntlet", "Difficulty-based Setting")

local diffModBeginner = pageScaling.addRangeSetting("diff_mod_beginner", ::ModGauntletEvents.Settings.DifficultyModifierBeginner, 1, 3, 0.05, "Difficulty Modifier (Beginner)")
diffModBeginner.setDescription("Difficulty Modifier for Beginner Combat settings. Recommend values [1.0, 1.2].")
diffModBeginner.addAfterChangeCallback(printChangedValue)

local diffModVeteran = pageScaling.addRangeSetting("diff_mod_veteran", ::ModGauntletEvents.Settings.DifficultyModifierVeteran, 1, 3, 0.05, "Difficulty Modifier (Veteran)")
diffModVeteran.setDescription("Difficulty Modifier for Veteran Combat settings. Recommend values [1.15, 1.3].")
diffModVeteran.addAfterChangeCallback(printChangedValue)

local diffModExpert = pageScaling.addRangeSetting("diff_mod_expert", ::ModGauntletEvents.Settings.DifficultyModifierExpert, 1, 3, 0.05, "Difficulty Modifier (Expert)")
diffModExpert.setDescription("Difficulty Modifier for Expert Combat settings. Recommend values [1.3, 1.5].")
diffModExpert.addAfterChangeCallback(printChangedValue);

// local extraDaysBeginner = pageScaling.addStringSetting("extra_day_beginner", ::ModGauntletEvents.Settings.ExtraDayBeginner, "Extra days for Days Max Difficulty Score reached (Beginner)")
// extraDaysBeginner.setDescription("Extra days for scaling function to reach max value on the Beginner difficulty. Adding to Days when Maximum Difficulty Score is reached (Expert). Recommend to be 4 times the interval value.")
// extraDaysBeginner.addAfterChangeCallback(processIntegerAndPrintChangedValue)

// local extraDaysVeteran = pageScaling.addStringSetting("extra_day_veteran", ::ModGauntletEvents.Settings.ExtraDayVeteran, "Extra days for Days Max Difficulty Score reached (Veteran)")
// extraDaysVeteran.setDescription("Extra days for scaling function to reach max value on the Veteran difficulty. Adding to Days when Maximum Difficulty Score is reached (Expert). Recommend to be 2 times the interval value.")
// extraDaysVeteran.addAfterChangeCallback(processIntegerAndPrintChangedValue)

local pagePreset = ::ModGauntletEvents.Mod.ModSettings.addPage("preset_page", "Preset/Debug");
pagePreset.addTitle("titlePreset", "Preset/Debug Setting")

local usePresetSpawnlist = pagePreset.addBooleanSetting("use_preset_spawnlist", ::ModGauntletEvents.Settings.UsePresetSpawnlist, "Use the preset spawnlist");
usePresetSpawnlist.setDescription("Use the preset spawnlist (GauntletPreset) instead of randomly generated one. Intended usage is for debug only.")
usePresetSpawnlist.addAfterChangeCallback(printChangedValue);

local presetSpawnlistScore = pagePreset.addStringSetting("preset_spawnlist_score", ::ModGauntletEvents.Settings.PresetSpawnlistScore, "Preset Spawnlist's Difficulty Score");
presetSpawnlistScore.setDescription("Difficulty score for the preset spawnlist. Intended usage is for debug only.");
presetSpawnlistScore.addAfterChangeCallback(processIntegerAndPrintChangedValue);

local startCombatSetLastGauntlet = pagePreset.addBooleanSetting("start_combat_set_last",::ModGauntletEvents.Settings.StartCombatSetLastGauntlet, "Start Combat Reset Cooldown")
startCombatSetLastGauntlet.setDescription("\'Start Combat\' option in the editor menu resets the gauntlet event's cooldown.")
startCombatSetLastGauntlet.addAfterChangeCallback(printChangedValue)