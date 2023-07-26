untyped
global function placeDrydockObjects
global function CraneCreate
global function setupSarahRecord

int MissionAlreadyComplete = 0


const vector turretSpawn = < -256, 1, 480 >

struct
{
    entity turret_mega
    entity door1
    entity door2
    bool open = false
    bool sarahSpawned = false
}
file

void function placeDrydockObjects()
{
    PrecacheModel( $"models/levels_terrain/mp_drydock/dd_warehouse14_panel_01.mdl" )
    PrecacheModel( $"models/beacon/beacon_crane_yellow.mdl" )

    InitKeyTracking()
    CraneCreate( <2669,-2911,107>, <0,0,0> )
    CraneCreate( <2751, 3174, 261>, <0,0,0> )
    CraneCreate( < -1878, 3028, 291 >, <0,0,0> )

    CreateNessy( <43, 6578, 1653>, <0, -110, 0>, 12 )

    //CreateSimpleButton( <3237, 325, 410>, <180, 180, 0>, "to know when will Iniquity stream", Callback_MessageButtonTriggered, 60 )
    CreateSimpleButton( <2706, 339, 294 >, <0, 0, 0>, "控製下方大門", MoveDoors, 20 )

    file.door1 = CreateExpensiveScriptMoverModel( $"models/levels_terrain/mp_drydock/dd_warehouse14_panel_01.mdl", <2518, 134, 66>, <0,90,0>, SOLID_VPHYSICS, 10000 )
    file.door2 = CreateExpensiveScriptMoverModel( $"models/levels_terrain/mp_drydock/dd_warehouse14_panel_01.mdl", <2518, 534, 66>, <0,90,0>, SOLID_VPHYSICS, 10000 )

    entity door1 = CreateExpensiveScriptMoverModel( $"models/levels_terrain/mp_drydock/dd_warehouse14_panel_01.mdl", <2518, 134, 66>, <0,90,0>, SOLID_VPHYSICS, 10000 )
    entity door2 = CreateExpensiveScriptMoverModel( $"models/levels_terrain/mp_drydock/dd_warehouse14_panel_01.mdl", <2518, 534, 66>, <0,90,0>, SOLID_VPHYSICS, 10000 )

    door1.SetOrigin( door1.GetOrigin() + <300,0,0> )
    door2.SetOrigin( door2.GetOrigin() + <300,0,0> )
    door1.SetParent( file.door1 )
    door2.SetParent( file.door2 )

    file.door1.NonPhysicsMoveTo( file.door1.GetOrigin() + < -500,0,0 >, 1, 0.1, 0.1 )
    file.door2.NonPhysicsMoveTo( file.door2.GetOrigin() + < -500,0,0 >, 1, 0.1, 0.1 )


    CreatePhaseTeleporter( <3239.73, 330.218, 256.031>, <2264.4, 329.618, 352.031> )
    CreatePhaseTeleporter( <3948.34, -4299.16, -103.383>, < -2975.38, 2556.51, -119.969 > )


    AddCallback_EntitiesDidLoad( EntitiesDidLoad )
}

void function EntitiesDidLoad()
{
    entity panel = CreateHackPanel( < -318, 1, 408 >, <0,180,0>, OnPanelHacked )

	// Highlight_SetNeutralHighlight( panel, "sp_enemy_pilot" )

    if ( !GetDisabledElements().contains( "missions_from_sarah" ) )
        panel = CreateHackPanel( <747, -1929, 416>, <0,90,0>, OnPanelHacked2 )

	// Highlight_SetNeutralHighlight( panel, "sp_enemy_pilot" )

    file.turret_mega = CreateNPC( "npc_turret_mega", TEAM_UNASSIGNED, turretSpawn, <0,0,0> )
    SetSpawnOption_AISettings( file.turret_mega, "npc_turret_mega")
    // file.turret_mega.kv.solid = SOLID_VPHYSICS
    DispatchSpawn( file.turret_mega )
}

void function Callback_MessageButtonTriggered( entity button, entity player )
{
    Chat_ServerPrivateMessage( player, "idk lol", false )
}

