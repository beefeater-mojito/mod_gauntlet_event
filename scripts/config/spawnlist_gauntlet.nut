local gt = this.getroottable();

if (!("World" in gt.Const)) {
	gt.Const.World <- {};
}

if (!("Spawn" in gt.Const.World)) {
	gt.Const.World.Spawn <- {};
}

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
		Pool = [
			{
				Type = this.Const.World.Spawn.Troops.Footman,
				DifficultyRating = 2,
				Weight = 3
			},
			{
				Type = this.Const.World.Spawn.Troops.Billman,
				DifficultyRating = 2,
				Weight = 3,
				IsSquishyMelee = true
			},
			{
				Type = this.Const.World.Spawn.Troops.Arbalester,
				DifficultyRating = 3,
				IsRange = true,
				CoSpawn = [
					{
						Type = this.Const.World.Spawn.Troops.ArmoredWardog
					}
				]
			},
			{
				Type = this.Const.World.Spawn.Troops.ManAtArms,
				DifficultyRating = 3
			},
			// gilded
			{
				Type = this.Const.World.Spawn.Troops.Conscript,
				DifficultyRating = 2,
				Weight = 2
			},
			{
				Type = this.Const.World.Spawn.Troops.ConscriptPolearm,
				DifficultyRating = 3,
				Weight = 2,
				CoSpawn = [
					{
						Type = this.Const.World.Spawn.Troops.MilitiaVeteran
					}
				]
			},
			// brigand
			{
				Type = this.Const.World.Spawn.Troops.BanditRaider,
				DifficultyRating = 1,
				IsSquishyMelee = true,
				Weight = 4
			},
			{
				Type = this.Const.World.Spawn.Troops.BanditMarksman,
				DifficultyRating = 2,
				IsRange = true,
				Weight = 2,
				CoSpawn = [
					{
						Type = this.Const.World.Spawn.Troops.Wardog
					}
				]
			},
			{
				Type = this.Const.World.Spawn.Troops.BanditLeader,
				DifficultyRating = 3,
				CoSpawn = [
					{
						Type = this.Const.World.Spawn.Troops.ArmoredWardog
					}
				]
			},
			// nomad
			{
				Type = this.Const.World.Spawn.Troops.NomadOutlaw,
				DifficultyRating = 1,
				Weight = 3
			},
			{
				Type = this.Const.World.Spawn.Troops.NomadArcher,
				DifficultyRating = 1,
				IsRange = true,
				Weight = 2
			},
			{
				Type = this.Const.World.Spawn.Troops.NomadLeader,
				DifficultyRating = 3
			},
			// barb
			{
				Type = this.Const.World.Spawn.Troops.BarbarianMarauder,
				DifficultyRating = 2,
				Weight = 3
			},
			// orc
			{
				Type = this.Const.World.Spawn.Troops.OrcYoung,
				DifficultyRating = 1,
				IsSquishyMelee = true,
				Weight = 2
			},
			{
				Type = this.Const.World.Spawn.Troops.OrcBerserker,
				DifficultyRating = 3,
				IsSquishyMelee = true,
				Weight = 2
			},
			{
				Type = this.Const.World.Spawn.Troops.OrcWarrior,
				DifficultyRating = 4
			},
			// gobbo
			{
				Type = this.Const.World.Spawn.Troops.GoblinSkirmisher,
				DifficultyRating = 1,
				IsSquishyMelee = true
			},
			{
				Type = this.Const.World.Spawn.Troops.GoblinAmbusher,
				DifficultyRating = 2,
				IsRange = true
			},
			{
				Type = this.Const.World.Spawn.Troops.GoblinWolfrider,
				DifficultyRating = 2,
				IsSquishyMelee = true
			},
			// beast
			{
				Type = this.Const.World.Spawn.Troops.Ghoul,
				DifficultyRating = 1,
				IsSquishyMelee = true
			},
			{
				Type = this.Const.World.Spawn.Troops.Serpent,
				DifficultyRating = 1,
				IsSquishyMelee = true
			},
			// undead
			{
				Type = this.Const.World.Spawn.Troops.ZombieKnight,
				DifficultyRating = 3,
				CoSpawn = [
					{
						Type = this.Const.World.Spawn.Troops.Warhound
					}
				]
			},
			{
				Type = this.Const.World.Spawn.Troops.Ghost,
				DifficultyRating = 6,
				IsCrowdControl = true,
				CoSpawn = [
					{
						Type = this.Const.World.Spawn.Troops.ZombieNomad
					},
					{
						Type = this.Const.World.Spawn.Troops.ZombieYeomanBodyguard,
						Num = 2
					},
					{
						Type = this.Const.World.Spawn.Troops.Warhound,
						Num = 2
					}
				]
			},
			{
				Type = this.Const.World.Spawn.Troops.Necromancer,
				DifficultyRating = 8,
				IsCrowdControl = true,
				CoSpawn = [
					{
						Type = this.Const.World.Spawn.Troops.ZombieYeomanBodyguard,
						Num = 2
					},
					{
						Type = this.Const.World.Spawn.Troops.ZombieNomad,
						Num = 2
					}
				]
			},
			{
				Type = this.Const.World.Spawn.Troops.SkeletonMedium,
				DifficultyRating = 3,
				Weight = 2
			},
			{
				Type = this.Const.World.Spawn.Troops.SkeletonMediumPolearm,
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
		Pool = [
			// noble
			{
				Type = this.Const.World.Spawn.Troops.Footman,
				DifficultyRating = 2,
				Weight = 4
			},
			{
				Type = this.Const.World.Spawn.Troops.Billman,
				DifficultyRating = 1,
				Weight = 4,
				IsSquishyMelee = true
			},
			{
				Type = this.Const.World.Spawn.Troops.Arbalester,
				DifficultyRating = 2,
				IsRange = true,
				CoSpawn = [
					{
						Type = this.Const.World.Spawn.Troops.ArmoredWardog
					}
				]
			},
			{
				Type = this.Const.World.Spawn.Troops.ManAtArms,
				DifficultyRating = 3,
				Weight = 3
			},
			{
				Type = this.Const.World.Spawn.Troops.Sergeant,
				DifficultyRating = 3,
				Weight = 2,
				CoSpawn = [
					{
						Type = this.Const.World.Spawn.Troops.ArmoredWardog
					}
				]
			},
			{
				Type = this.Const.World.Spawn.Troops.Greatsword,
				DifficultyRating = 3,
				Weight = 3,
				IsSquishyMelee = true
			},
			{
				Type = this.Const.World.Spawn.Troops.Knight,
				DifficultyRating = 6
			},
			// gilded
			{
				Type = this.Const.World.Spawn.Troops.Conscript,
				DifficultyRating = 1,
				Weight = 4
			},
			{
				Type = this.Const.World.Spawn.Troops.ConscriptPolearm,
				DifficultyRating = 2,
				Weight = 4
			},
			{
				Type = this.Const.World.Spawn.Troops.Gunner,
				DifficultyRating = 3,
				Weight = 3,
				IsSquishyMelee = true
			},
			{
				Type = this.Const.World.Spawn.Troops.Officer,
				DifficultyRating = 3,
				Weight = 2
			},
			{
				Type = this.Const.World.Spawn.Troops.Assassin,
				DifficultyRating = 5,
				Weight = 2,
				CoSpawn = [
					{
						Type = this.Const.World.Spawn.Troops.ArmoredWardog
					}
				]
			},
			{
				Type = this.Const.World.Spawn.Troops.Mortar,
				DifficultyRating = 11,
				IsCrowdControl = true,
				CoSpawn = [
					{
						Type = this.Const.World.Spawn.Troops.Engineer,
						Num = 2
					},
					{
						Type = this.Const.World.Spawn.Troops.ArmoredWardog,
						Num = 2
					},
					{
						Type = this.Const.World.Spawn.Troops.Conscript,
						Num = 2
					}
				]
			},
			// brigand
			{
				Type = this.Const.World.Spawn.Troops.BanditMarauder,
				DifficultyRating = 4,
				Weight = 2,
				CoSpawn = [
					{
						Type = this.Const.World.Spawn.Troops.ArmoredWardog
					}
				]
			},
			{
				Type = this.Const.World.Spawn.Troops.HedgeKnight,
				DifficultyRating = 8
			},
			// nomad + glads
			{
				Type = this.Const.World.Spawn.Troops.Executioner,
				DifficultyRating = 9
			},
			{
				Type = this.Const.World.Spawn.Troops.Gladiator,
				DifficultyRating = 7
			},
			// barb
			{
				Type = this.Const.World.Spawn.Troops.BarbarianMarauder,
				DifficultyRating = 1,
				Weight = 2,
				IsSquishyMelee = true
			},
			{
				Type = this.Const.World.Spawn.Troops.BarbarianChampion,
				DifficultyRating = 4,
				Weight = 2
			},
			{
				Type = this.Const.World.Spawn.Troops.BarbarianUnhold,
				DifficultyRating = 7,
				CoSpawn = [
					{
						Type = this.Const.World.Spawn.Troops.BarbarianBeastmaster
					},
					{
						Type = this.Const.World.Spawn.Troops.BarbarianDrummer
					}
				]
			},
			// orc
			{
				Type = this.Const.World.Spawn.Troops.OrcBerserker,
				DifficultyRating = 2,
				IsSquishyMelee = true,
				Weight = 3
			},
			{
				Type = this.Const.World.Spawn.Troops.OrcWarrior,
				DifficultyRating = 4,
				Weight = 3
			},
			{
				Type = this.Const.World.Spawn.Troops.OrcWarlord,
				DifficultyRating = 7,
				CoSpawn = [
					{
						Type = this.Const.World.Spawn.Troops.OrcYoung
					}
				]
			},
			// gobbo
			{
				Type = this.Const.World.Spawn.Troops.GoblinAmbusher,
				DifficultyRating = 2,
				IsRange = true
			},
			{
				Type = this.Const.World.Spawn.Troops.GoblinWolfrider,
				DifficultyRating = 1,
				IsSquishyMelee = true
			},
			{
				Type = this.Const.World.Spawn.Troops.GoblinOverseer,
				DifficultyRating = 4,
				IsRange = true
			},
			// beast
			{
				Type = this.Const.World.Spawn.Troops.GhoulHIGH,
				DifficultyRating = 2,
				IsSquishyMelee = true
			},
			{
				Type = this.Const.World.Spawn.Troops.Serpent,
				Num = 2,
				DifficultyRating = 3,
				IsSquishyMelee = true
			},
			{
				Type = this.Const.World.Spawn.Troops.Unhold,
				DifficultyRating = 6,
				Weight = 2
			},
			{
				Type = this.Const.World.Spawn.Troops.UnholdFrost,
				DifficultyRating = 8,
				Weight = 2
			},
			// undead: zombie
			{
				Type = this.Const.World.Spawn.Troops.ZombieKnight,
				DifficultyRating = 2,
				Weight = 3,
				CoSpawn = [
					{
						Type = this.Const.World.Spawn.Troops.Warhound
					}
				]
			},
			{
				Type = this.Const.World.Spawn.Troops.Ghost,
				DifficultyRating = 6,
				IsCrowdControl = true,
				CoSpawn = [
					{
						Type = this.Const.World.Spawn.Troops.ZombieYeoman,
						Num = 2
					},
					{
						Type = this.Const.World.Spawn.Troops.ZombieNomad,
						Num = 2
					}
				]
			},
			{
				Type = this.Const.World.Spawn.Troops.Necromancer,
				DifficultyRating = 10,
				IsCrowdControl = true,
				CoSpawn = [
					{
						Type = this.Const.World.Spawn.Troops.ZombieKnightBodyguard
					},
					{
						Type = this.Const.World.Spawn.Troops.ZombieYeomanBodyguard
					},
					{
						Type = this.Const.World.Spawn.Troops.ZombieKnight
					}
				]
			},
			// undead: skellies
			{
				Type = this.Const.World.Spawn.Troops.SkeletonMedium,
				DifficultyRating = 2,
				Weight = 4
			},
			{
				Type = this.Const.World.Spawn.Troops.SkeletonMediumPolearm,
				DifficultyRating = 2,
				Weight = 4,
				IsSquishyMelee = true
			},
			{
				Type = this.Const.World.Spawn.Troops.VampireLOW,
				DifficultyRating = 4,
				IsRange = true,
				CoSpawn = [
					{
						Type = this.Const.World.Spawn.Troops.SkeletonLight
					}
				]
			},
			{
				Type = this.Const.World.Spawn.Troops.SkeletonHeavy,
				DifficultyRating = 4,
				Weight = 2
			},
			{
				Type = this.Const.World.Spawn.Troops.SkeletonHeavyPolearm,
				DifficultyRating = 4,
				Weight = 2
			},
			{
				Type = this.Const.World.Spawn.Troops.SkeletonPriest,
				DifficultyRating = 12,
				IsCrowdControl = true,
				CoSpawn = [
					{
						Type = this.Const.World.Spawn.Troops.SkeletonHeavyBodyguard
					}
				]
			}
		]
	}
]

function onCostCompare( _t1, _t2 )
{
	if (_t1.Cost < _t2.Cost)
	{
		return -1;
	}
	else if (_t1.Cost > _t2.Cost)
	{
		return 1;
	}

	return 0;
}

function calculateCosts( _p )
{
	foreach( p in _p )
	{
		p.Cost <- 0;

		foreach( t in p.Troops )
		{
			p.Cost += t.Type.Cost * t.Num;
		}

		if (!("MovementSpeedMult" in p))
		{
			p.MovementSpeedMult <- 1.0;
		}
	}

	_p.sort(this.onCostCompare);
}

this.calculateCosts(this.Const.World.Spawn.GauntletEarly)
this.calculateCosts(this.Const.World.Spawn.GauntletMid)