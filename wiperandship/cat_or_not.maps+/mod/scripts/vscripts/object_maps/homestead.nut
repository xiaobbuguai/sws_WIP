global function placeHomesteadObjects
global function SpawnEnemies
global function SarahDefenseThink

asset TitanBTModel = $"models/titans/buddy/titan_buddy.mdl"

struct CameraPath
{
    array<vector> path
    array<vector> angles
}

struct TimeMeter
{
    float time
    float start
}

void function placeHomesteadObjects()
{
     #if SERVER
     PrecacheParticleSystem( $"P_BT_eye_SM" )
     PrecacheModel( TitanBTModel )
     PrecacheParticleSystem( $"P_s2s_viper_death_fire" )
     PrecacheParticleSystem( $"xo_exp_death_s2s" )
 #endif

    CreateNessy( < -2192, -1198, 89 >, <0, -110, 0>, 11 )
    PrecacheModel( $"models/fx/ar_impact_pilot.mdl" )
    RegisterSignal( "CrouchInIntro" )

    AddClientCommandCallback( "dump_cords", DumpCords )
    AddCallback_OnClientConnected( OnPlayerConnected )
    AddCallback_EntitiesDidLoad( EntitiesDidLoad )
}

void function EntitiesDidLoad()
{
    SpawnBliskKillShop( <1558.58, -1102.14, 904.413>, <0, 0, 0>)//( <1170, -1175, -15>, <0, 45, 0> )
    if ( !GetDisabledElements().contains( "隨機傳送" ) )
    {
        PlaceRandomTeleporter( <4000, -1138, 162> )
        PlaceRandomTeleporter( < -1752, -337, 380 > )
    }

    if ( !GetDisabledElements().contains( "ziplines" ) )
    {
        CreateZipLine( < -440, -804, 180 >, <1021, -1098, 860> )
        CreateZipLine( <1305, -1360, 860>, <2318, -2457, 250> )
        CreateZipLine( <1280, -792, 910>, <803, 1117, 320> )
        CreateZipLine( <1577, -1059, 900>, <3120, -630, 140> )
        CreateZipLine( < -2459, -4394, -121>, < -1861, -4133, 10000 >, 0, 100.0 )
    }
    //CreateSimpleButton( <5279, 1716, 22>, <0, 0, 0>, "呼叫莎拉·布裏格斯支援", callback_SarahBriggsButtonTriggered )
    CreateSimpleButton( <5279, 1716, 76>, <0, 0, 0>, "召喚毒蛇", callback_ValidateVoperRequest , 1.0 )
    //callback_ValidateVoperRequest
    CameraPath path

    path.path.append( < -831.88, 1850.38, 70.6769 > )
    path.angles.append( <0, -58.6212, 0> )
    path.path.append( < -3.66578, 580.79, 345.487 > )
    path.angles.append( <0, -25.9732, 0> )
    path.path.append( <1607.52, -878.249, 447.484> )
    path.angles.append( <0, -39.1732, 0> )
    path.path.append( <3398.84, -990.98, 425.516> )
    path.angles.append( <0, 12.1308, 0> )
    path.path.append( <4755.42, -673.004, 153.179> )
    path.angles.append( <0, -36.5333, 0> )
    path.path.append( <5400.87, -1200.31, 49.3348> )
    path.angles.append( <0, 38.1787, 0> )
    path.path.append( <7292.63, -873.166, -84.6091> )
    path.angles.append( <0, 13.7148, 0> )
    path.path.append( <7292.63, -873.166, -84.6091> )
    path.angles.append( <0, 133.715, 0> )


    SpawnRacingPilot( < -1163, 1267, 316 >, <0, 180, 0>, path )
}

bool function DumpCords( entity player, array<string> args )
{
    printt( "" + player.GetOrigin() )
    printt( "" + player.GetAngles() )

    return true
}

void function OnPlayerConnected( entity player )
{
    AddButtonPressedPlayerInputCallback( player, IN_DUCK, PlayerCrouched )
}

void function PlayerCrouched( entity player )
{
    player.Signal( "CrouchInIntro" )
}

