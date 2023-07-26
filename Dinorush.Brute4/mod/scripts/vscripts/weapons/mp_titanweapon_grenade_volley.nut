untyped
global function MpTitanweaponGrenadeVolley_Init
global function OnWeaponPrimaryAttack_titanweapon_grenade_volley
global function OnProjectileCollision_titanweapon_grenade_volley
global function OnWeaponAttemptOffhandSwitch_titanweapon_grenade_volley

#if SERVER
global function OnWeaponNpcPrimaryAttack_titanweapon_grenade_volley
#endif // #if SERVER

const FUSE_TIME = 0.5

void function MpTitanweaponGrenadeVolley_Init()
{
	PrecacheWeapon( "mp_titanweapon_grenade_volley" )
}

bool function OnWeaponAttemptOffhandSwitch_titanweapon_grenade_volley( entity weapon )
{
	int minAmmo = weapon.GetWeaponSettingInt( eWeaponVar.ammo_min_to_fire )
	int currAmmo = weapon.GetWeaponPrimaryClipCount()
	if ( currAmmo < minAmmo )
		return false

	return true
}

var function OnWeaponPrimaryAttack_titanweapon_grenade_volley( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	entity owner = weapon.GetWeaponOwner()
	if ( owner.IsPlayer() )
		PlayerUsedOffhand( owner, weapon )

	if ( IsServer() || weapon.ShouldPredictProjectiles() )
		FireGrenade( weapon, attackParams )

	return weapon.GetAmmoPerShot()
}

#if SERVER
var function OnWeaponNpcPrimaryAttack_titanweapon_grenade_volley( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	FireGrenade( weapon, attackParams, true )
}
#endif // #if SERVER

function FireGrenade( entity weapon, WeaponPrimaryAttackParams attackParams, isNPCFiring = false )
{
	weapon.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )
	vector angularVelocity = Vector( RandomFloatRange( -1200, 1200 ), 100, 0 )

	int damageType = DF_RAGDOLL | DF_EXPLOSION

	entity weaponOwner = weapon.GetWeaponOwner()
	weaponOwner.Signal( "KillMobileDomeShield" )

	vector bulletVec = ApplyVectorSpread( attackParams.dir, weaponOwner.GetAttackSpreadAngle() * 2 )

	entity nade = weapon.FireWeaponGrenade( attackParams.pos, bulletVec, angularVelocity, 0.0 , damageType, damageType, !isNPCFiring, true, false )

	if ( nade )
	{
		#if SERVER
			EmitSoundOnEntity( nade, "Weapon_softball_Grenade_Emitter" )
			Grenade_Init( nade, weapon )
		#else
			SetTeam( nade, weaponOwner.GetTeam() )
		#endif
	}
}

void function OnProjectileCollision_titanweapon_grenade_volley( entity projectile, vector pos, vector normal, entity hitEnt, int hitbox, bool isCritical )
{
	#if SERVER
	if ( projectile.proj.projectileBounceCount > 0 )
	{
		if ( "isMagnetic" in projectile.s && IsMagneticTarget( hitEnt ) )
			projectile.GrenadeExplode( <0,0,0> )

		return
	}

	projectile.proj.projectileBounceCount++

	EmitSoundOnEntity( projectile, "weapon_softball_grenade_attached_3P" )
	if ( projectile.ProjectileGetMods().contains( "magnetic_rollers" ) )
		projectile.InitMagnetic( 1000.0, "Explo_MGL_MagneticAttract" )

	thread DetonateAfterTime( projectile, FUSE_TIME )
	#endif
}

#if SERVER
void function DetonateAfterTime( entity projectile, float delay )
{
	wait delay
	if ( IsValid( projectile ) )
		projectile.GrenadeExplode( <0,0,0> )
}
#endif