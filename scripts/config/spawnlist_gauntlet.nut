local gt = this.getroottable();

if (!("World" in gt.Const)) {
	gt.Const.World <- {};
}

if (!("Spawn" in gt.Const.World)) {
	gt.Const.World.Spawn <- {};
}
// About pool creation, ensure every pool has a melee unit with a DR of 1.
// This unit should also not have any special flag.
// DR value should be positive integer, but technically float can work too
gt.Const.World.Spawn.GauntletEarly <- [
	{
		Cost = 0,
		MovementSpeedMult = 1.0,
		VisibilityMult = 1.0,
		VisionMult = 1.0,
		Body = "figure_bandit_01",
		Troops = [
			{
				Type = this.Const.World.Spawn.Troops.Wardog,
				Num = 3
			}
		],
		// gauntlet data
		Name = "GauntletEarly",
		DayStartpoint = 0,
		DayEndpoint = 15,
		Pool = [
			{
				UnitKey = "Footman",
				DifficultyRating = 2,
				Weight = 3
			},
			{
				UnitKey = "Billman",
				DifficultyRating = 2,
				Weight = 3,
				IsSquishyMelee = true
			},
			{
				UnitKey = "Arbalester",
				DifficultyRating = 3,
				IsRange = true,
				CoSpawn = [
					{
						UnitKey = "ArmoredWardog"
					}
				]
			},
			{
				UnitKey = "ManAtArms",
				DifficultyRating = 3
			},
			// gilded
			{
				UnitKey = "Conscript",
				DifficultyRating = 2,
				Weight = 2
			},
			{
				UnitKey = "ConscriptPolearm",
				DifficultyRating = 3,
				Weight = 2,
				CoSpawn = [
					{
						UnitKey = "CaravanGuard"
					}
				]
			},
			// brigand
			{
				UnitKey = "BanditRaider",
				DifficultyRating = 1,
				IsSquishyMelee = true,
				Weight = 4
			},
			{
				UnitKey = "BanditMarksman",
				DifficultyRating = 2,
				IsRange = true,
				Weight = 2,
				CoSpawn = [
					{
						UnitKey = "Wardog"
					}
				]
			},
			{
				UnitKey = "BanditLeader",
				DifficultyRating = 3,
				CoSpawn = [
					{
						UnitKey = "ArmoredWardog"
					}
				]
			},
			// nomad
			{
				UnitKey = "NomadOutlaw",
				DifficultyRating = 1,
				Weight = 3
			},
			{
				UnitKey = "NomadArcher",
				DifficultyRating = 1,
				IsRange = true,
				Weight = 2
			},
			{
				UnitKey = "NomadLeader",
				DifficultyRating = 3
			},
			// barb
			{
				UnitKey = "BarbarianMarauder",
				Num = 2,
				DifficultyRating = 3,
				Weight = 3
			},
			// orc
			{
				UnitKey = "OrcYoung",
				DifficultyRating = 1,
				IsSquishyMelee = true,
				Weight = 2
			},
			{
				UnitKey = "OrcBerserker",
				DifficultyRating = 3,
				IsSquishyMelee = true,
				Weight = 2
			},
			{
				UnitKey = "OrcWarriorLOW",
				DifficultyRating = 4
			},
			// gobbo
			{
				UnitKey = "GoblinSkirmisher",
				DifficultyRating = 1,
				IsSquishyMelee = true
			},
			{
				UnitKey = "GoblinAmbusher",
				DifficultyRating = 2,
				IsRange = true
			},
			{
				UnitKey = "GoblinWolfrider",
				DifficultyRating = 2,
				IsSquishyMelee = true
			},
			// beast
			{
				UnitKey = "Ghoul",
				DifficultyRating = 1,
				IsSquishyMelee = true
			},
			{
				UnitKey = "Serpent",
				DifficultyRating = 1,
				IsSquishyMelee = true
			},
			// undead
			{
				UnitKey = "ZombieNomad",
				DifficultyRating = 1,
				Weight = 2,
				CoSpawn = [
					{UnitKey = "Warhound"}
				]
			},
			{
				UnitKey = "ZombieKnight",
				DifficultyRating = 3,
				CoSpawn = [
					{
						UnitKey = "Warhound"
					}
				]
			},
			{
				UnitKey = "Ghost",
				DifficultyRating = 6,
				IsCrowdControl = true,
				CoSpawn = [
					{
						UnitKey = "ZombieNomad",
						Num = 1
					},
					{
						UnitKey = "ZombieYeomanBodyguard",
						Num = 1
					},
					{
						UnitKey = "ArmoredWardog",
						Num = 2
					}
				]
			},
			{
				UnitKey = "Necromancer",
				DifficultyRating = 11,
				IsCrowdControl = true,
				CoSpawn = [
					{
						UnitKey = "ZombieYeomanBodyguard",
						Num = 2
					},
					{
						UnitKey = "ZombieNomad",
						Num = 2
					}
				]
			},
			{
				UnitKey = "SkeletonMedium",
				DifficultyRating = 3,
				Weight = 2
			},
			{
				UnitKey = "SkeletonMediumPolearm",
				DifficultyRating = 3,
				Weight = 2
			}
		]
	}
]

