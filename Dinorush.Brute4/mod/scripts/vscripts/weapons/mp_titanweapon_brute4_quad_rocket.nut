global function MpTitanweaponBrute4QuadRocket_Init

global function OnWeaponPrimaryAttack_TitanWeapon_Brute4_QuadRocket

global function OnWeaponStartZoomIn_TitanWeapon_Brute4_QuadRocket
global function OnWeaponStartZoomOut_TitanWeapon_Brute4_QuadRocket

#if SERVER
global function OnWeaponNpcPrimaryAttack_TitanWeapon_Brute4_QuadRocket
#endif // #if SERVER

#if CLIENT
global function OnClientAnimEvent_TitanWeapon_Brute4_QuadRocket
#endif // #if CLIENT


const float MISSILE_LIFETIME = 8.0
const float STRAIGHT_CONDENSE_DELAY = 0.0
const float STRAIGHT_CONDENSE_TIME = 0.6
const float STRAIGHT_EXPAND_DIST = 30.0
const float STRAIGHT_CONDENSE_DIST = 25.0
const asset AMPED_SHOT_PROJECTILE = $"models/weapons/bullets/temp_triple_threat_projectile_large.mdl"

const float QUAD_ROCKET_SPEED = 3000.0
const float STRAIGHT_ROCKET_SPEED = QUAD_ROCKET_SPEED * 1.25
const float SINGLE_ROCKET_SPEED = 8000.0

void function MpTitanweaponBrute4QuadRocket_Init()
{
	RegisterSignal( "FiredWeapon" )
	RegisterSignal( "KillMobileDomeShield" )

	PrecacheParticleSystem( $"wpn_muzzleflash_xo_rocket_FP" )
	PrecacheParticleSystem( $"wpn_muzzleflash_xo_rocket" )
	PrecacheParticleSystem( $"wpn_muzzleflash_xo_fp" )
	PrecacheParticleSystem( $"P_muzzleflash_xo_mortar" )

#if SERVER
	PrecacheWeapon( "mp_titanweapon_brute4_quad_rocket" )
	PrecacheModel( AMPED_SHOT_PROJECTILE )
#endif // #if SERVER
}

void function OnWeaponStartZoomIn_TitanWeapon_Brute4_QuadRocket( entity weapon )
{
	if ( weapon.HasMod( "cluster_payload" ) )
		return

	array<string> mods = weapon.GetMods()
	mods.append( "single_shot" )
	weapon.SetMods( mods )
}

void function OnWeaponStartZoomOut_TitanWeapon_Brute4_QuadRocket( entity weapon )
{
	array<string> mods = weapon.GetMods()
	mods.fastremovebyvalue( "single_shot" )
	weapon.SetMods( mods )
}


#if CLIENT
void function OnClientAnimEvent_TitanWeapon_Brute4_QuadRocket( entity weapon, string name )
{
	if ( name == "muzzle_flash" )
	{
		weapon.PlayWeaponEffect( $"wpn_muzzleflash_xo_fp", $"wpn_muzzleflash_xo_rocket", "muzzle_flash" )
	}
}
#endif // #if CLIENT

var function OnWeaponPrimaryAttack_TitanWeapon_Brute4_QuadRocket( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	entity player = weapon.GetWeaponOwner()
	float zoomFrac = player.GetZoomFrac()
	if ( zoomFrac < 1 && zoomFrac > 0)
		return 0

	#if CLIENT
		if ( !weapon.ShouldPredictProjectiles() )
			return weapon.GetAmmoPerShot()
	#endif

	return FireMissileStream( weapon, attackParams, PROJECTILE_PREDICTED )
}

#if SERVER
var function OnWeaponNpcPrimaryAttack_TitanWeapon_Brute4_QuadRocket( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	return FireMissileStream( weapon, attackParams, PROJECTILE_NOT_PREDICTED )
}
#endif // #if SERVER

