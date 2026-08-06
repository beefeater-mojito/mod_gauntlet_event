local debug_init = "GAUNTLET DEBUG: ";

local deepCopy;
deepCopy = function (container) {
	// Container must not have circular references
	switch (typeof container) {
		case "table":
			local result = clone container;
			foreach (k, v in container) result[k] = deepCopy(v);
			return result;
		case "array":
			local result = [];
			foreach (v in container) {
				result.append(deepCopy(v));
			}
			return result;
		default:
			return container;
	}
}

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

local GauntletPool = function () {
	return {
		name = "",
		pool = [],

		function init(name, outside_pool) {
			this.name = name
			this.pool = deepCopy(outside_pool)
			if (outside_pool.len() == 0) {
				return;
			}
			if (!("Weight" in this.pool[0])) {
				this.pool[0].Weight <- 1;
			}
			for (local i = 1; i < this.pool.len(); i++) {
				if (!("Weight" in this.pool[i])) {
					this.pool[i].Weight <- 1;
				}
				this.pool[i].Weight += this.pool[i - 1].Weight
			}
			::logDebug(debug_init + "Pool " + name + " is constructed! pool.len()=" + pool.len())
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
				// this.logDebug(debug_init + "0-1 Random roll r=" + r)
				r *= this.pool[this.pool.len() - 1].Weight; // last unit has total weight
				// this.logDebug(debug_init + "Unit roll r=" + r)
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
			return this.pool[idx];
		}

		function getUnits() {
			return this.pool;
		}
		function getPoolLen() {
			return this.pool.len()
		}
	}
}