gt.Const.World.Spawn.GauntletMid <- [
	{
		Cost = 0,
		MovementSpeedMult = 1.0,
		VisibilityMult = 1.0,
		VisionMult = 1.0,
		Body = "figure_bandit_01",
		Troops = [
			{
				Type = this.Const.World.Spawn.Troops.Wardog,
				Num = 4
			}
		],
		Name = "GauntletMid",
		DayStartpoint = 15,
		DayEndpoint = 35,
		Pool = [
			// noble
			{
				UnitKey = "Footman",
				Num = 2,
				DifficultyRating = 3,
				Weight = 4
			},
			{
				UnitKey = "Billman",
				DifficultyRating = 1,
				Weight = 4,
				IsSquishyMelee = true
			},
			{
				UnitKey = "Arbalester",
				DifficultyRating = 2,
				IsRange = true,
				CoSpawn = [
					{
						UnitKey = "ArmoredWardog"
					}
				]
			},
			{
				UnitKey = "ManAtArms",
				DifficultyRating = 2,
				Weight = 3
			},
			{
				UnitKey = "Sergeant",
				DifficultyRating = 3,
				Weight = 2,
				CoSpawn = [
					{
						UnitKey = "ArmoredWardog"
					}
				]
			},
			{
				UnitKey = "Greatsword",
				DifficultyRating = 3,
				Weight = 3,
				IsSquishyMelee = true
			},
			// gilded
			{
				UnitKey = "Conscript",
				DifficultyRating = 2,
				Weight = 4
			},
			{
				UnitKey = "ConscriptPolearm",
				DifficultyRating = 2,
				Weight = 4
			},
			{
				UnitKey = "Gunner",
				DifficultyRating = 3,
				Weight = 3,
				IsSquishyMelee = true
			},
			{
				UnitKey = "Officer",
				DifficultyRating = 4
			},
			{
				UnitKey = "Assassin",
				DifficultyRating = 4
			},
			{
				UnitKey = "Mortar",
				DifficultyRating = 12,
				IsCrowdControl = true,
				CoSpawn = [
					{
						UnitKey = "Engineer",
						Num = 2
					},
					{
						UnitKey = "Officer",
						Num = 1
					}
				]
			},
			// brigand
			{
				UnitKey = "BanditMarauder",
				DifficultyRating = 3,
				Weight = 2
			},
			{
				UnitKey = "BountyHunter",
				DifficultyRating = 3,
				Weight = 2
			},
			{
				UnitKey = "BountyHunterRanged",
				DifficultyRating = 3,
				IsRange = true
			},
			// nomad + glads
			{
				UnitKey = "NomadLeader",
				DifficultyRating = 3
			},
			{
				UnitKey = "Gladiator",
				DifficultyRating = 6
			},
			// barb
			{
				UnitKey = "BarbarianMarauder",
				DifficultyRating = 1,
				Weight = 2
			},
			{
				UnitKey = "BarbarianChampion",
				DifficultyRating = 4,
				Weight = 2
			},
			{
				UnitKey = "BarbarianUnhold",
				DifficultyRating = 7,
				CoSpawn = [
					{
						UnitKey = "BarbarianBeastmaster"
					}
				]
			},
			// orc
			{
				UnitKey = "OrcBerserker",
				DifficultyRating = 2,
				Weight = 3,
				IsSquishyMelee = true,
			},
			{
				UnitKey = "OrcWarrior",
				DifficultyRating = 4,
				Weight = 3
			},
			{
				UnitKey = "OrcWarlord",
				DifficultyRating = 7
			},
			// gobbo
			{
				UnitKey = "GoblinAmbusher",
				DifficultyRating = 2,
				IsRange = true
			},
			{
				UnitKey = "GoblinWolfrider",
				DifficultyRating = 1,
				IsSquishyMelee = true
			},
			{
				UnitKey = "GoblinOverseer",
				DifficultyRating = 5,
				IsRange = true
			},
			// beast
			{
				UnitKey = "GhoulHIGH",
				DifficultyRating = 2,
				IsSquishyMelee = true
			},
			{
				UnitKey = "Unhold",
				DifficultyRating = 6,
				Weight = 2
			},
			{
				UnitKey = "UnholdFrost",
				DifficultyRating = 8,
				Weight = 2
			},
			// undead: zombie
			{
				UnitKey = "ZombieKnight",
				DifficultyRating = 2,
				Weight = 3,
				CoSpawn = [
					{
						UnitKey = "Warhound"
					}
				]
			},
			{
				UnitKey = "Ghost",
				DifficultyRating = 7,
				IsCrowdControl = true,
				CoSpawn = [
					{
						UnitKey = "ZombieKnight",
						Num = 1
					},
					{
						UnitKey = "ZombieNomad",
						Num = 2
					}
				]
			},
			{
				UnitKey = "Necromancer",
				DifficultyRating = 15,
				IsCrowdControl = true,
				CoSpawn = [
					{
						UnitKey = "ZombieKnightBodyguard"
					},
					{
						UnitKey = "ZombieYeomanBodyguard"
					},
					{
						UnitKey = "ZombieKnight"
					}
				]
			},
			// undead: skellies
			{
				UnitKey = "SkeletonMedium",
				DifficultyRating = 2,
				Weight = 4
			},
			{
				UnitKey = "SkeletonMediumPolearm",
				DifficultyRating = 2,
				Weight = 4,
				IsSquishyMelee = true
			},
			{
				UnitKey = "VampireLOW",
				DifficultyRating = 5,
				IsSquishyMelee = true
				CoSpawn = [
					{
						UnitKey = "SkeletonLight"
					}
				]
			},
			{
				UnitKey = "SkeletonHeavy",
				DifficultyRating = 4,
				Weight = 2
			},
			{
				UnitKey = "SkeletonHeavyPolearm",
				DifficultyRating = 4,
				Weight = 2
			},
			{
				UnitKey = "SkeletonPriest",
				DifficultyRating = 13,
				IsCrowdControl = true,
				CoSpawn = [
					{
						UnitKey = "SkeletonHeavyBodyguard",
						Num = 1
					}
				]
			},
			// undead: golem
			{
				UnitKey = "LesserFleshGolem",
				DifficultyRating = 4
			}
		]
	}
]

