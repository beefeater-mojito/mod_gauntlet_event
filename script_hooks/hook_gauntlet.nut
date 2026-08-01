::mods_hookBaseClass("scenarios/world/starting_scenario", function(ss) {
	local onSpawnAssets = ::mods_getMember(ss, "onSpawnAssets");
	local onInit = ::mods_getMember(ss, "onInit");

	::mods_override(ss, "onSpawnAssets", function() {
		onSpawnAssets();

		World.Statistics.getFlags().set("GauntletEnabled", 0);
		World.Statistics.getFlags().set("GauntletLastTriggeredOnDay", 0);
		World.Statistics.getFlags().set("GauntletSurvivedFlag", 0);
		World.Statistics.getFlags().set("GauntletEarly", 0)
		World.Statistics.getFlags().set("GauntletMid", 0)
		World.Statistics.getFlags().set("GauntletLate", 0)
	});
	::mods_override(ss, "onInit", function() {
		onInit();

		if (!(World.Statistics.getFlags().get("GauntletEnabled"))) {
			local mundaneEvents = IO.enumerateFiles("scripts/events/special");
			foreach ( i, event in mundaneEvents ) {
				local instantiatedEvent = new(event);
				World.Events.m.Events.push(instantiatedEvent);
			};
		}
		World.Statistics.getFlags().set("GauntletEnabled", true);

		World.Events.addSpecialEvent("event.mod_gauntlet_events");
		::logDebug("Gauntlet event added!")

	})
})