void function SpawnBliskKillShop( vector origin, vector angles ) {

    if ( GetDisabledElements().contains( "blisk" ) )
        return

    entity blisk = CreateEntity( "prop_dynamic" )

    blisk.SetValueForModelKey( $"models/humans/heroes/imc_hero_blisk.mdl" )
	blisk.kv.fadedist = 1000
	blisk.kv.renderamt = 255
	blisk.kv.rendercolor = "81 130 151"
	blisk.kv.solid = SOLID_VPHYSICS

    blisk.SetOrigin( origin )
	blisk.SetAngles( angles )
	DispatchSpawn( blisk )

    blisk.Anim_Play( "blisk_menu_pose" )
    SetTeam( blisk, TEAM_BOTH )

    entity prop = CreateEntity( "prop_dynamic" )

    prop.SetValueForModelKey( $"models/dev/editor_ref.mdl" )
	prop.kv.fadedist = 1000
	prop.kv.renderamt = 255
	prop.kv.rendercolor = "81 130 151"
	prop.kv.solid = SOLID_VPHYSICS


	SetTeam( prop, TEAM_BOTH )
	prop.SetOrigin( origin )
	prop.SetAngles( angles )
	DispatchSpawn( prop )
    prop.Hide()

    prop.SetUsable()
    prop.SetUsableByGroup( "pilot" )
    prop.SetUsePrompts( "按 %use% 為布裏斯克打工", "按 %use% 為布裏斯克打工" )
	thread BliskThink( blisk, prop )
}

void function BliskThink( entity blisk, entity prop )
{
    for(;;)
    {
        prop.SetUsable()
        blisk.SetSkin( 0 )

        entity player = expect entity( prop.WaitSignal( "OnPlayerUse" ).player )

        prop.UnsetUsable()
        blisk.SetSkin( 1 )

        waitthread GetNewTarget( player )

        wait 5
    }
}

void function GetNewTarget( entity player )
{
    EndSignal(player, "OnDestroy")
    EndSignal(player, "OnDeath")

    array<entity> other_players
    foreach ( p in GetPlayerArray() )
    {
        if ( p.GetTeam() != player.GetTeam() )
            other_players.append( p )
    }

    if ( other_players.len() == 0 )
    {
        NSSendPopUpMessageToPlayer( player, "無人可殺" )
        return
    }

    entity target = other_players.getrandom()

    EndSignal( target, "OnDestroy" )
    EndSignal( target, "OnDeath" )

    string unique_id = UniqueString( "GetNewTarget" )

    NSCreateStatusMessageOnPlayer( player, "Kill", target.GetPlayerName(), unique_id )

    OnThreadEnd(
	function() : ( player, target, unique_id, other_players  )
		{
            if ( !IsValid( player ) || other_players.len() == 0 )
                return

            NSDeleteStatusMessageOnPlayer( player, unique_id )

			if ( IsValid( target ) && IsAlive( target ) )
			{
				NSSendPopUpMessageToPlayer( player, "你未能擊殺目標" )
			}
            else
            {
                NSSendPopUpMessageToPlayer( player, "幹得好!" )
                StimPlayer( player, 5 )
            }
		}
	)

    WaitSignal( player, "OnDeath" )
}

void function SpawnRacingPilot( vector origin, vector angles, CameraPath path ) {

    if ( GetDisabledElements().contains( "race" ) )
        return

    entity pilot = CreatePropDynamic( $"models/humans/heroes/mlt_hero_jack.mdl", origin, angles, SOLID_VPHYSICS )

    pilot.Anim_Play( "ACT_MP_CROUCHWALK_FORWARD" )

    pilot.SetUsable()
    pilot.SetUsableByGroup( "pilot" )
    pilot.SetUsePrompts( "按 %use% 開始與傑克庫伯進行跑酷比賽", "按 %use% 開始與傑克庫伯進行跑酷比賽" )

    thread RacingPilotThink( pilot, path )
}

void function RacingPilotThink( entity pilot, CameraPath path  )
{
    for(;;)
    {
        pilot.SetUsable()
        pilot.Show()

        entity player = expect entity( pilot.WaitSignal( "OnPlayerUse" ).player )

        pilot.UnsetUsable()
        pilot.Hide()

        waitthread StartRaceIntro( player, pilot, path )

        wait 5
    }
}