gt.Const.World.Spawn.GauntletLate <- [
	{
		Cost = 0,
		MovementSpeedMult = 1.0,
		VisibilityMult = 1.0,
		VisionMult = 1.0,
		Body = "figure_bandit_01",
		Troops = [
			{
				Type = this.Const.World.Spawn.Troops.Wardog,
				Num = 5
			}
		],
		GauntletName = "GauntletLate",
		DayStartpoint = 35,
		DayEndpoint = null,
		Pool = [
			// noble
			{
				UnitKey = "Footman",
				DifficultyRating = 3,
				Num = 2,
				Weight = 3
			},
			{
				UnitKey = "Billman",
				DifficultyRating = 1,
				Weight = 2,
				IsSquishyMelee = true
			},
			{
				UnitKey = "Arbalester",
				DifficultyRating = 2,
				IsRange = true,
				CoSpawn = [
					{
						UnitKey = "ArmoredWardog"
					}
				]
			},
			{
				UnitKey = "ManAtArms",
				DifficultyRating = 2,
				Weight = 3
			},
			{
				UnitKey = "Sergeant",
				DifficultyRating = 2,
				Weight = 2,
				CoSpawn = [
					{
						UnitKey = "ArmoredWardog"
					}
				]
			},
			{
				UnitKey = "Greatsword",
				DifficultyRating = 2,
				Weight = 2,
				IsSquishyMelee = true
			},
			{
				UnitKey = "Knight",
				DifficultyRating = 5
			},
			// gilded
			{
				UnitKey = "Conscript",
				Num = 2,
				DifficultyRating = 3,
				Weight = 3
			},
			{
				UnitKey = "ConscriptPolearm",
				DifficultyRating = 2,
				Weight = 3,
				IsSquishyMelee = true
			},
			{
				UnitKey = "Gunner",
				DifficultyRating = 3,
				Weight = 2,
				IsSquishyMelee = true
			},
			{
				UnitKey = "Officer",
				DifficultyRating = 4,
				Weight = 2
			},
			{
				UnitKey = "Assassin",
				DifficultyRating = 4,
				Weight = 2
			},
			{
				UnitKey = "Mortar",
				DifficultyRating = 11,
				IsCrowdControl = true,
				CoSpawn = [
					{
						UnitKey = "Engineer",
						Num = 2
					},
					{
						UnitKey = "Officer",
						Num = 1
					}
				]
			},
			// brigand + merc
			{
				UnitKey = "BanditMarauder",
				DifficultyRating = 3,
				Weight = 3
			},
			{
				UnitKey = "BountyHunter",
				DifficultyRating = 3,
				Weight = 2
			},
			{
				UnitKey = "BountyHunterRanged",
				DifficultyRating = 3,
				IsRange = true
			},
			{
				UnitKey = "HedgeKnight",
				DifficultyRating = 6
			},
			{
				UnitKey = "Oathbringer",
				DifficultyRating = 7
			},
			// nomad + glads
			{
				UnitKey = "Executioner",
				DifficultyRating = 8
			},
			{
				UnitKey = "Gladiator",
				DifficultyRating = 6
			},
			// barb
			{
				UnitKey = "BarbarianChampion",
				DifficultyRating = 4,
				Weight = 3
			},
			{
				UnitKey = "BarbarianUnhold",
				DifficultyRating = 6,
				Weight = 2,
				CoSpawn = [
					{
						UnitKey = "BarbarianBeastmaster"
					}
				]
			},
			{
				UnitKey = "BarbarianUnholdFrost",
				DifficultyRating = 9,
				Weight = 2,
				CoSpawn = [
					{
						UnitKey = "BarbarianBeastmaster"
					}
				]
			},
			{
				UnitKey = "BarbarianChosen",
				DifficultyRating = 6
			},
			// orc
			{
				UnitKey = "OrcBerserker",
				DifficultyRating = 2,
				Weight = 2,
				IsSquishyMelee = true
			},
			{
				UnitKey = "OrcWarrior",
				DifficultyRating = 4,
				Weight = 3
			},
			{
				UnitKey = "OrcWarlord",
				DifficultyRating = 6
			},
			// gobbo
			{
				UnitKey = "GoblinOverseer",
				DifficultyRating = 4,
				IsRange = true
			},
			// beast
			{
				UnitKey = "UnholdFrost",
				DifficultyRating = 7,
				Weight = 2
			},
			// undead: zombie
			{
				UnitKey = "ZombieKnight",
				DifficultyRating = 2,
				Weight = 2,
				CoSpawn = [
					{
						UnitKey = "ZombieNomad"
					}
				]
			},
			{
				UnitKey = "Ghost",
				DifficultyRating = 6,
				IsCrowdControl = true,
				CoSpawn = [
					{
						UnitKey = "ZombieKnight",
						Num = 4
					}
				]
			},
			{
				UnitKey = "Necromancer",
				DifficultyRating = 17,
				IsCrowdControl = true,
				CoSpawn = [
					{
						UnitKey = "ZombieKnightBodyguard",
						Num = 2
					},
					{
						UnitKey = "ZombieKnight",
						Num = 2
					}
				]
			},
			// undead: skellies
			{
				UnitKey = "SkeletonMedium",
				Num = 2,
				DifficultyRating = 3,
				Weight = 3
			},
			{
				UnitKey = "SkeletonMediumPolearm",
				Num = 2,
				DifficultyRating = 3,
				Weight = 3,
				IsSquishyMelee = true
			},
			{
				UnitKey = "Vampire",
				DifficultyRating = 5,
				IsSquishyMelee = true
			},
			{
				UnitKey = "SkeletonHeavy",
				DifficultyRating = 3,
				Weight = 2
			},
			{
				UnitKey = "SkeletonHeavyPolearm",
				DifficultyRating = 3,
				Weight = 2,
				IsSquishyMelee = true
			},
			{
				UnitKey = "SkeletonPriest",
				DifficultyRating = 13,
				IsCrowdControl = true,
				CoSpawn = [
					{
						UnitKey = "SkeletonHeavyBodyguard",
						Num = 2
					}
				]
			},
			//undead: golem
			{
				UnitKey = "GreaterFleshGolem",
				DifficultyRating = 8
			}
		]
	}
]

