untyped
global function Brute4_Init

void function Brute4_Init()
{
	#if SERVER
	RegisterWeaponDamageSources(
		{
			mp_titanweapon_brute4_quad_rocket = "#WPN_TITAN_ROCKET_LAUNCHER",
			mp_titanweapon_barrage_core_launcher = "#TITANCORE_BARRAGE",
			mp_titanweapon_grenade_volley = "#WPN_TITAN_GRENADE_VOLLEY",
			mp_titanability_cluster_payload = "#WPN_TITAN_CLUSTER_PAYLOAD"
		}
	)
	#endif

	Brute4_InitWeaponsAndPassives()
	
	#if SERVER
	GameModeRulesRegisterTimerCreditException( eDamageSourceId.mp_titanweapon_barrage_core_launcher )
	AddCallback_OnTitanGetsNewTitanLoadout( Brute4_HandlePassives )
	#endif
}

void function Brute4_InitWeaponsAndPassives()
{
	MpTitanweaponBrute4QuadRocket_Init()
	MpTitanAbilityClusterPayload_Init()
	MpTitanAbilityMobileDomeShield_Init()
	MpTitanweaponGrenadeVolley_Init()
	BarrageCore_Init()
}

#if SERVER
void function Brute4_HandlePassives( entity titan, TitanLoadoutDef loadout  )
{
	if( loadout.titanClass != "#DEFAULT_TITAN_6")
		return

	entity soul = titan.GetTitanSoul()
	if ( !IsValid( soul ) )
		return

//==================================================//KITS//==================================================//
	if ( SoulHasPassive( soul, ePassives["#GEAR_BRUTE4_WEAPON"] ) )
		titan.GetMainWeapons()[0].AddMod( "straight_shot" )

	if ( SoulHasPassive( soul, ePassives["#GEAR_BRUTE4_GRENADE"] ) )
		titan.GetOffhandWeapon( OFFHAND_RIGHT ).AddMod( "magnetic_rollers" )
				
	if ( SoulHasPassive( soul, ePassives["#GEAR_BRUTE4_CLUSTER"] ) )
	{
		titan.GetOffhandWeapon( OFFHAND_EQUIPMENT ).AddMod( "rapid_detonator" )
		titan.GetMainWeapons()[0].AddMod( "rapid_detonator" )
	}
				
	if ( SoulHasPassive( soul, ePassives["#GEAR_BRUTE4_PAYLOAD"] ) )
		titan.GetOffhandWeapon( OFFHAND_TITAN_CENTER ).AddMod( "explosive_reserves" )
				
	if ( SoulHasPassive( soul, ePassives["#GEAR_BRUTE4_DOME"] ) )
		titan.GetOffhandWeapon( OFFHAND_SPECIAL ).AddMod( "molting_dome" )

//==================================================//AEGIS RANKS//==================================================//

	if ( GetCurrentPlaylistVarInt( "aegis_upgrades", 0 ) == 1 )
	{
		entity weapon = titan.GetMainWeapons()[0]
		// Rank 1: Agile Frame - allow sprinting
		weapon.AddMod( "agile_frame" )
		titan.GetOffhandWeapon( OFFHAND_EQUIPMENT ).AddMod( "agile_frame" )
		titan.GetOffhandWeapon( OFFHAND_SPECIAL ).AddMod( "agile_frame" )

		// Rank 2: Health
		loadout.setFileMods.append( "fd_health_upgrade" )

		// Rank 3: Rocket Stream - more fire rate and ammo
		weapon.AddMod( "rocket_stream" )
		weapon.SetWeaponPrimaryClipCount( weapon.GetWeaponPrimaryClipCountMax() )

		// Rank 4: Gliders - faster barrage core rockets + less drop
		titan.GetOffhandWeapon( OFFHAND_EQUIPMENT ).AddMod( "gliders" )

		// Rank 5: Shields
		soul.SetShieldHealthMax( int( GetTitanSoulShieldHealth( soul ) * 1.5 ) )

		// Rank 6: Grenade Swarm - more grenades fired
		titan.GetOffhandWeapon( OFFHAND_RIGHT ).AddMod( "grenade_swarm" )

		// Rank 7: Pyrotechnics - no explosion falloff
		weapon.AddMod( "pyrotechnics" )
		titan.GetOffhandWeapon( OFFHAND_RIGHT ).AddMod( "pyrotechnics" )
		titan.GetOffhandWeapon( OFFHAND_EQUIPMENT ).AddMod( "pyrotechnics" )
	}
}
#endif
