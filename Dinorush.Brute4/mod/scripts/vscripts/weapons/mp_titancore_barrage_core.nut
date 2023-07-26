global function BarrageCore_Init

global function OnAbilityStart_BarrageCore
global function OnAbilityEnd_BarrageCore

void function BarrageCore_Init()
{
	PrecacheWeapon( "mp_titancore_barrage_core" )
	PrecacheWeapon( "mp_titanweapon_barrage_core_launcher" )
}

bool function OnAbilityStart_BarrageCore( entity weapon )
{
	if ( !OnAbilityCharge_TitanCore( weapon ) )
		return false

#if SERVER
	OnAbilityChargeEnd_TitanCore( weapon )
#endif

	OnAbilityStart_TitanCore( weapon )

	entity titan = weapon.GetOwner() // GetPlayerFromTitanWeapon( weapon )

#if SERVER
	if ( titan.IsPlayer() )
		Melee_Disable( titan )

	thread PROTO_BarrageCore( titan, weapon.GetCoreDuration(), weapon.GetMods() )
#endif

	return true
}

void function OnAbilityEnd_BarrageCore( entity weapon )
{
	entity titan = weapon.GetWeaponOwner()
	#if SERVER
	OnAbilityEnd_TitanCore( weapon )
	int currAmmo = weapon.GetWeaponPrimaryClipCount()
	
	if(currAmmo == 0)
	{
		titan.Signal( "CoreEnd" )
	}

	if ( titan != null )
	{
		if ( titan.IsPlayer() )
			Melee_Enable( titan )
		titan.Signal( "CoreEnd" )
	}
	#else
		if ( titan.IsPlayer() )
			TitanCockpit_PlayDialog( titan, "flightCoreOffline" )
	#endif
}

#if SERVER
//HACK - Should use operator functions from Joe/Steven W
void function PROTO_BarrageCore( entity titan, float flightTime, array<string> mods = [] )
{
	if ( !titan.IsTitan() )
		return

	table<string, bool> e
	e.shouldDeployWeapon <- false

	array<string> weaponArray = [ "mp_titancore_barrage_core" ]

	titan.EndSignal( "OnDestroy" )
	titan.EndSignal( "OnDeath" )
	titan.EndSignal( "TitanEjectionStarted" )
	titan.EndSignal( "DisembarkingTitan" )
	titan.EndSignal( "OnSyncedMelee" )

	int slowID = -1
	int speedID = -1
	if ( titan.IsPlayer() && !mods.contains( "agile_frame" ) )
	{
		slowID = StatusEffect_AddTimed( titan, eStatusEffect.move_slow, 0.5, flightTime, 0 )
		speedID = StatusEffect_AddTimed( titan, eStatusEffect.speed_boost, 0.5, flightTime, 0 )
	}

	OnThreadEnd(
		function() : ( titan, e, weaponArray, slowID, speedID )
		{
			if ( IsValid( titan ) && titan.IsPlayer() )
			{
				if ( IsAlive( titan ) && titan.IsTitan() )
				{
					if ( HasWeapon( titan, "mp_titanweapon_barrage_core_launcher" ) )
					{
						EnableWeapons( titan, weaponArray )
						titan.TakeWeapon( "mp_titanweapon_barrage_core_launcher" )
					}
				}

				titan.ClearParent()
				titan.Server_TurnDodgeDisabledOff()
				StatusEffect_Stop( titan, slowID )
				StatusEffect_Stop( titan, speedID )

				if ( e.shouldDeployWeapon && !titan.ContextAction_IsActive() )
					DeployAndEnableWeapons( titan )

				titan.Signal( "CoreEnd" )
			}
		}
	)

	if ( titan.IsPlayer() )
	{
		const float startupTime = 0.5
		const float endingTime = 0.5

		e.shouldDeployWeapon = true
		HolsterAndDisableWeapons( titan )

		DisableWeapons( titan, weaponArray )
		titan.GiveWeapon( "mp_titanweapon_barrage_core_launcher", mods )
		titan.SetActiveWeaponByName( "mp_titanweapon_barrage_core_launcher" )
		
		wait startupTime - 0.1

		// HACK: for some reason, weapons deploy instantly if you're sprinting. 
		// Fix by slowing the player off a sprint just before and removing when the weapon starts deploying.
		int tempSlow = StatusEffect_AddTimed( titan, eStatusEffect.move_slow, 0.5, 0.5, 0 )
		int tempSpeed = StatusEffect_AddTimed( titan, eStatusEffect.speed_boost, 0.5, 0.5, 0 )

		wait 0.1

		titan.Server_TurnDodgeDisabledOn()
		e.shouldDeployWeapon = false
		DeployAndEnableWeapons( titan )
		StatusEffect_Stop( titan, tempSlow )
		StatusEffect_Stop( titan, tempSpeed )

		titan.WaitSignal( "CoreEnd" )

		if ( IsAlive( titan ) && titan.IsTitan() )
		{
			e.shouldDeployWeapon = true
			HolsterAndDisableWeapons( titan )

			wait endingTime
		}
	}
	else
	{
		titan.GiveWeapon( "mp_titanweapon_barrage_core_launcher", mods )
		titan.SetActiveWeaponByName( "mp_titanweapon_barrage_core_launcher" )
		titan.WaitSignal( "CoreEnd" )
		titan.TakeWeapon( "mp_titanweapon_barrage_core_launcher" )
		titan.SetActiveWeaponByName("mp_titanweapon_brute4_quad_rocket")
	}
}
#endif