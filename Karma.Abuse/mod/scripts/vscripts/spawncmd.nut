untyped

global function SpawnViper
global function AddCommands
global function KSpawnTitan
global function rpwn
global function SpawnTurretTick

global function registerFunctions
global function registerFunctionsAfter
// global function Respawn



global int TitanGroup = 0
global const currentTitanId = ["npc_titan_atlas_tracker",
							"npc_titan_atlas_tracker_fd_sniper",
							"npc_titan_atlas_tracker_mortar",
							"npc_titan_atlas_tracker_boss_fd",
							"npc_titan_atlas_vanguard",
							"npc_titan_atlas_vanguard_boss_fd",
							"npc_titan_ogre_meteor",
							"npc_titan_ogre_meteor_boss_fd",
							"npc_titan_ogre_minigun",
							"npc_titan_ogre_minigun_boss_fd",
							"npc_titan_ogre_minigun_nuke",
							"npc_titan_stryder_leadwall",
							"npc_titan_stryder_leadwall_arc",
							"npc_titan_stryder_leadwall_boss_fd",
							"npc_titan_stryder_leadwall_shift_core",
							"npc_titan_stryder_rocketeer",
							"npc_titan_stryder_rocketeer_dash_core",
							"npc_titan_stryder_sniper",
							"npc_titan_stryder_sniper_boss_fd",
							"npc_titan_stryder_sniper_fd",
							"npc_titan_atlas_stickybomb",
							"npc_titan_atlas_stickybomb_boss_fd"];


void function registerFunctions()
{
	Remote_RegisterFunction("SpawnViper");
	Remote_RegisterFunction("SpawnTitan");
}
void function registerFunctionsAfter()
{
	// Remote_RegisterFunction("Respawn");
}
void function AddCommands()
{
	#if SERVER
	AddClientCommandCallback("cycletitanid", cycleTitanId);
	AddClientCommandCallback("spawntitan", KSpawnTitan);
	AddClientCommandCallback("spawnturrettick", SpawnTurretTick)
	AddClientCommandCallback("spawnviper", SpawnViper);
	AddClientCommandCallback("rpwn", rpwn);
	AddClientCommandCallback("respawn", rpwn);
	#endif
}

bool function KSpawnTitan(entity a, array<string> args)
{
#if SERVER
    hadGift_Admin = false;
    CheckAdmin(a);//
    if (hadGift_Admin != true) {
        //Kprint( a, "未檢測到管理員權限加個驗證管理員不就行了，還隔這測試崩服？");
		Kprint( a, "未檢測到管理員權限");
        return true;
    }

	entity player = GetPlayerArray()[0];
	vector origin = GetPlayerCrosshairOrigin( player );
	vector angles = player.EyeAngles();
	angles.x = 0;
	angles.z = 0;
	string titanId = currentTitanId[TitanGroup];

	vector spawnPos = origin;
	vector spawnAng = angles;
	int team = TEAM_BOTH;
	var teamTagPos = titanId.find( "#" )
	entity spawnNpc = CreateNPCTitan( "npc_titan", team, spawnPos, spawnAng, [] );
	SetSpawnOption_NPCTitan( spawnNpc, TITAN_HENCH );
	SetSpawnOption_AISettings( spawnNpc, titanId );
	DispatchSpawn( spawnNpc );
	#endif
	return true;
}

bool function cycleTitanId(entity player, array<string> args)
{
	TitanGroup++;
	if (TitanGroup == 22) {
	TitanGroup = 0; }

	#if SERVER
	Kprint( player, currentTitanId[TitanGroup]);
	#endif
	return true;
}

