global function MobileDomeShield_AllowShootThrough
global function MobileDomeShield_CreateDome

const vector MOBILE_DOME_COLOR_PAS_MOLTING_SHELL = <92, 92, 200>
const vector MOBILE_DOME_COLOR_CHARGE_FULL		 = <92, 155, 200>	// blue
const vector MOBILE_DOME_COLOR_CHARGE_MED		 = <255, 128, 80>	// orange
const vector MOBILE_DOME_COLOR_CHARGE_EMPTY		 = <255, 80, 80>	// red

const float MOBILE_DOME_COLOR_CROSSOVERFRAC_FULL2MED	= 0.75  // from zero to this fraction, fade between full and medium charge colors
const float MOBILE_DOME_COLOR_CROSSOVERFRAC_MED2EMPTY	= 0.95  // from "full2med" to this fraction, fade between medium and empty charge colors


struct BubbleShieldDamageStruct
{
	float damageFloor
	float damageCeiling
	array<float> quadraticPolynomialCoefficients //Should actually be float[3], but because float[ 3 ] and array<float> are different types and this needs to be fed into EvaluatePolynomial make it an array<float> instead
}

void function MobileDomeShield_CreateDome( entity titan, vector origin, vector angles, float duration = 10 )
{
	if ( !IsAlive( titan ) )
		return

	entity soul = titan.GetTitanSoul()
	soul.Signal( "NewBubbleShield" )
	entity bubbleShield = MobileDomeShield_CreateDomeWithSettings( titan.GetTeam(), origin, angles, titan, duration )

#if SERVER
	soul.soul.bubbleShield = bubbleShield
	if ( titan.IsPlayer() )
		SyncedMelee_Disable( titan )
	
	// Normally, Dome Shield prevents the user from taking damage. We allow all damage to occur and use a callback to make sure only the damage we want goes through.
	AddEntityCallback_OnDamaged( titan, MobileDomeShield_OwnerTakeSpecialDamage )

	soul.soul.bubbleShield.SetParent( titan, "ORIGIN" )
	table bubbleShieldDotS = expect table( soul.soul.bubbleShield.s )
	entity vortexColoredFX = expect entity ( bubbleShieldDotS.vortexColoredFX )
	vortexColoredFX.SetParent( soul.soul.bubbleShield )
	bubbleShieldDotS.moltingShell <- false
	if ( SoulHasPassive( soul, ePassives["#GEAR_BRUTE4_DOME"] ) )
		bubbleShieldDotS.moltingShell <- true

	// Update color here since the function that updates it waits a frame before its first iteration
	MobileDomeShield_ColorUpdate( bubbleShield, vortexColoredFX )
	thread WaitForCleanup(titan, soul, bubbleShield, duration)
#endif
}

void function WaitForCleanup(entity titan, entity soul, entity bubbleShield, float duration)
{
	bubbleShield.EndSignal( "OnDestroy" )
	soul.EndSignal( "OnTitanDeath" )
	soul.EndSignal( "OnDestroy" )
	soul.EndSignal( "TitanBrokeBubbleShield" )

	OnThreadEnd(
		function () : ( titan, soul, bubbleShield )
		{
			MobileDomeShield_CleanupVars( titan, soul, bubbleShield )
		}
	)
	wait duration
}

void function MobileDomeShield_CleanupVars( entity titan, entity soul, entity bubbleShield )
{
	MobileDomeShield_Destroy( bubbleShield )
#if SERVER
	if( IsValid( titan ) )
	{
		if ( titan.IsPlayer() )
			SyncedMelee_Enable( titan )
		RemoveEntityCallback_OnDamaged( titan, MobileDomeShield_OwnerTakeSpecialDamage )
	}
	if ( IsValid( soul ) )
		soul.soul.bubbleShield = null
#endif
}

void function MobileDomeShield_Destroy( entity bubbleShield )
{
	if ( IsValid( bubbleShield ) )
	{
#if SERVER
		ClearChildren( bubbleShield )
		bubbleShield.Destroy()
#endif
	}
}