void function MoveDoors( entity button, entity player )
{
    int x = 680
    if ( file.open )
        x *= -1

    file.door1.NonPhysicsMoveTo( file.door1.GetOrigin() + < x,0,0 >, 1, 0.1, 0.1 )
    file.door2.NonPhysicsMoveTo( file.door2.GetOrigin() + < x,0,0 >, 1, 0.1, 0.1 )

    file.open = !file.open
}

function OnPanelHacked( panel, player )
{
	expect entity( panel )
	expect entity( player )

	print( panel + " was hacked by " + player )

    file.turret_mega.Destroy()
    file.turret_mega = CreateNPC( "npc_turret_mega", player.GetTeam(), turretSpawn, <0,0,0> )
    SetSpawnOption_AISettings( file.turret_mega, "npc_turret_mega_frontierdefense")
    // file.turret_mega.kv.solid = SOLID_VPHYSICS
    DispatchSpawn( file.turret_mega )

	SetTeam( file.turret_mega, player.GetTeam() )
    // file.turret_mega.SetOwner( player )
    file.turret_mega.SetMaxHealth( 1500*10 )
    file.turret_mega.SetHealth( 1500*10 )
    file.turret_mega.SetBossPlayer( player )
    // TakeAllWeapons( file.turret_mega )
    // file.turret_mega.GiveWeapon( "mp_weapon_gunship_missile" )
}

function OnPanelHacked2( panel, player )
{

    expect entity( panel )
	expect entity( player )

    print( panel + " was hacked by " + player )

    if ( MissionAlreadyComplete == 1){
        NSSendPopUpMessageToPlayer( player, "任務已被完成，你來晚了" )
        return
        }
    if ( file.sarahSpawned )
        return
    file.sarahSpawned = true

    vector origin = panel.GetForwardVector() * 400 + panel.GetOrigin() + <0,0,10>
    if ( MissionAlreadyComplete == 0){
    thread SarahEscortThink( origin, player )
        }
    wait 5
    //NSSendPopUpMessageToPlayer( player, "test" )
}