void function StartRaceIntro( entity player, entity pilot, CameraPath path  )
{
    player.EndSignal( "OnDeath" )
    player.EndSignal( "OnDestroy" )

    waitthread HandleRaceIntroCamera( player, path )
    player.SetOrigin( < -831, 1850, 75 > )

    entity pilot = CreateElitePilot( 1, <0,1000,10000>, <0,0,0> )
    pilot.SetModel( $"models/humans/heroes/mlt_hero_jack.mdl" )
    DispatchSpawn( pilot )
    pilot.SetModel( $"models/humans/heroes/mlt_hero_jack.mdl" )
    pilot.Freeze()
    thread PlayRecoding_recording_race_homestead_1( pilot )

    entity finishline = CreatePropDynamic( $"models/fx/ar_impact_pilot.mdl", path.path[ path.path.len() - 1 ], <0,0,0>, SOLID_VPHYSICS )

    TimeMeter time

    time.time = Time()
    time.start = Time()

    string unique_id = UniqueString( "Race" )

    NSCreateStatusMessageOnPlayer( player, "Time", "" + ( time.time - time.start ), unique_id )

    OnThreadEnd(
		function() : ( player, finishline, time, unique_id )
		{
            if ( IsAlive( player ) )
            {
                NSSendAnnouncementMessageToPlayer(player, "Your Time Is " + ( time.time - time.start ) + " seconds", "", <1,1,0>, 1, 0 )
            }

            if ( IsValid( player ) )
                NSDeleteStatusMessageOnPlayer( player, unique_id )
			if ( IsValid( finishline ) )
                finishline.Destroy()
		}
	)

    for(;;)
    {
        if ( Distance2D( player.GetOrigin(), finishline.GetOrigin() ) < 200.0 )
            break

        time.time = Time()

        NSEditStatusMessageOnPlayer( player, "Time", "" + ( time.time - time.start ), unique_id )

        wait 0.1
    }
}

void function HandleRaceIntroCamera( entity player, CameraPath path  )
{
    if ( !IsValid( player ) || !IsAlive( player ) )
        return

    NSSendInfoMessageToPlayer( player, "按蹲下結束預覽賽道" )

    player.EndSignal( "OnDeath" )
    player.EndSignal( "OnDestroy" )
    player.EndSignal( "CrouchInIntro" )

    entity mover
    entity camera
    entity finishline = CreatePropDynamic( $"models/fx/ar_impact_pilot.mdl", path.path[ path.path.len() - 1 ], <0,0,0>, SOLID_VPHYSICS )

    OnThreadEnd(
		function() : ( player, camera, mover, finishline )
		{
            if ( IsValid( player ) )
            {
                ViewConeFree( player )
                player.ClearParent()
                RemoveCinematicFlag( player, CE_FLAG_HIDE_MAIN_HUD )
                DeployAndEnableWeapons( player )
                player.ClearInvulnerable()
                player.AnimViewEntity_SetLerpOutTime( 1 )
                player.AnimViewEntity_Clear()
                player.ClearViewEntity()
            }

			if ( IsValid( camera ) )
                camera.Destroy()
            if ( IsValid( mover ) )
                mover.Destroy()
            if ( IsValid( finishline ) )
                finishline.Destroy()
		}
	)

    player.SetInvulnerable()

    vector angles = <0,0,0>

    camera = CreateEntity( "point_viewcontrol" )
    camera.kv.spawnflags = 56 // infinite hold time, snap to goal angles, make player non-solid
    camera.SetOrigin( player.GetOrigin() )
    camera.SetAngles( angles )
    DispatchSpawn( camera )

    player.SetViewEntity( camera, true )
    // EntFireByHandle( camera, "Enable", "!activator", 0, player, null )
    mover = CreateExpensiveScriptMover( player.GetOrigin(), angles )
    camera.SetParent( mover )

    player.SetAngles( angles )
    HolsterAndDisableWeapons( player )
    AddCinematicFlag( player, CE_FLAG_HIDE_MAIN_HUD  )
    player.PlayerCone_SetLerpTime( 0.5 )
    player.PlayerCone_FromAnim()
    player.PlayerCone_SetMinYaw( 0 )
    player.PlayerCone_SetMaxYaw( 0 )
    player.PlayerCone_SetMinPitch( 0 )
    player.PlayerCone_SetMaxPitch( 0 )

    for ( int index = 0; index < path.path.len(); index++ )
    {
        mover.NonPhysicsMoveTo( path.path[index] + <0,0,100>, 1, 0.1, 0.1 )
        mover.NonPhysicsRotateTo( path.angles[index], 0.2, 0.1, 0.1 )

        wait 2
    }

    wait 2
}

void function PlaceRandomTeleporter( vector origin )
{
    CreateSimpleButton( origin, <0, 90, 0>, "隨機傳送", callback_RandTelportButtonTriggered )
}

void function callback_RandTelportButtonTriggered( entity panel, entity player )
{
    array<entity> teleportPoints = SpawnPoints_GetTitan()

    entity point = teleportPoints.getrandom()

    thread DelayedTeleportPlayerTo( player, point.GetOrigin(), 2.0 )
}

void function DelayedTeleportPlayerTo( entity player, vector origin, float time )
{
    float fadeTime = 0.5
    float holdTime = time
    ScreenFade( player, 0, 1, 0, 255, fadeTime, holdTime, FFADE_OUT | FFADE_PURGE )

    PhaseShift( player, 0.1, time )

    wait 1

    player.SetOrigin( origin )
}

