local debug_init = ::ModGauntletEvents.Setup.getDebugInit();

local deepCopy;
deepCopy = function(container) {
	// Container must not have circular references
	switch (typeof container) {
		case "table":
			local result = clone container;
			foreach(k, v in container) result[k] = deepCopy(v);
			return result;
		case "array":
			local result = [];
			foreach(v in container) {
				result.append(deepCopy(v));
			}
			return result;
		default:
			return container;
	}
}

local formatValue = function(v) {
	return typeof v == "string" ? "\"" + v + "\"" : v;
}

local dumpCustom;
dumpCustom = function(value, indent = "") {
	switch (typeof value) {
		case "table":
			this.logDebug(indent + "{");
			foreach(k, v in value) {
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
			foreach(i, v in value) {
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

local GauntletPool = function() {
	return {
		name = "",
		pool = [],
		lowestDiffScore = null

		function init(name, troops_array) {
			this.name = name;
			this.pool = []
			if (troops_array.len() == 0) {
				return;
			}
			local last_unit = null;
			this.lowestDiffScore = this.getInitializedUnit(troops_array[0]).DifficultyRating;
			foreach(troop in troops_array) {
				local unit = this.getInitializedUnit(troop, last_unit);

				this.pool.append(unit);
				last_unit = unit;

				this.lowestDiffScore = this.Math.min(unit.DifficultyRating, this.lowestDiffScore);
			};

			::logDebug(debug_init + "Pool " + name + " is constructed! pool.len()=" + pool.len())
		}

		function getInitializedUnit(_unit, _prevUnit = null) {
			local unit = clone _unit;
			unit.Type <- ::Const.World.Spawn.Troops[unit.UnitKey]

			if (!("Weight" in unit)) {
				unit.Weight <- 1;
			}
			if (!("Num" in unit)) {
				unit.Num <- 1;
			}
			if (!("DifficultyRating" in unit)) {
				::logError("Unit has no DR score! Dumping unit!")
				dumpCustom(unit)
				unit.DifficultyRating <- null;
			}
			if (_prevUnit != null) {
				unit.Weight += _prevUnit.Weight;
			}
			if ("CoSpawn" in unit && unit.CoSpawn.len() > 0) {
				unit.CoSpawn = this.getInitializedCoSpawn(unit.CoSpawn)
			}
			return unit
		}

		function getInitializedCoSpawn(_coSpawn) {
			local coSpawn = clone _coSpawn;
			foreach(co in coSpawn) {
				co.Type <- ::Const.World.Spawn.Troops[co.UnitKey]
				if (!("Num" in co)) {
					co.Num <- 1;
				}
			}
			return coSpawn
		}

		function pushUnit(new_unit) {
			local unit = deepCopy(new_unit);
			if (!("Weight" in unit)) {
				unit.Weight <- 1;
			}
			if (this.pool.len() > 0) {
				unit.Weight += this.pool[this.pool.len() - 1].Weight;
			}
			this.pool.push(unit);
		}

		function removeUnitAtIdx(idx) {
			if ((typeof idx != "integer") || idx >= this.pool.len() || idx < 0) {
				this.logDebug(debug_init + "INVALID INDEX!")
				return null;
			}
			local unit = this.pool[idx];

			local unit_og_weight = idx == 0 ? unit.Weight : unit.Weight - this.pool[idx - 1].Weight;
			// ::logDebug(debug_init+"Unit to be removed: og_weight=" + unit_og_weight)
			// dumpCustom(unit)
			for (local i = idx + 1; i < this.pool.len(); i++) {
				this.pool[i].Weight -= unit_og_weight;
			}
			this.pool.remove(idx);
		}

		function getIdxFromPickingRandomUnit() {
			local r = 0;
			if (this.pool.len() <= 0) {
				this.logError(debug_init + "RANDOM PICK ON EMPTY POOL");
				return;
			}
			while (true) {
				// r = 1.0 * this.Math.rand() / ::RAND_MAX; // this will not reset seed (if you restart the game, you'll get the same gauntlet setup)
				r = 1.0 * this.Math.rand(0, ::RAND_MAX) / ::RAND_MAX;
				if (r >= 1) {
					this.logDebug(debug_init + "Lucky roll!")
					continue;
				}
				r *= this.pool[this.pool.len() - 1].Weight; // last unit has total weight
				break;
			}
			for (local i = 0; i < this.pool.len(); ++i) {
				if (this.pool[i].Weight > r) {
					return i
				}
			}
			return this.pool.len() - 1;
		}

		function getUnitAtIdx(idx) {
			if ((typeof idx != "integer") || idx >= this.pool.len() || idx < 0) {
				this.logDebug(debug_init + "INVALID INDEX!")
				return null;
			}
			return this.pool[idx];
		}

		function getUnits() {
			return this.pool;
		}

		function getPoolLen() {
			return this.pool.len()
		}

		function getPoolName() {
			return this.name;
		}
	}
}

local GauntletManager = function() {
	return {
		m = {
			BasePool = null,
			RangePool = null,
			CrowdControlPool = null,
			BossPool = null,
			SpawnList = null,
			InitDifficulty = 0,
			RemainingDifficulty = 0,

			RangeMax = 0,
			RangeTotal = 0,

			CrowdControlMax = 0,
			CrowdControlTotal = 0,

			SquishyLimit = 0,
			SquishyScore = 0,

			BossLimit = 0,
			BossScore = 0,
			BossMax = 1,
			BossTotal = 0,

			Spawnlist = {
				Cost = 0,
				MovementSpeedMult = 1.0,
				VisibilityMult = 1.0,
				VisionMult = 1.0,
				Body = "figure_noble_01",
				Troops = []
			},

			MeleeTroops = [],
			RangeTroops = [],
			CrowdControlTroops = [],

			EnemyBucket = {},
			TroopNum = 0,

			MinTroopNum = 0,
			MaxTroopNum = null,

			MinDiffScoreFromUnit = 1
		}

		function init(_troops, _squishyLimit = null, _bossLimit = null ) {
			local bossTroops = this.complementTroopsArrayWithFlag(_troops, "IsBoss");
			local rangeTroops = this.complementTroopsArrayWithFlag(_troops, "IsRange");
			local crowdControlTroops = this.complementTroopsArrayWithFlag(_troops, "IsCrowdControl");

			this.m.BossPool = this.getInitializedGauntletPool("boss", bossTroops);
			this.m.RangePool = this.getInitializedGauntletPool("range", rangeTroops);
			this.m.CrowdControlPool = this.getInitializedGauntletPool("crowdcontrol", crowdControlTroops);
			this.m.BasePool = this.getInitializedGauntletPool("base", _troops);

			this.m.SquishyLimit = _squishyLimit;
			this.m.BossLimit = _bossLimit;

			this.m.MinDiffScoreFromUnit = this.m.BasePool.lowestDiffScore
		}

		function getInitializedGauntletPool(_name, _troops){
			local pool = GauntletPool();
			pool.init(_name, _troops);
			return pool;
		}

		function complementTroopsArrayWithFlag(_troops, _flag) {
			// return an array with units containing _flag
			// and remove units with _flag inside this.pool
			local arr = _troops.filter(
				function(idx, unit) {
					return _flag in unit && unit[_flag];
				}
			)
			_troops = _troops.filter(
				function(idx, unit) {
					return !(_flag in unit && unit[_flag]);
				}
			)
			return arr
		}

		function generateSpawnList(_difficultyScore, _currentDay, _survived, _bannerUnit = null, _minTroop = 0) {
			this.m.InitDifficulty = _difficultyScore;
			this.m.RemainingDifficulty = _difficultyScore;

			this.m.RangeMax = this.Math.rand(0, 2) - 1 + this.Math.min(2, _survived);
			this.m.CrowdControlMax = this.Math.rand(0, 3) - 2 + this.Math.min(2, this.Math.ceil(_survived * 1.0 / 2));
			this.m.BossMax = this.Math.rand(0, 3) + this.Math.rand(0, this.Math.min(3, this.Math.floor(_survived * 1.0 / 2)))

			this.m.RangeTotal = 0;
			this.m.CrowdControlTotal = 0;
			this.m.SquishyScore = 0;

			this.m.SpawnList = {
				Cost = 0,
				MovementSpeedMult = 1.0,
				VisibilityMult = 1.0,
				VisionMult = 1.0,
				Body = "figure_noble_01",
				Troops = []
			};

			local absoluteMinimumTroopNum = this.getMostUnitFromLowestDRTroop();
			if (absoluteMinimumTroopNum < _minTroop) {
				::logError("Specified minimum is impossible to obtain! Switching to absolute minimum!")
			}
			this.m.MinTroopNum = this.Math.min(_minTroop, absoluteMinimumTroopNum)

			if (this.m.BossMax > 0 && this.m.BossPool.getPoolLen() > 0) {
				this.generateTroopsFromPool(this.m.BossPool);
			}
			if (this.m.RangeMax > 0 && this.m.RangePool.getPoolLen() > 0) {
				this.generateTroopsFromPool(this.m.RangePool);
			}
			if (this.m.CrowdControlMax > 0 && this.m.CrowdControlPool.getPoolLen() > 0) {
				this.generateTroopsFromPool(this.m.CrowdControlPool);
			}

			this.generateTroopsFromPool();

			if (_bannerUnit != null) {
				local num = this.Math.ceil(this.m.TroopNum * 1.0 / 22);

				this.m.SpawnList.Troops.append({
					Type = _bannerUnit,
					Num = num
				});

				this.m.SpawnList.Cost += num * _bannerUnit.Cost;
			}

			// Finalize Spawnlist
			this.m.SpawnList.Troops.extend(this.m.MeleeTroops)
			this.m.SpawnList.Troops.extend(this.m.RangeTroops)
			this.m.SpawnList.Troops.extend(this.m.CrowdControlTroops)

			return this.m.SpawnList;
		}

		function generateTroopsFromPool(_gauntletPool = null) {
			local gauntlet_pool = _gauntletPool;
			if (gauntlet_pool == null) {
				gauntlet_pool = this.m.BasePool;
			}

			::logDebug(debug_init + "Picking units from " + gauntlet_pool.getPoolName());
			while (this.m.RemainingDifficulty > 0 && gauntlet_pool.getPoolLen() > 0) {
				// ::logDebug(debug_init+"Pool dump!")
				// dumpCustom(gauntlet_pool)
				local idx = gauntlet_pool.getIdxFromPickingRandomUnit();
				local unit = gauntlet_pool.getUnitAtIdx(idx);

				if (!this.canAddUnit(unit)) {
					gauntlet_pool.removeUnitAtIdx(idx);
					continue;
				}

				this.addUnit(unit);
			}

			::logDebug(debug_init + "Remaining DR Score: " + this.m.RemainingDifficulty)
		}

		function getMostUnitFromLowestDRTroop(_diffScore = null) {
			local difficultyScore = _diffScore != null ? _diffScore : this.m.RemainingDifficulty;
			// min diff score unit are assummed to have a unit num of 1
			return this.Math.floor(difficultyScore / this.m.MinDiffScoreFromUnit);
		}

		function canAddUnit(_unit) {
			if (_unit.DifficultyRating > this.m.RemainingDifficulty) {
				return false;
			}

			local lowestDRTroopNum = this.Math.floor((this.m.RemainingDifficulty - _unit.DifficultyRating) * 1.0 / this.m.MinDiffScoreFromUnit)
			local unitNum = "Num" in _unit ? _unit.Num : 1;
			if (lowestDRTroopNum + unitNum + this.m.TroopNum < this.m.MinTroopNum) {
				return false
			}

			local squishyLimit = this.m.InitDifficulty * this.m.SquishyLimit - _unit.DifficultyRating;

			if ("IsRange" in _unit && _unit.IsRange) {
				if (this.m.RangeTotal >= this.m.RangeMax) {
					return false;
				}

				if (this.m.SquishyScore >= squishyLimit) {
					return false;
				}
			}

			if ("IsSquishyMelee" in _unit && _unit.IsSquishyMelee) {
				if (this.m.SquishyScore >= squishyLimit) {
					return false;
				}
			}

			if ("IsCrowdControl" in _unit && _unit.IsCrowdControl) {
				if (this.m.CrowdControlTotal >= this.m.CrowdControlMax) {
					return false;
				}

				if (this.m.SquishyScore >= squishyLimit) {
					return false;
				}

				if (!this.canAddSpecialCrowdControl(_unit)) {
					return false
				}
			}

			if ("IsBoss" in _unit && _unit.IsBoss) {
				if (this.m.BossTotal >= this.m.BossMax) {
					return false;
				}
				local boss_limit = this.m.InitDifficulty * this.m.BossLimit - _unit.DifficultyRating;
				if (this.m.BossScore >= boss_limit) {
					return false;
				}
			}

			return true;
		}

		function canAddSpecialCrowdControl(_unit) {
			switch (_unit.Type.ID) {
				case this.Const.EntityType.GoblinShaman:
				case this.Const.EntityType.Necromancer:
					// cannotAdd = (id in bucket) && (bucket[id] >= 1)
					return !(_unit.Type.ID in this.m.EnemyBucket) ||
						this.m.EnemyBucket[_unit.Type.ID] < 1;
				case this.Const.EntityType.Hexe:
				case this.Const.EntityType.FaultFinder:
					return !(_unit.Type.ID in this.m.EnemyBucket) ||
						this.m.EnemyBucket[_unit.Type.ID] < 2;
			}
			return true
		}

		function addUnit(_unit) {
			local isRangeFlag = false;
			local isCrowdControlFlag = false;
			if ("IsRange" in _unit && _unit.IsRange) {
				this.m.RangeTotal++;
				this.m.SquishyScore += _unit.DifficultyRating;
				isRangeFlag = true
			}

			if ("IsSquishyMelee" in _unit && _unit.IsSquishyMelee) {
				this.m.SquishyScore += _unit.DifficultyRating;
			}

			if ("IsCrowdControl" in _unit && _unit.IsCrowdControl) {
				this.m.CrowdControlTotal++;
				this.m.SquishyScore += _unit.DifficultyRating;
				isCrowdControlFlag = true
			}

			if (_unit.Type.ID in this.m.EnemyBucket) {
				this.m.EnemyBucket[_unit.Type.ID]++;
			} else {
				this.m.EnemyBucket[_unit.Type.ID] <- 1;
			}

			local num = "Num" in _unit ? _unit.Num : 1;
			local member = {
				Type = _unit.Type,
				Num = num
			}

			if ("IsBoss" in _unit && _unit.IsBoss) {
				this.m.BossTotal++;
				this.m.BossScore += _unit.DifficultyRating;
				member.IsBoss <- true;
			}
			if (isRangeFlag) {
				this.m.RangeTroops.append(member)
			} else if (isCrowdControlFlag) {
				this.m.CrowdControlTroops.append(member)
			} else {
				this.m.MeleeTroops.append(member)
			}
			// this.m.SpawnList.Troops.append(member);

			this.m.SpawnList.Cost += _unit.Type.Cost * num;
			this.m.RemainingDifficulty -= _unit.DifficultyRating;
			this.m.TroopNum += num;

			this.addCoSpawn(_unit, isRangeFlag, isCrowdControlFlag);
		}

		function addCoSpawn(_unit, _isRangeFlag = false, _isCrowdControlFlag = false) {
			if (!("CoSpawn" in _unit)) {
				return;
			};

			foreach(co in _unit.CoSpawn) {
				local num = "Num" in co ? co.Num : 1;
				local member = {
					Type = co.Type,
					Num = num
				};

				if ("IsBoss" in _unit && _unit.IsBoss) {
					member.IsBoss <- true;
				};
				// dumpCustom(member)
				if (_isRangeFlag) {
					this.m.RangeTroops.append(member)
				} else if (_isCrowdControlFlag) {
					this.m.CrowdControlTroops.append(member)
				} else {
					this.m.MeleeTroops.append(member)
				}
				this.m.SpawnList.Cost += co.Type.Cost * num;
				// Cospawns do not add toward troops' number,
				// instead they should be treated as one block,
				// and based on the main unit's num
			}
		}
	}
}

mod_gauntlet_events <- inherit("scripts/events/event", {
	m = {
		// msu setting variable
		IsPrepared = false,
		BaseGauntletInterval = 10,
		EndofEarlyGameThreshold = 15,
		EndofMidGameThreshold = 35,
		MinDifficultyScore = 0,
		MaxDifficultyScore = 90,
		MaxExpertDifficultyScoreOnDay = 120,
		AdditionalScore = 0,

		AllowLooting = 1,
		AllowSuppliesAfterCombat = true,
		DifficultyScoreModifier = 1,
		GauntletSurvived = 0,
		SuppliesNum = 0,
		SafeDaysUntilFirstGauntlet = 3,
		UsePresetSpawnList = false,
		PresetSpawnListScore = 10,

		IsEditorCombat = false
	},

	function create() {
		this.m.ID = "event.mod_gauntlet_events";
		this.m.Title = "The Gauntlet comes...";
		this.m.IsSpecial = true;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_90.png[/img]Here comes the gauntlet.",
			Image = "",
			List = [],
			Banner = [],
			Options = [{
				Text = "To battle!",
				function getResult(_event) {
					_event.registerToShowAfterCombat("Survived", "Survived");
					_event.preparePropertiesAndStartCombat();
					return 1; // 1 so that processInput doesn't throw a fuss
				}
			}],

			function start(_event) {
				World.Statistics.getFlags().set("HasGauntletInit", true);
			}
		});
		this.m.Screens.push({
			ID = "Survived",
			Text = "[img]gfx/ui/events/event_22.png[/img] The gauntlet passed.",
			Image = "",
			List = [],
			Banner = [],
			Options = [{
				Text = "We survived... for now.",
				function getResult(_event) {
					return 0
				}
			}],

			function start(_event) {
				local isEditorCombat = World.Statistics.getFlags().get("GauntletEditorCombat");
				local editorCombatAllowSupplies = World.Statistics.getFlags().get("GauntletEditorCombatGiveSupplies");

				if (!isEditorCombat || ::ModGauntletEvents.Setup.getModSettingValue("start_combat_set_last", "bool")) {
					World.Statistics.getFlags().set("GauntletLastTriggeredOnDay", this.World.getTime().Days);
				}
				World.Statistics.getFlags().set("GauntletSurvivedFlag", _event.m.GauntletSurvived + 1);
				World.Statistics.getFlags().set("HasGauntletInit", false);
				World.Statistics.getFlags().set("GauntletEditorCombat", false);

				local allow_supplies = (!isEditorCombat && _event.m.AllowSuppliesAfterCombat)
					|| (isEditorCombat && editorCombatAllowSupplies);
				if (!allow_supplies) {
					return;
				}
				local supplies = _event.getSupplyFromSuppliesNum();
				local armorPartAmount = supplies.ArmorPart;
				local medicineAmount = supplies.Medicine;
				local ammoAmount = supplies.Ammo;

				this.World.Assets.addArmorParts(armorPartAmount);
				this.World.Assets.addMedicine(medicineAmount);
				this.World.Assets.addAmmo(ammoAmount);

				local armorPartStr = "You gain [color=" + this.Const.UI.Color.PositiveEventValue + "]+" + armorPartAmount + "[/color] Tools and Supplies.";
				local medicineStr = "You gain [color=" + this.Const.UI.Color.PositiveEventValue + "]+" + medicineAmount + "[/color] Medicines.";
				local ammoStr = "You gain [color=" + this.Const.UI.Color.PositiveEventValue + "]+" + ammoAmount + "[/color] Ammunition.";

				this.List.push({
					id = 10,
					icon = "ui/icons/asset_supplies.png",
					text = armorPartStr
				})
				this.List.push({
					id = 10,
					icon = "ui/icons/asset_medicine.png",
					text = medicineStr
				})
				this.List.push({
					id = 10,
					icon = "ui/icons/asset_ammo.png",
					text = ammoStr
				})
			}
		})

	}

	function onUpdateScore() {}

	function onPrepare() {
		// ::logDebug(debug_init + "getCombatDifficulty()=" + this.World.Assets.getCombatDifficulty())
		local setup = ::ModGauntletEvents.Setup;
		this.m.BaseGauntletInterval = setup.getModSettingValue("base_gauntlet_interval");
		this.m.MinDifficultyScore = setup.getModSettingValue("min_difficulty_score");
		this.m.MaxDifficultyScore = setup.getModSettingValue("max_difficulty_score");
		this.m.MaxExpertDifficultyScoreOnDay = setup.getModSettingValue("max_score_on_day");
		this.m.EndofEarlyGameThreshold = setup.getModSettingValue("early_end_on_day");
		this.m.EndofMidGameThreshold = setup.getModSettingValue("mid_end_on_day");
		this.m.SafeDaysUntilFirstGauntlet = setup.getModSettingValue("safe_day_until_1st_gauntlet");
		this.m.PresetSpawnListScore = setup.getModSettingValue("preset_spawnlist_score");

		this.m.AllowSuppliesAfterCombat = setup.getModSettingValue("allow_supplies_after_battle", "bool");
		this.m.UsePresetSpawnList = setup.getModSettingValue("use_preset_spawnlist", "bool");

		this.m.DifficultyScoreModifier = setup.getDifficultyModifierBasedOnCombatDifficulty();
		this.m.IsEditorCombat = World.Statistics.getFlags().get("GauntletEditorCombat");

		this.m.AdditionalScore = setup.getModSettingValue("additional_score");

		if (!(World.Statistics.getFlags().get("GauntletSurvivedFlag"))) {
			World.Statistics.getFlags().set("GauntletSurvivedFlag", 0);
		}
		this.m.GauntletSurvived = World.Statistics.getFlags().getAsInt("GauntletSurvivedFlag")
		// ::logDebug(debug_init + "getEconomicDifficulty()=" + this.World.Assets.getEconomicDifficulty())
		local allowLootingRegardlessEcoDiff = setup.getModSettingValue("allow_looting_regardless_ecodiff", "bool");

		if (this.m.IsEditorCombat){
			this.m.AllowLooting = World.Statistics.getFlags().get("GauntletEditorCombatAllowLooting");
		} else if (allowLootingRegardlessEcoDiff){
			this.m.AllowLooting = true
		} else {
			switch (this.World.Assets.getEconomicDifficulty()) {
				case 0:
					this.m.AllowLooting = true;
					break;
				case 1:
					this.m.AllowLooting = this.m.GauntletSurvived > 1;
					break;
				case 2:
					this.m.AllowLooting = false;
					break;
				default:
					this.logError(debug_init + "ERROR: getEconomicDifficulty() does not return expected value!")
			}
		}

		this.m.SuppliesNum = this.getDifficultyScore();
		this.m.IsPrepared = true;
	}

	function onClear() {
		// this.m.Score = -20;
	}

	function isValid() {
		if (!(::ModGauntletEvents.Setup.getModSettingValue("enable_gauntlet", "bool"))) {
			return false
		}

		local current_day = this.World.getTime().Days;
		if (!(World.Statistics.getFlags().get("GauntletLastTriggeredOnDay"))) {
			World.Statistics.getFlags().set("GauntletLastTriggeredOnDay", 0);
		}
		local last_triggered_on_day = this.World.Statistics.getFlags().getAsInt("GauntletLastTriggeredOnDay");

		local safe_days = ::ModGauntletEvents.Setup.getModSettingValue("safe_day_until_1st_gauntlet");
		local interval = ::ModGauntletEvents.Setup.getModSettingValue("base_gauntlet_interval");

		if (current_day < safe_days) {
			return false;
		}
		if (current_day - last_triggered_on_day < interval) {
			return false;
		}
		return true;
	}

	function approximateGauntletSurvivedFromDay(days) {
		return this.Math.floor((days - 1) * 1.0 / this.m.BaseGauntletInterval)
	}

	function getDifficultyScore() {
		if(this.m.IsEditorCombat){
			return World.Statistics.getFlags().getAsInt("GauntletEditorCombatDifficultyScore");
		}

		local score = calculateDifficultyScoreBasedOnDay();
		if (score < this.m.MinDifficultyScore) {
			return this.m.MinDifficultyScore;
		}
		if (score > this.m.MaxDifficultyScore) {
			return this.m.MaxDifficultyScore
		}
		return score;
	}

	function calculateDifficultyScoreBasedOnDay(_days = null, _difficultyModifier = null) {
		local current_day = _days == null ? this.World.getTime().Days : _days;
		local diffMod = _difficultyModifier == null ? this.m.DifficultyScoreModifier : _difficultyModifier;

		local baseScore = this.m.AdditionalScore; // can be thought of as score on day 1
		if (current_day < this.m.EndofEarlyGameThreshold) {
			return this.Math.ceil(baseScore + current_day * diffMod);
		}

		local d0 = this.m.EndofEarlyGameThreshold;
		local s0 = d0 * diffMod;
		if (current_day < this.m.EndofMidGameThreshold) {
			return this.Math.ceil(baseScore + s0 + (current_day - d0) * diffMod / 2);
		}

		local extraDay = 0;
		switch (this.World.Assets.getCombatDifficulty()) {
			case 0:
				extraDay = this.m.BaseGauntletInterval * 4;
				break;
			case 1:
				extraDay = this.m.BaseGauntletInterval * 2;
				break;
			default:
				extraDay = 0;
		}
		local d1 = this.m.EndofMidGameThreshold;
		local d2 = this.m.MaxExpertDifficultyScoreOnDay + extraDay;
		local s1 = this.Math.ceil(baseScore + s0 + (d1 - d0) * diffMod / 2);
		local s2 = this.m.MaxDifficultyScore;
		// ::logDebug("d1="+d1+" d2="+d2+" s1="+s1+" s2="+s2)

		local k = log(s2 / s1) / (-d2 + d1)
		local C = s1 / (exp(-k * d1))

		return this.Math.min(this.Math.ceil(C * exp(-k * current_day)), s2);
	}

	function getGauntletPoolFromFiles(_gauntletName) { // TODO: move this to setup
		local mod = ::ModGauntletEvents.Mod;
		local filename = ::ModGauntletEvents.Setup.getFilename();
		if (!(mod.PersistentData.hasFile(filename))) {
			::ModGauntletEvents.Setup.defaultOverwriteAll();
		}
		local readData = null;
		try {
			readData = mod.PersistentData.readFile(filename);
			if (!(_gauntletName in readData)) {
				local e = debug_init + _gauntletName + " DOES NOT EXIST IN MOD FILE!";
				throw e;
			}
			return readData[_gauntletName];
		} catch (exception) {
			// error handling
			::logError(exception)
		}
		// load from default
		::logError(debug_init + "LOADING GAUNTLET POOL FROM DEFAULT LOCATION!");
		return this.getGauntletPoolFromDefault(_gauntletName)
	}

	function getGauntletPoolFromDefault(_gauntletName) {
		if (!(_gauntletName in ::Const.World.Spawn)) {
			::logError(debug_init + _gauntletName + " DOES NOT EXIST IN CONST.WORLD.SPAWN!")
			return {}
		}
		return this.Const.World.Spawn[_gauntletName][0];
	}

	function getTroopsArrayPreset() {
		return this.getTroopsArrayFromGauntletPool("GauntletPreset")
	}

	function getTroopsArrayFromGauntletPool(_gauntletName) {
		local gauntletPool = this.getGauntletPoolFromFiles(_gauntletName);
		local troops = clone gauntletPool.Pool;

		if ("ForceFlags" in gauntletPool && gauntletPool.ForceFlags.len() > 0) {
			foreach(unit in troops) {
				foreach(flag in gauntletPool.ForceFlags) {
					unit[flag] <- true;
				}
			}
		}
		return troops
	}

	function getSupplyFromSuppliesNum() {
		local ecoDiffMod = (this.World.Assets.getEconomicDifficulty() + 1) * 0.1;
		return {
			ArmorPart = this.Math.ceil(this.m.SuppliesNum * (1.25 - ecoDiffMod)),
			Medicine = this.Math.ceil(this.m.SuppliesNum * (0.75 - ecoDiffMod)),
			Ammo = this.Math.ceil(this.m.SuppliesNum * (1.75 - ecoDiffMod))
		}
	}

	function getTroopsArrayBasedOnDay() {
		local current_days = this.World.getTime().Days;
		local pool = [];
		if (current_days < this.m.EndofEarlyGameThreshold) {
			pool.extend(
				this.getTroopsArrayFromGauntletPool("GauntletEarly")
			);
		} else if (current_days < this.m.EndofMidGameThreshold) {
			pool.extend(
				this.getTroopsArrayFromGauntletPool("GauntletMid")
			)
		} else {
			pool.extend(
				this.getTroopsArrayFromGauntletPool("GauntletLate")
			);
		}

		if (this.IsChampionAllowed()) {
			pool.extend(
				this.getTroopsArrayFromGauntletPool("GauntletChampion")
			);
		}
		if (this.IsMiniBossAllowed()) {
			pool.extend(
				this.getTroopsArrayFromGauntletPool("GauntletMiniBoss")
			);
		}
		if (this.IsBossAllowed()) {
			pool.extend(
				this.getTroopsArrayFromGauntletPool("GauntletBoss")
			);
		}
		return pool;
	}

	function IsChampionAllowed() {
		return::ModGauntletEvents.Setup.getModSettingValue("allow_champions", "bool") &&
			this.World.getTime().Days >= this.m.EndofMidGameThreshold
	}

	function IsMiniBossAllowed() {
		return::ModGauntletEvents.Setup.getModSettingValue("allow_minibosses", "bool") &&
			this.World.getTime().Days >= this.m.EndofMidGameThreshold
	}

	function IsBossAllowed() {
		return::ModGauntletEvents.Setup.getModSettingValue("allow_bosses", "bool") &&
			this.World.getTime().Days >= this.m.EndofMidGameThreshold
	}

	function generateSpawnListBasedOnDay(_days = null, _diffScore = null) {
		local current_day = _days != null ? _days : this.World.getTime().Days;
		local init_difficulty_score = null;
		if (_diffScore != null) {
			init_difficulty_score = _diffScore;
		} else if (this.m.UsePresetSpawnList) {
			init_difficulty_score = this.m.PresetSpawnListScore;
		} else {
			init_difficulty_score = this.getDifficultyScore();
		}
		this.logDebug(debug_init + "Difficulty score " + init_difficulty_score + " on day " + current_day)

		local gauntlet_survived = this.approximateGauntletSurvivedFromDay(current_day)

		local troops = this.m.UsePresetSpawnList ?
			this.getTroopsArrayPreset() :
			this.getTroopsArrayBasedOnDay()

		local squishyLimit = ::ModGauntletEvents.Setup.getModSettingValue("squishy_limit", "float");
		local bossLimit = ::ModGauntletEvents.Setup.getModSettingValue("boss_limit", "float");

		local pool_manager = GauntletManager();
		pool_manager.init(troops, squishyLimit, bossLimit);

		local banner_unit =
			(	current_day >= this.m.EndofEarlyGameThreshold ||
				gauntlet_survived > 0 ||
				this.World.Assets.getCombatDifficulty() > 1
			) ? this.Const.World.Spawn.Troops.StandardBearer :
			this.Const.World.Spawn.Troops.MilitiaCaptain;

		local fieldable_bros = this.Math.min(this.World.getPlayerRoster().getAll().len(), this.World.Assets.m.BrothersMaxInCombat + 1);
		local min_troop_num = this.Math.min(fieldable_bros, this.Math.floor(current_day * 0.8));

		return pool_manager.generateSpawnList(
			init_difficulty_score,
			current_day,
			gauntlet_survived,
			banner_unit,
			min_troop_num
		)
	}

	function getBossSpawnList(_spawnlist) {
		if (_spawnlist == null) {
			::logError(debug_init + "INVALID SPAWNLIST")
			return {}
		}
		local boss_spawnlist = {
			Cost = 0,
			MovementSpeedMult = 1.0,
			VisibilityMult = 1.0,
			VisionMult = 1.0,
			Body = "figure_noble_01",
			Troops = []
		};

		boss_spawnlist.Troops = _spawnlist.Troops.filter(
			function(index, unit) {
				return "IsBoss" in unit && unit.IsBoss;
			}
		);

		_spawnlist.Troops = _spawnlist.Troops.filter(
			function(index, unit) {
				return !("IsBoss" in unit && unit.IsBoss);
			}
		);
		return boss_spawnlist
	}

	function preparePropertiesAndStartCombat(
		_days = null,
		_diffScore = null,
		_allowLooting = null
	) {
		local properties = this.World.State.getLocalCombatProperties(this.World.State.getPlayer().getPos());
		properties.CombatID = "Event";

		local music_arr = [];
		music_arr.extend(this.Const.Music.NobleTracks);
		music_arr.extend(this.Const.Music.BarbarianTracks);
		music_arr.extend(this.Const.Music.BanditTracks);
		music_arr.extend(this.Const.Music.UndeadTracks);
		music_arr.extend(this.Const.Music.OrientalCityStateTracks);
		music_arr.extend(this.Const.Music.OrcsTracks);
		music_arr.extend(this.Const.Music.GoblinsTracks);

		properties.Music = music_arr;
		properties.IsAutoAssigningBases = false;
		properties.Entities = [];
		properties.IsFleeingProhibited = true;
		properties.IsArenaMode = !( // note that we negate the inside expr
			_allowLooting != null ?
			_allowLooting : this.m.AllowLooting
		);
		properties.PlayerDeploymentType = this.Const.Tactical.DeploymentType.Line;
		properties.EnemyDeploymentType = this.Const.Tactical.DeploymentType.Line;
		properties.AllyBanners = [
			this.World.Assets.getBanner()
		];

		local spawnlist = this.generateSpawnListBasedOnDay(_days, _diffScore);
		local resource = spawnlist.Cost + 100;

		local champion_spawnlist = this.getBossSpawnList(spawnlist)
		local champion_spawnlist_arr = [];
		champion_spawnlist_arr.append(champion_spawnlist)

		this.Const.World.Common.addUnitsToCombat(properties.Entities, champion_spawnlist_arr, resource, this.Const.Faction.Enemy, 150)
		local spawnlist_arr = [];
		spawnlist_arr.append(spawnlist);

		this.Const.World.Common.addUnitsToCombat(properties.Entities, spawnlist_arr, resource, this.Const.Faction.Enemy, -150)
		this.logDebug(debug_init + "properties.Entities constructed. Prepare to fight!");

		this.World.Contracts.startScriptedCombat(properties, false, true, true);
		return 1;
	}

});