void function SarahEscortThink( vector origin, entity player )
{
    entity ref
    ShipStruct ship =  SpawnCrowLight( CLVec( <623, 5989, 400 > ), <0,90,0>, true )

    Chat_ServerPrivateMessage( player, "开始任务：布裏格斯指揮官的咖啡夢", false )
    Chat_ServerPrivateMessage( player, "Part2：幹塢的救贖", false )
    wait 2

    entity sarah = CreateNPC( "npc_soldier", player.GetTeam(), origin, <0,0,0> )
    SetSpawnOption_AISettings( sarah, "npc_soldier_hero_sarah")
    DispatchSpawn( sarah )

    EndSignal( sarah, "OnDeath" )
    EndSignal( sarah, "OnDestroy" )
    EndSignal( player, "OnDeath" )
    EndSignal( player, "OnDestroy" )

    OnThreadEnd(
		function() : ( sarah, player, ship, ref )
		{
			if ( IsValid( ship ) )
				ship.mover.Destroy()
			if ( IsValid( ref ) )
				ref.Destroy()

            if ( file.sarahSpawned && ( !IsAlive( sarah ) || !IsAlive( player ) ) && IsValid( player ) )
                Chat_ServerPrivateMessage( player, "你沒能救出莎拉", false )
            else if ( IsValid( player ) )
                SetMapMissionComple( player, 0 ) // TODO: add right inputs

            if ( IsAlive( sarah ) )
                sarah.Die()

            file.sarahSpawned = false
		}
	)

    // sarah.ContextAction_SetBusy()
    sarah.EnableNPCMoveFlag( NPCMF_DISABLE_ARRIVALS )
	sarah.DisableNPCFlag( NPC_ALLOW_FLEE | NPC_ALLOW_HAND_SIGNALS )
    sarah.DisableNPCFlag( NPC_ALLOW_PATROL | NPC_ALLOW_INVESTIGATE )
    sarah.EnableNPCFlag( NPC_NO_MOVING_PLATFORM_DEATH )

    TakeAllWeapons( sarah )
    PhaseShift( sarah, 0, 2 )
    wait 1
    Chat_ServerPrivateMessage( player, "[莎拉] 感謝你救了我，上次我賣咖啡時被小b抓了", false )
    wait 3
    Chat_ServerPrivateMessage( player, "[莎拉] 跟我來", false )
    NSSendPopUpMessageToPlayer( player, "跟隨布裏格斯指揮官" )
    // why isn't assault working?

    ref = CreateScriptMover( < -103, -1700, 416 > )
    // int followBehavior = GetDefaultNPCFollowBehavior( sarah )
    // sarah.InitFollowBehavior( ref, followBehavior )
    // sarah.EnableBehavior( "Follow" )

    // while( Distance2D( sarah.GetOrigin(), ref.GetOrigin() ) > 100 )
    //     WaitFrame()

    // Chat_ServerPrivateMessage( player, "[Sarah] Phaseshifting", false )

    // wait 0.2
    // PhaseShift( sarah, 0, 2 )
    // wait 0.5
    // sarah.SetOrigin( < -808, -1328, 409 > )

    // wait 2

    // Chat_ServerPrivateMessage( player, "[Sarah] Come closer", false )
    // while( Distance2D( sarah.GetOrigin(), player.GetOrigin() ) > 200 )
    //     WaitFrame()

    // ref.SetOrigin( <628, 3805, 96> )

    // wait 1
    // PhaseShift( sarah, 0, 2 )
    // PhaseShift( player, 0, 2 )
    // WaitFrame()
    // sarah.SetOrigin( <2005, 2855, 81> )
    // player.SetOrigin( <2005, 2555, 81> )

    // Chat_ServerPrivateMessage( player, "[Sarah] Go go go!", false )

    // bool said = false
    // while( Distance2D( sarah.GetOrigin(), ref.GetOrigin() ) > 100 )
    // {
    //     if( Distance2D( sarah.GetOrigin(), player.GetOrigin() ) > 500 && !said )
    //     {
    //         Chat_ServerPrivateMessage( player, "[Sarah] Come closer", false )
    //         // sarah.DisableBehavior( "Follow" )
    //         sarah.Freeze()
    //         said = true
    //     }
    //     else if( Distance2D( sarah.GetOrigin(), player.GetOrigin() ) < 500 && said )
    //     {
    //         sarah.Unfreeze()
    //         // sarah.EnableBehavior( "Follow" )
    //         Chat_ServerPrivateMessage( player, "[Sarah] Go go go!", false )
    //         said = false
    //     }

    //     WaitFrame()
    // }

    // ref.SetOrigin( ship.mover.GetOrigin() )

    // while( Distance2D( sarah.GetOrigin(), ref.GetOrigin() ) > 200 )
    // {
    //     if( Distance2D( sarah.GetOrigin(), player.GetOrigin() ) > 500 && !said )
    //     {
    //         Chat_ServerPrivateMessage( player, "[Sarah] Come closer", false )
    //         // sarah.DisableBehavior( "Follow" )
    //         sarah.Freeze()
    //         said = true
    //     }
    //     else if( Distance2D( sarah.GetOrigin(), player.GetOrigin() ) < 500 && said )
    //     {
    //         sarah.Unfreeze()
    //         // sarah.EnableBehavior( "Follow" )
    //         Chat_ServerPrivateMessage( player, "[Sarah] Go go go!", false )
    //         said = false
    //     }

    //     WaitFrame()
    // }

    sarah.Freeze()
    waitthread PlayRecoding_recording_sarah( sarah )

    bool slow = true
    if ( Distance2D( sarah.GetOrigin(), player.GetOrigin() ) < 2000 )
        slow = false

    if ( !slow )
        Chat_ServerPrivateMessage( player, "[莎拉] 我們到達逃脫飛船了", false )

    // PhaseShift( sarah, 0 , 0.1 )
    // StartParticleEffectOnEntity( sarah, GetParticleSystemIndex( $"P_phase_shift_main" ), FX_PATTACH_POINT_FOLLOW, 7 )
	sarah.SetParent( ship.model, "ORIGIN" )
	thread PlayAnim( sarah, "Militia_flyinA_idle_mac", ship.model, "ORIGIN")

    wait 1

    if ( !slow )
    {
        Chat_ServerPrivateMessage( player, "[莎拉] 給，這是你應得的", false )
        StimPlayer( player, 1000000 )
    }

    if ( slow )
    {
        Chat_ServerPrivateMessage( player, "[莎拉] 天啊，你跑得可真慢，我還想給你準備杯咖啡呢", false )
        wait 1
        Chat_ServerPrivateMessage( player, "[莎拉] 我先走一步了", false )
    }

    wait 2

    Chat_ServerPrivateMessage( player, "[莎拉] 飛船起飛", false )
    MissionAlreadyComplete++
    thread __ShipFlyToPosInternal( ship, null, CLVec( <859,6758,4532> ), <0,0,0>, CONVOYDIR )

    WaitSignal( ship, "Goal" )

    file.sarahSpawned = false
}