void function callback_SarahBriggsButtonTriggered( entity panel, entity player )
{
    //if ( GetDisabledElements().contains( "sarah_nessie" ) )
    //    return

    //if ( !HasAllNessies() )
    //{
    //    NSSendPopUpMessageToPlayer( player, "You don't have all the nessies [" + CountNessy() + " out of 4 ]" )
    //    return
    //}

    ResetNessy()

    thread SarahDefenseThink( TEAM_MILITIA )
}

void function SarahDefenseThink( int team )
{
    entity sarah = CreateNPC( "npc_soldier", team, <4516, -3006, 10000>, <0,0,0> )
    SetSpawnOption_AISettings( sarah, "npc_soldier_hero_sarah")
    DispatchSpawn( sarah )
    sarah.SetInvulnerable()
    foreach ( entity player in GetPlayerArray() ){
    Chat_ServerPrivateMessage( player, "开始任务：布裏格斯指揮官的咖啡夢", false )
    Chat_ServerPrivateMessage( player, "Part3：惊險逃亡", false )
    }
    wait 1

    entity titan = CreateNPCTitan( "npc_titan_atlas", team, <4188, -3188, 128>, <0,0,0>, [] )
    // SetSpawnOption_NPCTitan( spawnNpc, TITAN_HENCH )
    SetSpawnOption_AISettings( titan, "npc_titan_atlas_vanguard" )
    // SetSpawnOption_Titanfall( spawnNpc )
    DispatchSpawn( titan )

    SarahBecomesTitan( sarah, titan )

    thread NPCTitanHotdrops( titan, true, "at_hotdrop_drop_2knee_turbo_upgraded" )

    titan.WaitSignal( "TitanHotDropComplete" )

	wait 1

    foreach ( entity player in GetPlayerArray() )
    Chat_ServerPrivateMessage( player, "[莎拉] 該死，小b派毒蛇擊落了我們的飛船，鐵馭們，我需要你們的幫助", false )

    sarah = SarahBecomesPilot( titan )
    SarahDisembarksTitan( sarah, titan )
    thread TitanStanceThink( sarah, titan )

    EmitSoundOnEntity( sarah, "commander_sarah_frontier" )

    ShipStruct ship = SpawnDropShipLight( WorldToLocalOrigin( <4331, -4628, 174> ), <0,0,0>, team, true )
    entity model = ship.model

    model.SetPusher( true )

    thread PlayAnim( model, "dropship_open_doorR", ship.mover)

    ShipFlyToPos( ship, CLVec( <4237, -3130, 250> ), <0,90,0> )
    model.SetMaxHealth( 20000 )
	model.SetHealth( model.GetMaxHealth() )

    model.EndSignal( "OverDamaged" )
    EndSignal( ship, "engineFailure_Complete" )
    model.EndSignal( "OnDeath" )
    model.EndSignal( "OnDestroy" )

    OnThreadEnd(
		function() : ( ship, sarah )
		{
            Ship_CleanDelete( ship )

            if ( !IsValid( sarah ) )
                return

            foreach ( entity player in GetPlayerArray() )
                NSSendInfoMessageToPlayer( player, "莎拉去世，在座各位都有責任" )
		}
	)

    WaitSignal( ship, "Goal" )
    StopSoundOnEntity( model, "amb_emit_s2s_distant_ambient_ships" )

    titan.Die()

    wait 0.5

    foreach ( entity player in GetPlayerArray() )
    {
        if ( player.GetTeam() == team )
            NSSendInfoMessageToPlayer( player, "保護莎拉·布裏格斯指揮官！" )
        else
            NSSendInfoMessageToPlayer( player, "攻擊莎拉·布裏格斯指揮官！" )
    }

    PhaseShift( sarah, 0 , 0.1 )
    GoblinRiderAnimate( sarah, model, 0, "RESCUE" )
    TakeAllWeapons( sarah )
    sarah.GiveWeapon( "mp_weapon_r97" )

    ShipFlyToPos( ship, CLVec( <4338.17, -2177.24, 207.729> ), <0, 83.8166, 0> )
    WaitSignal( ship, "Goal" )
    ShipFlyToPos( ship, CLVec( <3072.83, -3063.96, 559.819> ), <0, -145.943, 0> )
    WaitSignal( ship, "Goal" )
    StopSoundOnEntity( model, "amb_emit_s2s_distant_ambient_ships" )
    EmitSoundOnEntity( model, "amb_emit_s2s_rushing_wind_strong_v2_02b" )
    SpawnEnemies( <2035, -3852, 251>, 10, GetOtherTeam( team ), sarah )
    foreach ( entity player in GetPlayerArray() )
    Chat_ServerPrivateMessage( player, "[莎拉] 打下那些無人機！", false )
    ShipFlyToPos( ship, CLVec( <484.674, -2599.3, 92.5172> ), <0, 156.329, 0> )
    WaitSignal( ship, "Goal" )
    ShipFlyToPos( ship, CLVec( < -1657.06, -1996.03, 183.811> ), <0, 171.544, 0> )
    WaitSignal( ship, "Goal" )
    StopSoundOnEntity( model, "amb_emit_s2s_distant_ambient_ships" )
    EmitSoundOnEntity( model, "amb_emit_s2s_rushing_wind_strong_v2_02b" )
    ShipFlyToPos( ship, CLVec( < -3007.45, -1467.8, 431.422> ), <0, 90.4965, 0> )
    WaitSignal( ship, "Goal" )
    ShipFlyToPos( ship, CLVec( < -2889.21, 327.515, 360.658> ), <0, 54.1525, 0> )
    WaitSignal( ship, "Goal" )
    StopSoundOnEntity( model, "amb_emit_s2s_distant_ambient_ships" )
    EmitSoundOnEntity( model, "amb_emit_s2s_rushing_wind_strong_v2_02b" )
    SpawnEnemies( < -3973, 7, 200 >, 10, GetOtherTeam( team ), sarah )
    ShipFlyToPos( ship, CLVec( < -1679.48, 1239.38, 410.723> ), <0, 3.11249, 0> )
    WaitSignal( ship, "Goal" )
    ShipFlyToPos( ship, CLVec( < -926.755, 1153.32, 399.599> ), <0, 20.7125, 0> )
    WaitSignal( ship, "Goal" )
    StopSoundOnEntity( model, "amb_emit_s2s_distant_ambient_ships" )
    EmitSoundOnEntity( model, "amb_emit_s2s_rushing_wind_strong_v2_02b" )
    ShipFlyToPos( ship, CLVec( <1775.36, 389.589, 606.904> ), <0, -24.8715, 0> )
    WaitSignal( ship, "Goal" )
    ShipFlyToPos( ship, CLVec( <2623.65, 54.2617, 436.046> ), <0, 53.0085, 0> )
    WaitSignal( ship, "Goal" )
    StopSoundOnEntity( model, "amb_emit_s2s_distant_ambient_ships" )
    EmitSoundOnEntity( model, "amb_emit_s2s_rushing_wind_strong_v2_02b" )
    SpawnEnemies( <2154, 2749, 200>, 10, GetOtherTeam( team ), sarah )
    ShipFlyToPos( ship, CLVec( <4250.51, 2382.66, 100> ), <0, 54.9445, 0> )
    WaitSignal( ship, "Goal" )

    wait 1

    sarah.ClearParent()
    sarah.Anim_Stop()

    wait 1

    Signal( ship, "FakeDestroy" )
	entity mover = ship.mover
	mover.NonPhysicsStop()
	mover.SetPusher( false )
    ShipSetInvulnerable( ship )

    ShipFlyToPos( ship, CLVec( mover.GetOrigin() + <0,10000,2000> ), <0,0,0> )

    foreach ( vector o in [ <4616, 2543, -54>, <4017, 2748, -20> ] )
    {
        entity turret = CreateNPC( "npc_turret_mega", team, o - <0,0,1000>, <0,0,0> )
        SetSpawnOption_AISettings( turret, "npc_turret_mega_frontierdefense")
        DispatchSpawn( turret )

        SetTeam( turret, team )
        turret.SetMaxHealth( 1500*10 )
        turret.SetHealth( 1500*10 )

        entity mover = CreateScriptMover( turret.GetOrigin(), turret.GetAngles() )
        turret.SetParent( mover )

        mover.NonPhysicsMoveTo( o, 5, 0.1, 0.1 )
    }

    wait 5
    SpawnEnemies( <2154, 2749, 200>, 10, GetOtherTeam( team ), sarah )
    entity newtitan = CreateNPCTitan( "npc_titan_atlas", team, sarah.GetOrigin(), <0,0,0>, [] )
    SetSpawnOption_NPCTitan( newtitan, TITAN_HENCH )
    SetSpawnOption_AISettings( newtitan, "npc_titan_atlas_vanguard" )
    newtitan.SetModel( TitanBTModel )
    DispatchSpawn( newtitan )
    newtitan.SetMaxHealth( newtitan.GetMaxHealth() * 5 );
    newtitan.SetHealth( newtitan.GetMaxHealth() )

    thread NPCTitanHotdrops( newtitan, true, "at_hotdrop_drop_2knee_turbo_upgraded" )

    newtitan.WaitSignal( "TitanHotDropComplete" )

    wait 1

    sarah.ClearInvulnerable()
    SarahEmbarksTitan( sarah, newtitan )

    wait 1

    foreach ( entity player in GetPlayerArray() )
    Chat_ServerPrivateMessage( player, "[莎拉] 那些無人機會阻止飛船起飛，把它們都幹掉", false )

    newtitan.ClearInvulnerable()
    newtitan.AssaultPoint( newtitan.GetOrigin() )
    newtitan.AssaultSetFightRadius( 2000 )

    EndSignal( newtitan, "OnDeath" )
    EndSignal( newtitan, "OnDestroy" )

    ShipStruct sarahShip

    OnThreadEnd(
		function() : ( newtitan, sarahShip )
		{
            if ( IsAlive( newtitan ) )
            {
                newtitan.Die()
                Ship_CleanDelete( sarahShip )

                foreach ( entity player in GetPlayerArray() ){
                    NSSendInfoMessageToPlayer( player, "莎拉從毒蛇的攻擊中幸存，並給了每名鐵馭一杯激素咖啡" )
                    StimPlayer( player, 90 )
                }
            }
            else {
                foreach ( entity player in GetPlayerArray() )
                    NSSendInfoMessageToPlayer( player, "莎拉去世，在座各位都有責任" )
            }

		}
	)

    foreach ( entity player in GetPlayerArray() )
    {
        if ( player.GetTeam() == team )
            NSSendInfoMessageToPlayer( player, "保護莎拉·布裏格斯指揮官！直到消滅所有敵人" )
    }

    //SpawnEnemies( <4650, 1936, 60>, 5, team, newtitan )
    //SpawnEnemies( <3587, 2426, 70>, 5, team, newtitan )

    for(;;)
    {
        if( GetEntArrayByScriptName( "phase4_ents" ).len() == 0){
            break
        }
    wait 0.1
    }
    thread MissionEND()
    newtitan.SetInvulnerable()
    sarahShip = SpawnDropShipLight( WorldToLocalOrigin( newtitan.GetOrigin() ), <0,0,0>, team, true )
    mover = sarahShip.model
    mover.Hide()
    mover.NotSolid()
    SetTeam( mover, TEAM_UNASSIGNED )

    mover.SetAngles( <0,-120,0> )
	newtitan.SetParent( mover, "", false, 0 )
    newtitan.SetAngles( <0,-120,0> )
    newtitan.SetInvulnerable()

	sarahShip.model = newtitan
	sarahShip.boundsMinRatio 	= 0.5
	sarahShip.defBankTime		= 0.5	//1.5
	sarahShip.defAccMax 		= 500	//350
	sarahShip.defSpeedMax 		= 1000	//500
	sarahShip.defRollMax 		= 15
	sarahShip.defPitchMax 		= 3
	// sarahShip.FuncGetBankMagnitude = ViperBankMagnitude

    InitEmptyShip( sarahShip )
    //thread RunJetSfx( newtitan )
    //thread AnimateViper( newtitan )

    wait 1

    ShipFlyToPos( sarahShip, CLVec( newtitan.GetOrigin() + < 0, 0, 1000 > ), <0,-120,0> )

    WaitSignal( sarahShip, "Goal" )

    if ( IsValid( GetRodeoPilot( newtitan ) ) )
        ThrowRiderOff( GetRodeoPilot( newtitan ), newtitan, newtitan.GetVelocity() )

    newtitan.SetNumRodeoSlots( 2 )

    ShipFlyToPos( sarahShip, CLVec( newtitan.GetOrigin() + <0,10000,3000> ), <0,-120,0> )

    if ( IsValid( GetRodeoPilot( newtitan ) ) )
        ThrowRiderOff( GetRodeoPilot( newtitan ), newtitan, newtitan.GetVelocity() )

    WaitSignal( sarahShip, "Goal" )

    ShipFlyToPos( sarahShip, CLVec( newtitan.GetOrigin() - <0,0,3000> ), <0,-120,0> )

    WaitSignal( sarahShip, "Goal" )

    sarah = newtitan
}