bool function rpwn(entity player, array<string> args)
{
#if SERVER
	hadGift_Admin = false;
	CheckAdmin(player);
	if (hadGift_Admin != true)
	{
		Kprint( player, "未檢測到管理員權限");
		return true;
	}
	// if player only typed rpwn/respawn with no further arguments
	if (args.len() == 0)
	{
		Kprint( player, "有效命令示例: rpwn/respawn <someone/imc/militia/all> [someone/spawn/nothing] [pilot/titan]");
		// print every single player's name and their id
		int i = 0;
		foreach (entity p in GetPlayerArray())
		{
			string playername = p.GetPlayerName();
			Kprint( player, "[" + i.tostring() + "] " + playername);
			i++
		}
		return true;
	}

	array<entity> players = GetPlayerArray();
	array<entity> player1 = []
	entity player2 = null
	CMDsender = player
	switch (args[0])
	{
		case ("all"):
			foreach (entity p in GetPlayerArray())
			{
				if (p != null)
					player1.append(p)
			}
		break;

		case ("imc"):
			foreach (entity p in GetPlayerArrayOfTeam( TEAM_IMC ))
			{
				if (p != null)
					player1.append(p)
			}
		break;

		case ("militia"):
			foreach (entity p in GetPlayerArrayOfTeam( TEAM_MILITIA ))
			{
				if (p != null)
					player1.append(p)
			}
		break;

		default:
            CheckPlayerName(args[0])
				foreach (entity p in successfulnames)
                    player1.append(p)
		break;
	}
	bool ISUSINGTITAN = false
	bool ISSPAWN = false
	if (args.len() > 1) {
		switch (args[1])
		{
			case ("spawn"):
				ISSPAWN = true
			break;

			default:
            	CheckPlayerName(args[1])
				foreach (entity p in successfulnames)
                    player2 = p
			break;
		}

		if (args.len() > 2)
		{
			switch(args[2])
			{
				case ("pilot"):
					ISUSINGTITAN = false
				break;
				case ("titan"):
					ISUSINGTITAN = true
				break;
				default:
					ISUSINGTITAN = false
				break;
			}
		}
	}
	if (args.len() > 3)
	{
		Kprint( player, "參數太多,命令示例: rpwn/respawn <someone/imc/militia/all> [someone/spawn/nothing] [pilot/titan]");
		return true;
	}
	foreach (sheep in player1)
	{
		if (!ISSPAWN)
			Respawn(sheep, player2, ISUSINGTITAN)
		else
			RespawnAtSpawn(sheep, ISUSINGTITAN)
	}
#endif
	return true;
}

void function Respawn(entity player, entity player2 = null, bool ISUSINGTITAN = false)
{
#if SERVER
	try
	{
		if (!ISUSINGTITAN)
		{
			if (player2 == null)
				player.RespawnPlayer(null);
			else if (IsValid(player2))
			{
				player.RespawnPlayer(null)
				player.SetOrigin(player2.GetOrigin())
			}
		} else
		{
			if (!IsAlive(player))
				thread CustomRespawnAsTitan(player, player2)
		}
	} catch(e) { print(e) }
#endif
}