entity function MobileDomeShield_CreateDomeWithSettings( int team, vector origin, vector angles, entity owner = null, float duration = 10 )
{
#if SERVER

	int health = MOBILE_DOME_HEALTH
	entity bubbleShield = CreatePropScript( $"models/fx/xo_shield.mdl", origin, angles, SOLID_VPHYSICS )
  	bubbleShield.kv.rendercolor = "81 130 151"
   	bubbleShield.kv.contents = (int(bubbleShield.kv.contents) | CONTENTS_NOGRAPPLE)
	 // Blocks bullets, projectiles but not players and not AI
	bubbleShield.kv.CollisionGroup = TRACE_COLLISION_GROUP_BLOCK_WEAPONS
	bubbleShield.SetMaxHealth( health )
	bubbleShield.SetHealth( health )
	bubbleShield.SetTakeDamageType( DAMAGE_YES )
	bubbleShield.SetBlocksRadiusDamage( false )
	bubbleShield.SetArmorType( ARMOR_TYPE_HEAVY )
	bubbleShield.SetDamageNotifications( true )
	bubbleShield.SetDeathNotifications( true )
	bubbleShield.Hide()

	SetObjectCanBeMeleed( bubbleShield, true )
	SetVisibleEntitiesInConeQueriableEnabled( bubbleShield, true ) // Needed for melee to see it
	SetCustomSmartAmmoTarget( bubbleShield, false )

	SetTeam( bubbleShield, team )
	AddEntityCallback_OnDamaged( bubbleShield, MobileDomeShield_HandleDamage )

	array<entity> bubbleShieldFXs

	vector coloredFXOrigin = origin + Vector( 0, 0, 25 )
	table bubbleShieldDotS = expect table( bubbleShield.s )

	entity vortexColoredFX = StartParticleEffectInWorld_ReturnEntity( BUBBLE_SHIELD_FX_PARTICLE_SYSTEM_INDEX, coloredFXOrigin, <0, 0, 0> )
	bubbleShieldDotS.vortexColoredFX <- vortexColoredFX
	bubbleShieldFXs.append( vortexColoredFX )

	#if MP
	DisableTitanfallForLifetimeOfEntityNearOrigin( bubbleShield, origin, TITANHOTDROP_DISABLE_ENEMY_TITANFALL_RADIUS )
	#endif

	EmitSoundOnEntity( bubbleShield, "BubbleShield_Sustain_Loop" )

	thread MobileDomeShield_Drain( bubbleShield, bubbleShieldFXs, duration, vortexColoredFX )

	return bubbleShield
#endif
}

#if SERVER
void function MobileDomeShield_ColorUpdate( entity bubbleShield, entity colorFXHandle = null )
{
	table bubbleShieldDotS = expect table( bubbleShield.s )
	if ( bubbleShieldDotS.moltingShell )
		EffectSetControlPointVector( colorFXHandle, 1, MobileDomeShield_GetCurrentColor( 1.0 - GetHealthFrac( bubbleShield ), MOBILE_DOME_COLOR_PAS_MOLTING_SHELL ) )
	else
		EffectSetControlPointVector( colorFXHandle, 1, MobileDomeShield_GetCurrentColor( 1.0 - GetHealthFrac( bubbleShield ) ) )
}

void function MobileDomeShield_OwnerTakeSpecialDamage( entity owner, var damageInfo )
{
	int damageFlags = DamageInfo_GetCustomDamageType( damageInfo )
	int passFlags = DF_RODEO | DF_DOOMED_HEALTH_LOSS | DF_BYPASS_SHIELD
	if ( damageFlags & passFlags )
		return

	if ( DamageInfo_GetDamageSourceIdentifier( damageInfo ) == eDamageSourceId.fall )
		return

	// If melees hit the user, we want to pass the damage to dome shield
	if ( damageFlags & DF_MELEE )
	{
		entity bubbleShield = owner.GetTitanSoul().soul.bubbleShield
		if( IsValid( bubbleShield ) )
		{
			entity attacker = DamageInfo_GetAttacker( damageInfo )
			table damageTable =
			{
				scriptType = damageFlags
				forceKill = false
				damageType = DamageInfo_GetDamageType( damageInfo )
				damageSourceId = DamageInfo_GetDamageSourceIdentifier( damageInfo )
				origin = DamageInfo_GetDamagePosition( damageInfo )
			}

			bubbleShield.TakeDamage( DamageInfo_GetDamage( damageInfo ), attacker, attacker, damageTable )
		}
	}

	DamageInfo_SetDamage( damageInfo, 0 )
}

void function MobileDomeShield_HandleDamage( entity bubbleShield, var damageInfo )
{
	if( DamageInfo_GetCustomDamageType( damageInfo ) & DF_MELEE )
		DamageInfo_ScaleDamage( damageInfo, MOBILE_DOME_MELEE_MOD )

	entity attacker = DamageInfo_GetAttacker( damageInfo )
	if ( bubbleShield.GetTeam() != attacker.GetTeam() && attacker.IsPlayer() )
		attacker.NotifyDidDamage( bubbleShield, DamageInfo_GetHitBox( damageInfo ), DamageInfo_GetDamagePosition( damageInfo ), DamageInfo_GetCustomDamageType( damageInfo ), DamageInfo_GetDamage( damageInfo ), DamageInfo_GetDamageFlags( damageInfo ), DamageInfo_GetHitGroup( damageInfo ), DamageInfo_GetWeapon( damageInfo ), DamageInfo_GetDistFromAttackOrigin( damageInfo ) )
}
#endif