void function CraneCreate( vector origin, vector angles )
{
    if ( GetDisabledElements().contains( "cranes" ) )
        return

    entity mover = CreateExpensiveScriptMoverModel( $"models/beacon/beacon_crane_yellow.mdl", origin, angles, SOLID_VPHYSICS, 10000 )
    entity triggerEnt = CreatePropDynamic( $"models/dev/editor_ref.mdl", origin + <0,0,100>, angles, SOLID_VPHYSICS, 10000 )
	SetTeam( triggerEnt, TEAM_BOTH )
    triggerEnt.Hide()

    mover.LinkToEnt( triggerEnt )
    mover.SetOwner( null )
    mover.SetPusher( true )

    triggerEnt.SetUsable()
    triggerEnt.SetUsableByGroup( "pilot" )
    triggerEnt.SetUsePrompts( "Hold %use% to use the crane", "Press %use% to use the crane" )
	thread CraneUseThink( triggerEnt, mover )
}

void function CraneUseThink( entity triggerEnt, entity mover )
{
    triggerEnt.SetUsable()
    mover.SetOwner( null )

    entity player
    while ( !IsValid( player ) || !IsAlive( player ) || IsValid( player.GetParent() ) || player.IsTitan() )
        player = expect entity( triggerEnt.WaitSignal( "OnPlayerUse" ).player )


    triggerEnt.UnsetUsable()
    mover.SetOwner( player )

    player.SetOrigin( mover.GetOrigin() + <0,0,105> + mover.GetRightVector() * 50 )
    player.SetParent( mover )
    // HolsterAndDisableWeapons( player ) // skill issue lmao; like I can't figure out why abbilities are getting disabled

    wait 1

    thread CraneThink( triggerEnt, mover, player )
}

void function CraneThink( entity triggerEnt, entity mover, entity player )
{
    EndSignal( player, "OnDeath" )
    EndSignal( player, "OnDestroy" )

    OnThreadEnd(
		function() : ( mover, triggerEnt, player )
		{
            thread CraneUseThink( triggerEnt, mover )

            if ( !IsAlive( player ) )
                return

            player.ClearParent()
            StopSoundOnEntity( player, "crane_servos_rotate_lp" )
            EmitSoundOnEntityOnlyToPlayer( player, player, "crane_shutdown" )
            // DeployAndEnableWeapons( player )
        }
    )

    EmitSoundOnEntityOnlyToPlayer( player, player, "crane_startup" )

    array<bool> keys = GetPlayerKeysList( player )
    bool played_stop = true
    for(;;)
    {
        keys = GetPlayerKeysList( player )

        if ( keys[KU] )
            return

        if ( keys[KL] )
            RotateMover( mover, <0,30,0> )
        if ( keys[KR] )
            RotateMover( mover, <0,-30,0> )


        if ( ( keys[KL] || keys[KR] ) && played_stop )
        {
            EmitSoundOnEntityOnlyToPlayer( player, player, "crane_servos_rotate_lp" )
            played_stop = false
        }
        else if ( !played_stop && !( keys[KL] || keys[KR] ) )
        {
            EmitSoundOnEntityOnlyToPlayer( player, player, "crane_servos_stop" )
            played_stop = true
        }

        WaitFrame()
    }
}

void function RotateMover( entity mover, vector angles )
{
    angles = mover.GetAngles() + angles
    mover.NonPhysicsRotateTo( angles, 0.3, 0.05, 0.05 )
}

void function setupSarahRecord()
{
    entity player = GetPlayerByIndex(0)

    player.SetOrigin( <710,-1600, 416> )
}