gt.Const.World.Spawn.GauntletChampion <- [
	{
		Cost = 0,
		MovementSpeedMult = 1.0,
		VisibilityMult = 1.0,
		VisionMult = 1.0,
		Body = "figure_bandit_01",
		Troops = [
			{
				Type = this.Const.World.Spawn.Troops.Wardog,
				Num = 6
			}
		],
		GauntletName = "GauntletChampion",
		ForceFlags = ["IsBoss"],
		Pool = [
			{
				UnitKey = "ZombieKnight",
				DifficultyRating = 4
			},
			{
				UnitKey = "BanditLeader",
				DifficultyRating = 5
			},
			{
				UnitKey = "NomadLeader",
				DifficultyRating = 6
			},
			{
				UnitKey = "SkeletonHeavy",
				DifficultyRating = 6
			},
			{
				UnitKey = "OrcWarrior",
				DifficultyRating = 7
			},
			{
				UnitKey = "BarbarianChampion",
				DifficultyRating = 7
			},
			{
				UnitKey = "Officer",
				DifficultyRating = 8
			},
			{
				UnitKey = "BarbarianChosen",
				DifficultyRating = 8
			},
			{
				UnitKey = "OrcWarlord",
				DifficultyRating = 8
			},
			{
				UnitKey = "Knight",
				DifficultyRating = 9
			},
			{
				UnitKey = "HedgeKnight",
				DifficultyRating = 10
			},
			{
				UnitKey = "Gladiator",
				DifficultyRating = 10
			},
			{
				UnitKey = "Oathbringer",
				DifficultyRating = 11
			},
			{
				UnitKey = "Executioner",
				DifficultyRating = 12
			},
		]
	}
]