int function FireMissileStream( entity weapon, WeaponPrimaryAttackParams attackParams, bool predicted )
{
	weapon.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )
	bool adsPressed = weapon.IsWeaponInAds()
	bool hasBurnMod = weapon.HasMod( "cluster_payload" )
	if ( adsPressed && !hasBurnMod && !weapon.HasMod( "single_shot" ) )
		OnWeaponStartZoomIn_TitanWeapon_Brute4_QuadRocket( weapon )

	if ( hasBurnMod )
		weapon.EmitWeaponSound_1p3p( "ShoulderRocket_Paint_Fire_1P", "ShoulderRocket_Paint_Fire_3P" )
	else if ( adsPressed )
		weapon.EmitWeaponSound_1p3p( "Weapon_Titan_Rocket_Launcher_Amped_Fire_1P", "Weapon_Titan_Rocket_Launcher_Amped_Fire_3P" )
	else
		weapon.EmitWeaponSound_1p3p( "Weapon_Titan_Rocket_Launcher.RapidFire_1P", "Weapon_Titan_Rocket_Launcher.RapidFire_3P" )

	entity weaponOwner = weapon.GetWeaponOwner()
	if ( !IsValid( weaponOwner ) )
		return 0
	weaponOwner.Signal( "KillMobileDomeShield" )

	if ( !adsPressed && !hasBurnMod )
	{
		int shots = minint( weapon.GetProjectilesPerShot(), weapon.GetWeaponPrimaryClipCount() )
		FireMissileStream_Spiral( weapon, attackParams, predicted, shots )
		return weapon.GetAmmoPerShot()
	}
	else
	{

		float missileSpeed = SINGLE_ROCKET_SPEED
		if( hasBurnMod )
			missileSpeed = SINGLE_ROCKET_SPEED

		int impactFlags = (DF_IMPACT | DF_GIB | DF_KNOCK_BACK)

		entity bolt = weapon.FireWeaponBolt( attackParams.pos, attackParams.dir, missileSpeed, impactFlags, damageTypes.explosive | DF_KNOCK_BACK, predicted, 0 )
		if ( bolt != null )
		{
			SetTeam( bolt, weaponOwner.GetTeam() )
		#if SERVER
			string whizBySound = "Weapon_Sidwinder_Projectile"
			EmitSoundOnEntity( bolt, whizBySound )
		#endif
			bolt.kv.rendercolor = "0 0 0"
			bolt.kv.renderamt = 0
			bolt.kv.fadedist = 1
			bolt.kv.gravity = 0.001
		}

		return weapon.GetAmmoPerShot()
	}

	unreachable
}


int function FindIdealMissileConfiguration( int numMissiles, int i )
{
	//We're locked into 4 missiles from passing in 0-3, and in the case of 2 we want to fire the horizontal missiles for aesthetic reasons.
	int idealMissile
	if ( numMissiles == 2 )
	{
		if ( i == 0 )
			idealMissile = 1
		else
			idealMissile = 3
	}
	else
	{
		idealMissile = i
	}

	return idealMissile
}

vector function FindStraightMissileDir( vector dir, int i )
{
	vector angles = VectorToAngles( dir )
	switch ( i )
	{
		case 0: // Up
			return AnglesToUp( angles )
			break
		case 1: // Right
			return -AnglesToRight( angles )
			break
		case 2: // Down
			return -AnglesToUp( angles )
			break
		case 3: // Left
			return AnglesToRight( angles )
	}
	return < 0,0,0 >
}

void function FireMissileStream_Spiral( entity weapon, WeaponPrimaryAttackParams attackParams, bool predicted, int numMissiles = 4 )
{
	array<entity> missiles
	array<vector> straightDir
	bool straight = weapon.HasMod( "straight_shot" )
	float missileSpeed = straight ? STRAIGHT_ROCKET_SPEED : QUAD_ROCKET_SPEED

	entity weaponOwner = weapon.GetWeaponOwner()
	if ( IsSingleplayer() && weaponOwner.IsPlayer() )
		missileSpeed = 2000

	int impactFlags = (DF_IMPACT | DF_GIB | DF_KNOCK_BACK)

	for ( int i = 0; i < numMissiles; i++ )
	{
		vector pos = attackParams.pos
		int missileNumber = FindIdealMissileConfiguration( numMissiles, i )
		if ( straight )
		{
			straightDir.append( FindStraightMissileDir( attackParams.dir, missileNumber ) )
			pos += straightDir[i] * STRAIGHT_EXPAND_DIST
		}

		entity missile = weapon.FireWeaponMissile( pos, attackParams.dir, missileSpeed, impactFlags, damageTypes.explosive | DF_KNOCK_BACK, false, predicted )
		if ( missile )
		{
			//Spreading out the missiles
			if ( !straight )
				missile.InitMissileSpiral( attackParams.pos, attackParams.dir, missileNumber, false, false )

			missile.kv.lifetime = MISSILE_LIFETIME
			missile.SetSpeed( missileSpeed )
			SetTeam( missile, weapon.GetWeaponOwner().GetTeam() )

			missiles.append( missile )

#if SERVER
			EmitSoundOnEntity( missile, "Weapon_Sidwinder_Projectile" )
#endif // #if SERVER
		}
	}

	if ( straight && missiles.len() > 0 )
		thread MissileStream_CondenseSpiral( missiles, straightDir, missileSpeed )
}

void function MissileStream_CondenseSpiral( array<entity> missiles, array<vector> straightDir, float missileSpeed )
{
	wait STRAIGHT_CONDENSE_DELAY

	ArrayRemoveInvalid( missiles )
	if ( missiles.len() == 0 )
		return

	array<vector> targetPos, velocities
	foreach ( i, missile in missiles )
	{
		vector target = -straightDir[i] * STRAIGHT_CONDENSE_DIST
		velocities.append( missile.GetVelocity() )
		targetPos.append( missile.GetOrigin() + velocities[i] * STRAIGHT_CONDENSE_TIME + target )
		missile.SetVelocity( velocities[i] + target / STRAIGHT_CONDENSE_TIME )
	}

	wait STRAIGHT_CONDENSE_TIME

	foreach ( i, missile in missiles )
	{
		if ( IsValid( missile ) )
		{
			missile.SetOrigin( targetPos[i] )
			missile.SetVelocity( velocities[i] )
		}
	}
}