void function MobileDomeShield_Drain( entity bubbleShield, array<entity> bubbleShieldFXs, float fadeTime, entity colorFXHandle = null )
{
#if SERVER
	bubbleShield.EndSignal( "OnDestroy" )

	OnThreadEnd(
		function () : ( bubbleShield, bubbleShieldFXs )
		{
			if ( IsValid_ThisFrame( bubbleShield ) )
			{
				StopSoundOnEntity( bubbleShield, "BubbleShield_Sustain_Loop" )
				EmitSoundOnEntity( bubbleShield, "BubbleShield_End" )
				MobileDomeShield_Destroy( bubbleShield )
			}

			foreach ( fx in bubbleShieldFXs )
			{
				if ( IsValid_ThisFrame( fx ) )
				{
					EffectStop( fx )
				}
			}
		}
	)

	float healthPerSec = bubbleShield.GetMaxHealth() / fadeTime
	float lastTime = Time()
	while(true)
	{
		WaitFrame()
		bubbleShield.SetHealth( bubbleShield.GetHealth() - healthPerSec * ( Time() - lastTime ) )
		if ( colorFXHandle != null )
			MobileDomeShield_ColorUpdate( bubbleShield, colorFXHandle )
		lastTime = Time()
	}
#endif
}

void function MobileDomeShield_AllowShootThrough( entity titanPlayer, entity weapon )
{
#if SERVER
	Assert( titanPlayer.IsTitan() )

	entity soul = titanPlayer.GetTitanSoul()

	entity bubbleShield = soul.soul.bubbleShield


	if ( !IsValid( bubbleShield ) )
		return

	bubbleShield.SetOwner( titanPlayer ) //After this, player is able to fire out from shield. WATCH OUT FOR POTENTIAL COLLISION BUGS!

	if ( titanPlayer.IsPlayer() )
		thread MobileDomeShield_MonitorDash( titanPlayer, bubbleShield )
	thread MobileDomeShield_MonitorAttack( weapon, titanPlayer, bubbleShield )
#endif
}

void function MobileDomeShield_MonitorAttack( entity weapon, entity player, entity bubbleShield )
{
#if SERVER
	player.EndSignal( "OnDestroy" )
	bubbleShield.EndSignal("OnDestroy")
	entity soul = player.GetTitanSoul()

	WaitSignal( player, "DisembarkingTitan", "OnSyncedMelee", "KillMobileDomeShield", "OnMelee" ) //Sent when player fires his weapon/disembarks

	if ( !IsValid( soul ) )
		return

	soul.Signal( "TitanBrokeBubbleShield" ) //WaitUntilShieldFades will end when this signal is sent
#endif
}

void function MobileDomeShield_MonitorDash( entity player, entity bubbleShield )
{
	#if SERVER
	player.EndSignal( "OnDestroy" )
	bubbleShield.EndSignal("OnDestroy")

	float lastDodgePower = player.GetDodgePower()
	while( player.GetDodgePower() >= lastDodgePower )
	{
		lastDodgePower = player.GetDodgePower()
		WaitFrame()
	}

	entity soul = player.GetTitanSoul()
	if ( !IsValid( soul ) )
		return

	soul.Signal( "TitanBrokeBubbleShield" ) //WaitUntilShieldFades will end when this signal is sent
	#endif
}

vector function MobileDomeShield_GetCurrentColor( float chargeFrac, vector fullHealthColor = MOBILE_DOME_COLOR_CHARGE_FULL )
{
	return GetTriLerpColor( chargeFrac, fullHealthColor, MOBILE_DOME_COLOR_CHARGE_MED, MOBILE_DOME_COLOR_CHARGE_EMPTY )
}

// Copied from vortex, since it's not a global func
vector function GetTriLerpColor( float fraction, vector color1, vector color2, vector color3 )
{
	float crossover1 = MOBILE_DOME_COLOR_CROSSOVERFRAC_FULL2MED  // from zero to this fraction, fade between color1 and color2
	float crossover2 = MOBILE_DOME_COLOR_CROSSOVERFRAC_MED2EMPTY // from crossover1 to this fraction, fade between color2 and color3

	float r, g, b

	// 0 = full charge, 1 = no charge remaining
	if ( fraction < crossover1 )
	{
		r = Graph( fraction, 0, crossover1, color1.x, color2.x )
		g = Graph( fraction, 0, crossover1, color1.y, color2.y )
		b = Graph( fraction, 0, crossover1, color1.z, color2.z )
		return <r, g, b>
	}
	else if ( fraction < crossover2 )
	{
		r = Graph( fraction, crossover1, crossover2, color2.x, color3.x )
		g = Graph( fraction, crossover1, crossover2, color2.y, color3.y )
		b = Graph( fraction, crossover1, crossover2, color2.z, color3.z )
		return <r, g, b>
	}
	else
	{
		// for the last bit of overload timer, keep it max danger color
		r = color3.x
		g = color3.y
		b = color3.z
		return <r, g, b>
	}

	unreachable
}