void function SpawnEnemies( vector origin, int amount, int team, entity target )
{
    for( int i = 0; i < amount; i++ )
    {
        entity npc = CreateNPC( "npc_drone", team, origin, <0,0,0>);
        SetSpawnOption_AISettings( npc, "npc_drone_beam");
        DispatchSpawn( npc );

        int followBehavior = GetDefaultNPCFollowBehavior( npc )
        npc.InitFollowBehavior( target, followBehavior )
        npc.EnableBehavior( "Follow" )
        npc.SetEnemy( target )
        npc.SetScriptName( "phase4_ents" )
    }
}

// taken from _ai_pilots.gnut
void function SarahBecomesTitan( entity pilot, entity titan )
{
	Assert( IsAlive( pilot ) )
	Assert( IsAlive( titan ) )
	Assert( IsGrunt( pilot ) || IsPilotElite( pilot ) )
	Assert( titan.IsTitan() )

	entity titanSoul = titan.GetTitanSoul()

	titanSoul.soul.seatedNpcPilot.isValid				= true

	titanSoul.soul.seatedNpcPilot.team 					= pilot.GetTeam()
	titanSoul.soul.seatedNpcPilot.spawnflags 			= 0
	titanSoul.soul.seatedNpcPilot.accuracy 				= expect string( pilot.kv.AccuracyMultiplier ).tofloat()
	titanSoul.soul.seatedNpcPilot.proficieny 			= expect string( pilot.kv.WeaponProficiency ).tofloat()
	titanSoul.soul.seatedNpcPilot.health 				= expect string( pilot.kv.max_health ).tofloat()
	titanSoul.soul.seatedNpcPilot.physDamageScale 		= expect string( pilot.kv.physdamagescale ).tofloat()
	titanSoul.soul.seatedNpcPilot.weapon 				= pilot.GetMainWeapons()[0].GetWeaponClassName()
	titanSoul.soul.seatedNpcPilot.squadName 			= expect string( pilot.kv.squadname )

	titanSoul.soul.seatedNpcPilot.modelAsset 			= pilot.GetModelName()
	titanSoul.soul.seatedNpcPilot.title 				= pilot.GetTitle()

	titanSoul.soul.seatedNpcPilot.isInvulnerable		= pilot.IsInvulnerable()

	titan.SetTitle( titanSoul.soul.seatedNpcPilot.title )

	// thread __TitanPilotRodeoCounter( titan )

	// ScriptCallback_OnNpcPilotBecomesTitan( pilot, titan )

	pilot.Destroy()
}