void function CustomRespawnAsTitan(entity player, entity player2 = null)
{
	while( player.IsWatchingKillReplay() )
		WaitFrame()

	player.Signal( "PlayerRespawnStarted" )

	player.isSpawning = true
	entity spawnpoint
	spawnpoint = FindSpawnPoint( player, true, false )
	if (IsValid(player2) && player != null)
	{
		spawnpoint.SetOrigin(player2.GetOrigin())
		spawnpoint.SetAngles(player2.GetAngles())
	}

 	TitanLoadoutDef titanLoadout = GetTitanLoadoutForPlayer( player )

	asset model = GetPlayerSettingsAssetForClassName( titanLoadout.setFile, "bodymodel" )
	Attachment warpAttach = GetAttachmentAtTimeFromModel( model, "at_hotdrop_01", "offset", spawnpoint.GetOrigin(), spawnpoint.GetAngles(), 0 )
	PlayFX( TURBO_WARP_FX, warpAttach.position, warpAttach.angle )

	entity titan = CreateAutoTitanForPlayer_FromTitanLoadout( player, titanLoadout, spawnpoint.GetOrigin(), spawnpoint.GetAngles() )
	DispatchSpawn( titan )
	player.SetPetTitan( null ) // prevent embark prompt from showing up

	AddCinematicFlag( player, CE_FLAG_CLASSIC_MP_SPAWNING ) // hide hud

	// do titanfall scoreevent
	AddPlayerScore( player, "Titanfall", player )

	entity camera = CreateTitanDropCamera( spawnpoint.GetAngles(), < 90, titan.GetAngles().y, 0 > )
	camera.SetParent( titan )

	// calc offset for spawnpoint angle
	// todo this seems bad but too lazy to figure it out rn
	//vector xyOffset = RotateAroundOrigin2D( < 44, 0, 0 >, < 0, 0, 0>, spawnpoint.GetAngles().y )
	//xyOffset.z = 520 // < 44, 0, 520 > at 0,0,0, seems to be the offset used in tf2
	//Kprint( player,  xyOffset )

	vector xyOffset = RotateAroundOrigin2D( < 44, 0, 520 >, < 0, 0, 0 >, spawnpoint.GetAngles().y )

	camera.SetLocalOrigin( xyOffset )
	camera.SetLocalAngles( < camera.GetAngles().x, spawnpoint.GetAngles().y, camera.GetAngles().z > ) // this straight up just does not work lol
	camera.Fire( "Enable", "!activator", 0, player )

	player.EndSignal( "OnDestroy" )
	OnThreadEnd( function() : ( player, titan, camera )
	{
		if ( IsValid( player ) )
		{
			RemoveCinematicFlag( player, CE_FLAG_CLASSIC_MP_SPAWNING ) // show hud
			player.isSpawning = false
		}

		titan.Destroy() // pilotbecomestitan leaves an npc titan that we need to delete
		camera.Fire( "Disable", "!activator", 0, player )
		camera.Destroy()
	})

	waitthread TitanHotDrop( titan, "at_hotdrop_01", spawnpoint.GetOrigin(), spawnpoint.GetAngles(), player, camera ) // do hotdrop anim

	try{player.RespawnPlayer( null )} catch(e1) {print(e1)} // spawn player as pilot so they get their pilot loadout on embark
	player.SetOrigin( titan.GetOrigin() )

	PilotBecomesTitan( player, titan )
}

void function RespawnAtSpawn(entity player, bool ISUSINGTITAN = false)
{
	#if SERVER
	try
	{
		if(!ISUSINGTITAN)
			player.RespawnPlayer(FindSpawnPoint(player, ISUSINGTITAN, false))
		else
			if (!IsAlive(player))
				thread CustomRespawnAsTitan(player, null)
	} catch(e2) { print(e2) }
	#endif
}

bool function SpawnViper(entity player, array<string> args)
{
#if SERVER
    hadGift_Admin = false;
    CheckAdmin(player);//
    if (hadGift_Admin != true) {
        //Kprint( player, "未檢測到管理員權限加个验证管理员不就行了，还隔这测试崩服？");
		Kprint( player, "未檢測到管理員權限");
        return true;
    }

	const CROSSHAIR_VERT_OFFSET = 32;
	string bossId = "Viper";

	TitanLoadoutDef ornull loadout = GetTitanLoadoutForBossCharacter( bossId );
	printt("loadout is null: ", loadout == null );
	if ( loadout == null )
	{
		return true;
	}
	expect TitanLoadoutDef( loadout );
	string baseClass = "npc_titan";
	string aiSettings = GetNPCSettingsFileForTitanPlayerSetFile( loadout.setFile );
	Kprint( player, aiSettings)
	entity player = GetPlayerByIndex( 0 );
	vector origin = GetPlayerCrosshairOrigin( player );
	vector angles = Vector( 0, 0, 0 );
	entity npc = CreateNPC( baseClass, TEAM_IMC, origin, angles );
	if ( IsTurret( npc ) )
	{
		npc.kv.origin -= Vector( 0, 0, CROSSHAIR_VERT_OFFSET );
	}
	SetSpawnOption_AISettings( npc, aiSettings );

	if ( npc.GetClassName() == "npc_titan" )
	{
		string builtInLoadout = expect string( Dev_GetAISettingByKeyField_Global( aiSettings, "npc_titan_player_settings" ) )
		SetTitanSettings( npc.ai.titanSettings, builtInLoadout );
		npc.ai.titanSpawnLoadout.setFile = builtInLoadout;
		OverwriteLoadoutWithDefaultsForSetFile( npc.ai.titanSpawnLoadout ); // get the entire loadout, including defensive and tactical
	}

	SetSpawnOption_NPCTitan( npc, TITAN_MERC );
	SetSpawnOption_TitanLoadout( npc, loadout );
	npc.ai.bossTitanPlayIntro = false;
	//npc.ai.bossTitanPlayOutro = true;
	DispatchSpawn( npc );
	return true;
	#endif
}



