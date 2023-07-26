untyped


global function OnProjectileCollision_Brute4_QuadRocket

void function OnProjectileCollision_Brute4_QuadRocket( entity projectile, vector pos, vector normal, entity hitEnt, int hitbox, bool isCritical )
{
	#if SERVER
		array<string> mods = projectile.ProjectileGetMods()
		if ( mods.contains( "cluster_payload" ) )
		{
			entity owner = projectile.GetOwner()
			if ( IsValid( owner ) )
			{
				PopcornInfo popcornInfo
				// Clusters share explosion radius/damage with the base weapon
				// Clusters spawn '((int) (count/groupSize) + 1) * groupSize' total subexplosions (thanks to a '<=')
				// The ""base delay"" between each group's subexplosion on average is ((float) duration / (int) (count / groupSize))
				// The actual delay is (""base delay"" - delay). Thus 'delay' REDUCES delay. Make sure delay + offset < ""base delay"".

				// Current:
				// 9 count, 0.3 delay, 2.4 duration, 3 groupSize
				// Total: 12 subexplosions
				// ""Base delay"": 0.8s, avg delay between (each group): 0.5s, total duration: 2.0s
				popcornInfo.weaponName = "mp_titanweapon_brute4_quad_rocket"
				popcornInfo.weaponMods = projectile.ProjectileGetMods()
				popcornInfo.damageSourceId = eDamageSourceId.mp_titanability_cluster_payload
				popcornInfo.count = 9
				popcornInfo.delay = mods.contains( "rapid_detonator" ) ? 0.4 : 0.3 // Avg delay and duration -20%
				popcornInfo.offset = 0.15
				popcornInfo.range = 200
				popcornInfo.normal = normal
				popcornInfo.duration = 2.4
				popcornInfo.groupSize = 3
				popcornInfo.hasBase = false

				thread Brute4_StartClusterExplosions( projectile, owner, popcornInfo, CLUSTER_ROCKET_FX_TABLE )
			}
		}
	#endif
}