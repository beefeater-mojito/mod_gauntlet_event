local debug_init = "GAUNTLET HOOK DEBUG: ";

::mods_hookBaseClass("scenarios/world/starting_scenario", function (ss) {
	local onSpawnAssets = ::mods_getMember(ss, "onSpawnAssets");
	local onInit = ::mods_getMember(ss, "onInit");

	::mods_override(ss, "onSpawnAssets", function () {
		onSpawnAssets();

		World.Statistics.getFlags().set("GauntletEnabled", 0);
		World.Statistics.getFlags().set("GauntletLastTriggeredOnDay", 0);
		World.Statistics.getFlags().set("GauntletSurvivedFlag", 0);
		World.Statistics.getFlags().set("GauntletEarly", 0)
		World.Statistics.getFlags().set("GauntletMid", 0)
		World.Statistics.getFlags().set("GauntletLate", 0)
	});
	::mods_override(ss, "onInit", function () {
		onInit();

		if (!(World.Statistics.getFlags().get("GauntletEnabled"))) {
			local mundaneEvents = this.IO.enumerateFiles("scripts/events/special");
			foreach (i, event in mundaneEvents) {
				local instantiatedEvent = this.new(event);
				World.Events.m.Events.push(instantiatedEvent);
			};
		}
		World.Statistics.getFlags().set("GauntletEnabled", true);

		World.Events.addSpecialEvent("event.mod_gauntlet_events");
		::logDebug("Gauntlet event added!");

	})
})

// Disable ai retreat on the gauntlet fight
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
	q.generateCorpse = @(__original) function (_tile, _fatalityType, _killer) {
		local corpse = __original(_tile, _fatalityType, _killer);
		if (World.Statistics.getFlags().get("HasGauntletInit")) {
			::logDebug(debug_init + "CHECKING SPAWN CORPSE!")
			if (corpse.Faction == this.Const.Faction.Player) {
				::logDebug(debug_init + "MAKE PLAYER'S CORPSE NON-RESURRECTABLE IN GAUNTLET MODE!")
				corpse.IsResurrectable = false;
			}
		}
		return corpse
	}
});

local getWeaponsListBasedOnType = function (_type, canEquipTwoHander = false) {
	local weapons = [];
	local two_handed_weapons = [];
	switch (_type) {
		case ::Const.EntityType.Zombie:
		case ::Const.EntityType.ZombieYeoman:
		case ::Const.EntityType.SkeletonLight:
		case ::Const.EntityType.SkeletonMedium:
			weapons = [
				"weapons/falchion",
				"weapons/hand_axe",
				"weapons/scramasax",
				"weapons/boar_spear",
				"weapons/military_pick",
				"weapons/morning_star",
				"weapons/flail",
				"weapons/barbarians/crude_axe",
				"weapons/barbarians/axehammer",
				"weapons/barbarians/blunt_cleaver",
				"weapons/ancient/ancient_sword",
				"weapons/oriental/light_southern_mace",
			];
			two_handed_weapons = [
				"weapons/warbrand",
				"weapons/hooked_blade",
				"weapons/pike",
				"weapons/two_handed_wooden_flail",
				"weapons/two_handed_mace",
				"weapons/two_handed_wooden_hammer",
				"weapons/longsword",
				"weapons/ancient/bladed_pike",
				"weapons/oriental/two_handed_saif",
			]
			break;


		default:
			weapons = [
				"weapons/arming_sword",
				"weapons/fighting_axe",
				"weapons/military_cleaver",
				"weapons/fighting_spear",
				"weapons/warhammer",
				"weapons/winged_mace",
				"weapons/ancient/khopesh",
				"weapons/oriental/heavy_southern_mace",
			]
			two_handed_weapons = [
				"weapons/billhook",
				"weapons/two_handed_flail",
				"weapons/two_handed_flanged_mace",
				"weapons/two_handed_hammer",
				"weapons/greatsword",
				"weapons/greataxe",
				"weapons/exesword",
				"weapons/poleaxe",
				"weapons/barbarians/heavy_rusty_axe",
				"weapons/barbarians/rusty_warblade",
				"weapons/ancient/crypt_cleaver",
				"weapons/ancient/warscythe",
				"weapons/oriental/two_handed_scimitar",
				"weapons/oriental/polemace",
				"weapons/oriental/swordlance"
			]
			break;
	}
	if (canEquipTwoHander) {
		weapons.extend(two_handed_weapons)
	}
	return weapons
}

local getShieldListBasedOnType = function (_type){
	local shields = [];
	switch(_type){
		case ::Const.EntityType.Zombie:
		case ::Const.EntityType.SkeletonLight:
			shields = [
				"shields/wooden_shield",
				"shields/wooden_shield_old",
				"shields/ancient/auxiliary_shield"
			]

		default:
			shields = [
				"shields/worn_heater_shield",
				"shields/heater_shield",
				"shields/ancient/tower_shield"
			]
			break;
	}
	return shields
}

local equipUnarmedGears = function () {
	if (this.getItems().getItemAtSlot(::Const.ItemSlot.Mainhand) == null) {
		::logDebug(debug_init + "EQUIPPING THE UNARMED NEW EQUIPMENTs")
		local weapons = getWeaponsListBasedOnType(this.getType(), this.getItems().getItemAtSlot(::Const.ItemSlot.Offhand) == null)

		local new_weapon = this.new("scripts/items/" + weapons[this.Math.rand(0, weapons.len() - 1)]);
		new_weapon.m.IsDroppedAsLoot = false;
		this.getItems().equip(new_weapon);

		if (this.getItems().getItemAtSlot(::Const.ItemSlot.Offhand) == null
			&& this.Math.rand(1, 100) <= 50)
		{
			local shields = getShieldListBasedOnType(this.getType())
			local new_shield = this.new("scripts/items/" + shields[this.Math.rand(0, shields.len() - 1)]);
			new_shield.m.IsDroppedAsLoot = false;
			this.getItems().equip(new_shield);
		}
	}
}

// Give resurrected zombie equipment, similar to raise undead all
::ModGauntletEvents.MH.hookTree("scripts/entity/tactical/enemies/zombie", function (q) {
	q.onResurrected = @(__original) function (_info) {
		__original(_info);
		if (World.Statistics.getFlags().get("HasGauntletInit")) {
			::logDebug(debug_init + "CHECKING RESURRECTED ZOMBIES!")
			equipUnarmedGears()
		}
	}
})

::ModGauntletEvents.MH.hookTree("scripts/entity/tactical/skeleton", function (q) {
	q.onResurrected = @(__original) function (_info) {
		__original(_info);
		if (World.Statistics.getFlags().get("HasGauntletInit")) {
			::logDebug(debug_init + "CHECKING RESURRECTED SKELLIES!")
			equipUnarmedGears()
		}
	}
})