void function SarahDisembarksTitan( entity pilot, entity titan )
{
	titan.ContextAction_SetBusy()
	pilot.ContextAction_SetBusy()

	if ( pilot.GetTitle() != "" )
	{
		titan.SetTitle( pilot.GetTitle() + "'s Titan" )
	}

	bool isInvulnerable = pilot.IsInvulnerable()
	pilot.SetInvulnerable()
	titan.SetInvulnerable()

	string pilot3pAnim
    string pilot3pAudio
    string titanDisembarkAnim
	string titanSubClass = GetSoulTitanSubClass( titan.GetTitanSoul() )
	bool standing = titan.GetTitanSoul().GetStance() >= STANCE_STANDING // STANCE_STANDING = 2, STANCE_STAND = 3

	if ( standing )
	{
		titanDisembarkAnim = "at_dismount_stand"
		pilot3pAnim = "pt_dismount_" + titanSubClass + "_stand"
		pilot3pAudio = titanSubClass + "_Disembark_Standing_3P"
	}
	else
	{
		titanDisembarkAnim = "at_dismount_crouch"
		pilot3pAnim = "pt_dismount_" + titanSubClass + "_crouch"
		pilot3pAudio = titanSubClass + "_Disembark_Kneeling_3P"
	}

//	pilot.SetParent( titan, "hijack" )
	EmitSoundOnEntity( titan, pilot3pAudio )
	thread PlayAnim( titan, titanDisembarkAnim )
	waitthread PlayAnim( pilot, pilot3pAnim, titan, "hijack" )

	//pilot.ClearParent()
	titan.ContextAction_ClearBusy()
	pilot.ContextAction_ClearBusy()
	if ( !isInvulnerable )
		pilot.ClearInvulnerable()
	titan.ClearInvulnerable()

	if ( !standing )
		SetStanceKneel( titan.GetTitanSoul() )
}