gt.Const.World.Spawn.GauntletMiniBoss <- [
	{
		Cost = 0,
		MovementSpeedMult = 1.0,
		VisibilityMult = 1.0,
		VisionMult = 1.0,
		Body = "figure_bandit_01",
		Troops = [
			{
				Type = this.Const.World.Spawn.Troops.Wardog,
				Num = 7
			}
		],
		GauntletName = "GauntletMiniBoss",
		Pool = [
			{
				UnitKey = "Swordmaster",
				DifficultyRating = 25
			},
			{
				UnitKey = "MasterArcher",
				DifficultyRating = 30,
				IsRange = true
			},
			{
				UnitKey = "DesertDevil",
				DifficultyRating = 25,
			},
			{
				UnitKey = "DesertStalker",
				DifficultyRating = 30,
				IsRange = true
			},
			{
				UnitKey = "Lindwurm",
				DifficultyRating = 20
			}
		]
	},
]

gt.Const.World.Spawn.GauntletBoss <- [
	{
		Cost = 0,
		MovementSpeedMult = 1.0,
		VisibilityMult = 1.0,
		VisionMult = 1.0,
		Body = "figure_bandit_01",
		Troops = [
			{
				Type = this.Const.World.Spawn.Troops.Wardog,
				Num = 8
			}
		],
		Name = "GauntletBoss",
		ForceFlags = ["IsBoss"],
		Pool = [ // enemies here, along with co-spawn, will be spawn as Champion
			{
				UnitKey = "Necromancer",
				DifficultyRating = 35,
				IsCrowdControl = true,
				CoSpawn = [
					{
						UnitKey = "ZombieKnightBodyguard",
						Num = 2
					},
					{
						UnitKey = "ZombieKnight"
						Num = 1
					}
				]
			},
			{
				UnitKey = "Swordmaster",
				DifficultyRating = 50
			},
			{
				UnitKey = "DesertDevil",
				DifficultyRating = 50
			},
			{
				UnitKey = "ZombieBoss",
				DifficultyRating = 45,
				IsCrowdControl = true
			},
			{
				UnitKey = "GrandDiviner",
				DifficultyRating = 35,
				IsCrowdControl = true,
				CoSpawn = [
					{
						UnitKey = "FaultFinder",
						Num = 2
					}
				]
			},
			{
				UnitKey = "SkeletonBoss",
				DifficultyRating = 16
			}
		]
	}
]