bool function SpawnTurretTick( entity player, array<string> args )
{
	hadGift_Admin = false;
	CheckAdmin(player);
	if (hadGift_Admin != true)
	{
		Kprint( player, "未檢測到管理員權限");
		return false;
	}

	if (args.len() > 0)
	{
		Kprint( player, "參數太多" )
		return false
	}
	int team = player.GetTeam()

	vector origin = GetPlayerCrosshairOrigin( player );
	entity tick = CreateFragDrone( team, origin, <0,0,0> )
	SetSpawnOption_AISettings(tick, "npc_frag_drone_fd")
	tick.EnableNPCFlag( NPC_ALLOW_PATROL | NPC_ALLOW_INVESTIGATE | NPC_NEW_ENEMY_FROM_SOUND)
	tick.EnableNPCMoveFlag(NPCMF_WALK_ALWAYS)
	DispatchSpawn( tick )
	tick.Minimap_AlwaysShow( TEAM_IMC, null )
	tick.Minimap_AlwaysShow( TEAM_MILITIA, null )
	tick.SetValueForModelKey( $"models/robots/drone_frag/drone_frag.mdl" )
	StatusEffect_AddEndless( tick, eStatusEffect.speed_boost, 1 )

	tick.SetTitle( "您**的打勾" )
	tick.SetTakeDamageType( DAMAGE_NO )
	tick.SetDamageNotifications( false )
	tick.SetNPCMoveSpeedScale( 10.0 )
	ShowName( tick )


	entity turret = CreateEntity( "npc_turret_sentry" )
	turret.SetOrigin( origin + <0,0,30> )
	turret.SetAngles( <0,0,0> )
	turret.SetBossPlayer( player )
	turret.ai.preventOwnerDamage = true
	turret.StartDeployed()
	SetTeam( turret, team )

	SetSpawnOption_AISettings( turret, "npc_turret_sentry_burn_card_ap_fd" )
	turret.SetParent( tick )
	DispatchSpawn( turret )
	turret.SetMaxHealth(500)
	turret.SetHealth(turret.GetMaxHealth())

	array<entity> players = GetPlayerArrayOfEnemies( tick.GetTeam() )
	if ( players.len() != 0 )
	{
		entity player = GetClosest2D( players, tick.GetOrigin() )
		tick.AssaultPoint( player.GetOrigin() )
	}
	UpdateEnemyMemoryWithinRadius( tick, 1000 )
	thread TickThink( tick )
	return true
}

void function TickThink( entity tick )
{
	array<entity> players
	while( IsAlive( tick ) )
	{
		players = GetPlayerArrayOfEnemies( tick.GetTeam() )
		if ( players.len() != 0 )
		{
			entity player = GetClosest2D( players, tick.GetOrigin() )
			tick.AssaultPoint( player.GetOrigin() )
		}
		wait RandomFloatRange(10.0,20.0)
	}
}