entity function SarahBecomesPilot( entity titan )
{
	Assert( IsValid( titan ) )
	Assert( titan.IsTitan() )

	entity titanSoul = titan.GetTitanSoul()
	titanSoul.soul.seatedNpcPilot.isValid = false

	string weapon 			= titanSoul.soul.seatedNpcPilot.weapon
	string squadName 		= titanSoul.soul.seatedNpcPilot.squadName
	asset model 			= titanSoul.soul.seatedNpcPilot.modelAsset
	string title 			= titanSoul.soul.seatedNpcPilot.title
	int team 				= titanSoul.soul.seatedNpcPilot.team
	vector origin 			= titan.GetOrigin()
	vector angles 			= titan.GetAngles()
	entity pilot 			= CreateNPC( "npc_soldier", team, origin, angles )
    SetSpawnOption_AISettings( pilot, "npc_soldier_hero_sarah" )

	SetSpawnOption_Weapon( pilot, weapon )
	SetSpawnOption_SquadName( pilot, squadName )
	pilot.SetValueForModelKey( model )
	DispatchSpawn( pilot )
	pilot.SetModel( model ) // this is a hack, trying to avoid having a model spawn option because its easy to abuse

	// NpcPilotSetPetTitan( pilot, titan )
	// NpcResetNextTitanRespawnAvailable( pilot )

	pilot.kv.spawnflags 			= titanSoul.soul.seatedNpcPilot.spawnflags
	pilot.kv.AccuracyMultiplier 	= titanSoul.soul.seatedNpcPilot.accuracy
	pilot.kv.WeaponProficiency 		= titanSoul.soul.seatedNpcPilot.proficieny
	pilot.kv.health 				= titanSoul.soul.seatedNpcPilot.health
	pilot.kv.max_health 			= titanSoul.soul.seatedNpcPilot.health
	pilot.kv.physDamageScale 		= titanSoul.soul.seatedNpcPilot.physDamageScale

	if ( titanSoul.soul.seatedNpcPilot.isInvulnerable )
		pilot.SetInvulnerable()

	titan.SetOwner( pilot )
	// NPCFollowsNPC( titan, pilot )

	// UpdateEnemyMemoryFromTeammates( pilot )

	return pilot
}