gt.Const.World.Spawn.GauntletPreset <- [
	{
		Cost = 0,
		MovementSpeedMult = 1.0,
		VisibilityMult = 1.0,
		VisionMult = 1.0,
		Body = "figure_bandit_01",
		Troops = [
			{
				Type = this.Const.World.Spawn.Troops.Wardog,
				Num = 9
			}
		],
		GauntletName = "GauntletPreset",
		Pool = [
			{
				UnitKey = "Mortar",
				DifficultyRating = 12,
				IsCrowdControl = true,
				CoSpawn = [
					{
						UnitKey = "Engineer",
						Num = 2
					},
					{
						UnitKey = "Officer",
						Num = 1
					}
				]
			},
			{
				UnitKey = "ZombieYeoman",
				DifficultyRating = 1
			},
			{
				UnitKey = "ZombieKnight",
				DifficultyRating = 2
			},
			{
				UnitKey = "SkeletonLight",
				DifficultyRating = 1
			},
			{
				UnitKey = "SkeletonHeavy",
				DifficultyRating = 3
			}
		]
	}
]

function onCostCompare(_t1, _t2) {
	if (_t1.Cost < _t2.Cost) {
		return -1;
	} else if (_t1.Cost > _t2.Cost) {
		return 1;
	}

	return 0;
}

function calculateCosts(_p) {
	foreach (p in _p) {
		p.Cost <- 0;

		foreach (t in p.Troops) {
			p.Cost += t.Type.Cost * t.Num;
		}

		if (!("MovementSpeedMult" in p)) {
			p.MovementSpeedMult <- 1.0;
		}
	}

	_p.sort(this.onCostCompare);
}

this.calculateCosts(this.Const.World.Spawn.GauntletEarly)
this.calculateCosts(this.Const.World.Spawn.GauntletMid)
this.calculateCosts(this.Const.World.Spawn.GauntletLate)
this.calculateCosts(this.Const.World.Spawn.GauntletChampion)
this.calculateCosts(this.Const.World.Spawn.GauntletMiniBoss)
this.calculateCosts(this.Const.World.Spawn.GauntletBoss)
this.calculateCosts(this.Const.World.Spawn.GauntletPreset)