local GauntletManager = function () {
	return {
		m = {
			Pool = null,
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

			SquishyLimit = 0.5,
			SquishyScore = 0,

			BossLimit = 0.5,
			BossScore = 0,
			BossMax = 1,
			BossTotal = 0

			Spawnlist = {
				Cost = 0,
				MovementSpeedMult = 1.0,
				VisibilityMult = 1.0,
				VisionMult = 1.0,
				Body = "figure_noble_01",
				Troops = []
			}
		}

		function init(_pool) {
			this.m.Pool = _pool;
			this.createRangePool();
			this.createCrowdControlPool();
			this.createBossPool();
		}

		function createFilteredArray(fun) {
			//return array
			local arr = [];
			// dumpCustom(this.m)
			foreach (i, _unit in this.m.Pool.getUnits()) {
				if (fun(_unit)) {
					local unit = deepCopy(_unit);
					unit.Weight -= i == 0 ? 0 : this.m.Pool.getUnitAtIdx(i - 1).Weight;
					arr.push(unit);
				}
			}
			return arr;
		}

		function createRangePool() {
			this.m.RangePool = GauntletPool();
			this.m.RangePool.init("range", this.createFilteredArray(@(u)"IsRange" in u));
		}

		function createCrowdControlPool() {
			this.m.CrowdControlPool = GauntletPool();
			this.m.CrowdControlPool.init("crowdcontrol", this.createFilteredArray(@(u)"IsCrowdControl" in u));
		}

		function createBossPool() {
			this.m.BossPool = GauntletPool();
			this.m.BossPool.init("boss", this.createFilteredArray(@(u)"IsBoss" in u))
		}

		function generateSpawnList(_difficultyScore, _currentDay, _survived, _bannerUnit = null, _bossMax = 0) {
			this.m.InitDifficulty = _difficultyScore;
			this.m.RemainingDifficulty = _difficultyScore;

			this.m.RangeMax = this.Math.rand(0, 2) - 1 + this.Math.min(2, _survived);
			this.m.CrowdControlMax = this.Math.rand(0, 3) - 2 + this.Math.min(2, this.Math.ceil(_survived * 1.0 / 2));
			this.m.BossMax = _bossMax

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
			if(this.m.BossMax > 0){
				::logDebug(debug_init+ "Picking bosses!")
				this.generateTroopsFromPool(this.m.BossPool);
			}
			if(this.m.RangeMax > 0){
				this.generateTroopsFromPool(this.m.RangePool);
			}
			if(this.m.CrowdControlMax > 0){
				this.generateTroopsFromPool(this.m.CrowdControlPool);
			}

			this.generateTroopsFromPool();

			if (_bannerUnit != null) {
				local num = this.Math.ceil(this.m.SpawnList.Troops.len() / 22.0);

				this.m.SpawnList.Troops.append({
					Type = _bannerUnit,
					Num = num
				});

				this.m.SpawnList.Cost += num * _bannerUnit.Cost;
			}

			return this.m.SpawnList;
		}

		function generateTroopsFromPool(_gauntlet_pool = null) {
			local gauntlet_pool = _gauntlet_pool;
			if (gauntlet_pool == null) {
				gauntlet_pool = this.m.Pool;
			}
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
		}

		function canAddUnit(_unit) {
			if (_unit.DifficultyRating > this.m.RemainingDifficulty) {
				return false;
			}

			local squishyLimit = this.m.InitDifficulty * this.m.SquishyLimit - _unit.DifficultyRating;

			if ("IsRange" in _unit) {
				if (this.m.RangeTotal >= this.m.RangeMax) {
					return false;
				}

				if (this.m.SquishyScore >= squishyLimit) {
					return false;
				}
			}

			if ("IsSquishyMelee" in _unit) {
				if (this.m.SquishyScore >= squishyLimit) {
					return false;
				}
			}

			if ("IsCrowdControl" in _unit) {
				if (this.m.CrowdControlTotal >= this.m.CrowdControlMax) {
					return false;
				}

				if (this.m.SquishyScore >= squishyLimit) {
					return false;
				}
			}

			if ("IsBoss" in _unit) {
				if (this.m.BossTotal >= this.m.BossMax) {
					return false;
				}
				local boss_limit = this.m.InitDifficulty * this.m.BossLimit - _unit.DifficultyRating
				if (this.m.BossScore >= boss_limit) {
					return false;
				}
			}

			return true;
		}

		function addUnit(_unit) {
			if ("IsRange" in _unit && _unit.IsRange) {
				this.m.RangeTotal++;
				this.m.SquishyScore += _unit.DifficultyRating;
			}

			if ("IsSquishyMelee" in _unit && _unit.IsSquishyMelee) {
				this.m.SquishyScore += _unit.DifficultyRating;
			}

			if ("IsCrowdControl" in _unit && _unit.IsCrowdControl) {
				this.m.CrowdControlTotal++;
				this.m.SquishyScore += _unit.DifficultyRating;
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

			this.m.SpawnList.Troops.append(member);

			this.m.SpawnList.Cost += _unit.Type.Cost;
			this.m.RemainingDifficulty -= _unit.DifficultyRating;

			this.addCoSpawn(_unit);
		}

		function addCoSpawn(_unit) {
			if (!("CoSpawn" in _unit)) {
				return;
			}

			foreach (co in _unit.CoSpawn) {
				local num = "Num" in co ? co.Num : 1;
				local member = {
					Type = co.Type,
					Num = num
				};
				if ("IsBoss" in _unit && _unit.IsBoss){
					member.IsBoss <- true;
				}
				this.m.SpawnList.Troops.append(member);

				this.m.SpawnList.Cost += co.Type.Cost;
			}
		}
	}
}

mod_gauntlet_events <- inherit("scripts/events/event", {
	m = {
		// msu setting variable
		BaseGauntletInterval = 10,
		EndofEarlyGameThreshold = 15,
		EndofMidGameThreshold = 35,
		MaxDifficultyScore = 90,
		MaxExpertDifficultyScoreOnDay = 120,

		AllowLooting = 1,
		DifficultyScoreModifier = 1,
		GauntletSurvived = 0,
		SuppliesNum = 0,
		SafeDaysUntilFirstGauntlet = 3
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
			Options = [
				{
					Text = "To battle!",
					function getResult(_event) {
						local properties = this.World.State.getLocalCombatProperties(this.World.State.getPlayer().getPos());
						properties.CombatID = "Event";
						local music_arr = [];
						music_arr.extend(this.Const.Music.NobleTracks)
						music_arr.extend(this.Const.Music.BarbarianTracks)
						music_arr.extend(this.Const.Music.BanditTracks)
						music_arr.extend(this.Const.Music.UndeadTracks)
						music_arr.extend(this.Const.Music.OrientalCityStateTracks)
						music_arr.extend(this.Const.Music.OrcsTracks)
						music_arr.extend(this.Const.Music.GoblinsTracks)
						properties.Music = music_arr;
						properties.IsAutoAssigningBases = false;
						properties.Entities = [];
						properties.IsFleeingProhibited = true;
						properties.IsArenaMode = !(_event.m.AllowLooting);
						properties.PlayerDeploymentType = this.Const.Tactical.DeploymentType.Line;
						properties.EnemyDeploymentType = this.Const.Tactical.DeploymentType.Line;
						properties.AllyBanners = [
							this.World.Assets.getBanner()
						];
						local spawnlist = _event.generateSpawnListBasedOnDay();
						local resource = spawnlist.Cost + 100;
						if (::ModGauntletEvents.Mod.ModSettings.getSetting("allow_champions")) {
							local boss_spawnlist = {
								Cost = 0,
								MovementSpeedMult = 1.0,
								VisibilityMult = 1.0,
								VisionMult = 1.0,
								Body = "figure_noble_01",
								Troops = []
							};
							foreach (i, troop in spawnlist.Troops) {
								if ("IsBoss" in troop && troop.IsBoss) {
									boss_spawnlist.Troops.append(troop)
									spawnlist.Troops.remove(i)
								}
							}
							local boss_spawnlist_arr = [];
							boss_spawnlist_arr.append(boss_spawnlist)
							this.Const.World.Common.addUnitsToCombat(properties.Entities, boss_spawnlist_arr, resource, this.Const.Faction.Enemy, 150)
						}
						local spawnlist_arr = [];
						spawnlist_arr.append(spawnlist);
						this.Const.World.Common.addUnitsToCombat(properties.Entities, spawnlist_arr, resource, this.Const.Faction.Enemy, -150)
						this.logDebug(debug_init + "properties.Entities constructed. Prepare to fight!");
						dumpCustom(properties);
						_event.registerToShowAfterCombat("Survived", "Survived");
						this.World.Contracts.startScriptedCombat(properties, false, true, true);
						return 1; // 1 so that processInput doesn't throw a fuss
					}
				}
			],

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
			Options = [
				{
					Text = "We survived... for now.",
					function getResult(_event) {
						return 0
					}
				}
			],

			function start(_event) {
				World.Statistics.getFlags().set("GauntletLastTriggeredOnDay", this.World.getTime().Days);
				World.Statistics.getFlags().set("GauntletSurvivedFlag", _event.m.GauntletSurvived + 1);
				World.Statistics.getFlags().set("HasGauntletInit", false);

				local ecoDiffMod = (this.World.Assets.getEconomicDifficulty() + 1) * 0.1
				local armorPartAmount = this.Math.ceil(_event.m.SuppliesNum * (1.5 - ecoDiffMod))
				local medicineAmount = this.Math.ceil(_event.m.SuppliesNum * (0.75 - ecoDiffMod))
				local ammoAmount = this.Math.ceil(_event.m.SuppliesNum * (2 - ecoDiffMod))

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
		this.m.BaseGauntletInterval = ::ModGauntletEvents.Mod.ModSettings.getSetting("base_gauntlet_interval").getValue().tointeger();
		this.m.MaxDifficultyScore = ::ModGauntletEvents.Mod.ModSettings.getSetting("max_difficulty_score").getValue().tointeger();
		this.m.MaxExpertDifficultyScoreOnDay = ::ModGauntletEvents.Mod.ModSettings.getSetting("max_score_on_day").getValue().tointeger();
		this.m.EndofEarlyGameThreshold = ::ModGauntletEvents.Mod.ModSettings.getSetting("early_end_on_day").getValue().tointeger();
		this.m.EndofMidGameThreshold = ::ModGauntletEvents.Mod.ModSettings.getSetting("mid_end_on_day").getValue().tointeger();
		this.m.SafeDaysUntilFirstGauntlet = ::ModGauntletEvents.Mod.ModSettings.getSetting("safe_day_until_1st_gauntlet").getValue().tointeger();

		switch (this.World.Assets.getCombatDifficulty()) {
			case 0:
				this.m.DifficultyScoreModifier = 1.2;
				break;
			case 1:
				this.m.DifficultyScoreModifier = 1.35;
				break;
			case 2:
				this.m.DifficultyScoreModifier = 1.5;
				break;
		}
		if (!(World.Statistics.getFlags().get("GauntletSurvivedFlag"))) {
			World.Statistics.getFlags().set("GauntletSurvivedFlag", 0);
		}
		this.m.GauntletSurvived = World.Statistics.getFlags().getAsInt("GauntletSurvivedFlag")
		// ::logDebug(debug_init + "getEconomicDifficulty()=" + this.World.Assets.getEconomicDifficulty())
		if (::ModGauntletEvents.Mod.ModSettings.getSetting("always_allow_looting").getValue()) {
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

		this.m.SuppliesNum = this.calculateTotalDifficultyScore();
	}

	function onPrepareVariables(_vars) {}

	function onClear() {
		// this.m.Score = -20;
	}

	function isValid() {

		local current_day = this.World.getTime().Days;
		if (!(World.Statistics.getFlags().get("GauntletLastTriggeredOnDay"))) {
			World.Statistics.getFlags().set("GauntletLastTriggeredOnDay", 0);
		}
		local last_triggered_on_day = this.World.Statistics.getFlags().getAsInt("GauntletLastTriggeredOnDay");

		local safe_days = ::ModGauntletEvents.Mod.ModSettings.getSetting("safe_day_until_1st_gauntlet").getValue().tointeger();
		local interval = ::ModGauntletEvents.Mod.ModSettings.getSetting("base_gauntlet_interval").getValue().tointeger();

		if (current_day < safe_days) {
			return false;
		}
		if (current_day - last_triggered_on_day < interval) {
			return false;
		}
		return true;
	}

	function generateSuppliesFromNum(_num) {
		local ecoDiffMod = this.World.Assets.getEconomicDifficulty() * 0.1
		local armorParts = this.new("scripts/items/supplies/armor_parts_item");
		armorParts.setAmount(this.Math.ceil(_num * (1.5 - ecoDiffMod)));
		local medicine = this.new("scripts/items/supplies/medicine_item");
		medicine.setAmount(this.Math.ceil(_num * (0.75 - ecoDiffMod)));
		local ammo = this.new("scripts/items/supplies/ammo_item");
		ammo.setAmount(this.Math.ceil(_num * (2 - ecoDiffMod)));
		local loot = []
		loot.push(armorParts);
		loot.push(medicine);
		loot.push(ammo);
		return loot;
	}

	function approximateGauntletSurvivedFromDay(days) {
		return this.Math.floor((days - 1) * 1.0 / this.m.BaseGauntletInterval)
	}

	function calculateTotalDifficultyScore() {
		local current_day = this.World.getTime().Days
		if (current_day < this.m.EndofEarlyGameThreshold) {
			return this.Math.ceil(current_day * this.m.DifficultyScoreModifier);
		}
		local d0 = this.m.EndofEarlyGameThreshold;
		local s0 = d0 * this.m.DifficultyScoreModifier;
		if (current_day < this.m.EndofMidGameThreshold) {
			return this.Math.ceil(s0 + (current_day - d0) * this.m.DifficultyScoreModifier / 2);
		}

		local diffMult = 1;
		switch (this.World.Assets.getCombatDifficulty()) {
			case 0:
				diffMult = 1.2;
				break;
			case 1:
				diffMult = 1.1;
				break;
			case 2:
				diffMult = 1;
				break;
		}

		local d1 = this.m.EndofMidGameThreshold;
		local d2 = this.m.MaxExpertDifficultyScoreOnDay;
		local s1 = this.Math.ceil(s0 + (d1 - d0) * this.m.DifficultyScoreModifier / 2.5);
		local s2 = this.m.MaxDifficultyScore;
		// ::logDebug("d1="+d1+" d2="+d2+" s1="+s1+" s2="+s2)

		local k = log(s2 / s1) / (-d2 + d1)
		local C = s1 / (diffMult * exp(-k * d1))

		return this.Math.min(this.Math.ceil(C * exp(-k * current_day)), s2);
	}

	function getGauntletPoolBasedOnDay() {
		local current_days = this.World.getTime().Days;
		// TODO: implement logic handle for different gauntlet pool

		if (current_days < this.m.EndofEarlyGameThreshold) {
			return this.Const.World.Spawn.GauntletEarly[0].Pool;
		}

		if (current_days < this.m.EndofMidGameThreshold){
			return this.Const.World.Spawn.GauntletMid[0].Pool
		}
		return this.Const.World.Spawn.GauntletLate[0].Pool;
	}

	function generateSpawnListBasedOnDay(_days = null, _diffScore = null) {
		local current_day = _days != null ? _days : this.World.getTime().Days;
		local init_difficulty_score = _diffScore != null
			? _diffScore
			: this.calculateTotalDifficultyScore();
		::logDebug(debug_init + "Difficulty score " + init_difficulty_score + " on day " + current_day)

		local gauntlet_survived = this.approximateGauntletSurvivedFromDay(current_day)

		local pool = GauntletPool();
		pool.init("pool", this.getGauntletPoolBasedOnDay())

		local boss_max = 0;
		if (::ModGauntletEvents.Mod.ModSettings.getSetting("allow_champions") && current_day >= this.m.EndofMidGameThreshold) {
			local boss_pool = this.Const.World.Spawn.GauntletBoss[0].Pool;
			foreach (boss in boss_pool) {
				boss.IsBoss <- true;
				pool.pushUnit(boss);
			}
			boss_max = this.Math.rand(0, 3) + this.Math.rand(0, this.Math.min(3, this.Math.floor(gauntlet_survived*1.0/2)));
		}

		local pool_manager = GauntletManager();
		pool_manager.init(pool)

		local banner_unit = (current_day >= this.m.EndofEarlyGameThreshold
			|| gauntlet_survived > 0)
			? this.Const.World.Spawn.Troops.StandardBearer
			: this.Const.World.Spawn.Troops.MilitiaCaptain;

		return pool_manager.generateSpawnList(init_difficulty_score, current_day, gauntlet_survived, banner_unit, boss_max)

	}

	function generateSpawnListDebug() {
		local current_day = this.World.getTime().Days;
		local init_difficulty_score = 10;

		::logDebug(debug_init + "TEST FIGHT: Difficulty score " + init_difficulty_score + " on day " + current_day)

		local debug_pool = [
			{
				Type = this.Const.World.Spawn.Troops.ZombieYeoman,
				DifficultyRating = 1
			},
			{
				Type = this.Const.World.Spawn.Troops.ZombieKnight,
				DifficultyRating = 2
			},
			{
				Type = this.Const.World.Spawn.Troops.Necromancer,
				DifficultyRating = 4,
				IsSquishyMelee = true,
				Weight = 3
			}
		]

		local pool = GauntletPool();
		pool.init("pool", debug_pool)

		local pool_manager = GauntletManager();
		pool_manager.init(pool)

		local gauntlet_survived = this.approximateGauntletSurvivedFromDay(current_day)
		local banner_unit = (current_day >= this.m.EndofEarlyGameThreshold
			|| gauntlet_survived > 0)
			? this.Const.World.Spawn.Troops.StandardBearer
			: this.Const.World.Spawn.Troops.MilitiaCaptain;

		return pool_manager.generateSpawnList(init_difficulty_score, current_day, gauntlet_survived, banner_unit)
	}

});