void function SarahEmbarksTitan( entity pilot, entity titan )
{
	titan.EndSignal( "OnDestroy" )
	titan.EndSignal( "OnDeath" )

	OnThreadEnd(
		function () : ( titan, pilot )
		{
			if ( IsAlive( titan ) )
			{
				if ( titan.ContextAction_IsBusy() )
					titan.ContextAction_ClearBusy()
				titan.ClearInvulnerable()

				Assert( !IsAlive( pilot ) )
			}
		}
	)

	bool isInvulnerable = pilot.IsInvulnerable()
	pilot.SetInvulnerable()
	titan.SetInvulnerable()

	string titanSubClass = GetSoulTitanSubClass( titan.GetTitanSoul() )
	table ornull embarkSet = expect table ornull( FindBestEmbark( pilot, titan, false ) )
	if ( !embarkSet )
    {
        SarahBecomesTitan( pilot, titan )
		return
    }

    expect table( embarkSet )
    table e = expect table( embarkSet.animSet )

	string pilotAnim = GetAnimFromAlias( titanSubClass, e.thirdPersonKneelingAlias )
	string titanAnim = expect string( e.titanKneelingAnim )

	if ( !titan.ContextAction_IsBusy() ) //might be set from kneeling
		titan.ContextAction_SetBusy()
	pilot.ContextAction_SetBusy()

    e = expect table( embarkSet.audioSet )

	//pilot.SetParent( titan, "hijack", false, 0.5 ) //the time is just in case their not exactly at the right starting position
	EmitSoundOnEntity( titan, expect string( e.thirdPersonKneelingAudioAlias ) )
	thread PlayAnim( pilot, pilotAnim, titan, "ORIGIN" )
	waitthread PlayAnim( titan, titanAnim )

	if ( !isInvulnerable )
		pilot.ClearInvulnerable()

	SarahBecomesTitan( pilot, titan )
}

void function TitanStanceThink( entity pilot, entity titan )
{
	if ( !IsAlive( titan ) )
		return

	if ( titan.GetTitanSoul().IsDoomed() )
		return

	titan.EndSignal( "OnDeath" )
	titan.EndSignal( "OnDestroy" )
	titan.EndSignal( "NpcPilotBecomesTitan" )

	WaittillAnimDone( titan ) //wait for disembark anim

	// kneel in certain circumstances
	// while ( IsAlive( pilot ) )
	// {
	// 	if ( !ChangedStance( titan ) )
	// 		waitthread TitanWaitsToChangeStance_or_PilotDeath( pilot, titan )
	// }

	if ( titan.GetTitanSoul().GetStance() < STANCE_STANDING )
	{
		while ( !TitanCanStand( titan ) )
			wait 2

		TitanStandUp( titan )
	}
}

void function Ship_CleanDelete( ShipStruct ship )
{
	if ( IsValid( ship.mover ) )
	{
		FakeDestroy( ship )
		if ( IsValid( ship.mover ) )
			ship.mover.Destroy()
	}
}