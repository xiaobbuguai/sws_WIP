untyped

global function placeEdenObjects

const drones_settings = [ "npc_drone_rocket", "npc_drone_plasma", "npc_drone_beam" ]

struct
{
    bool mission_started = false
    entity triggerEnt
}
file

void function placeEdenObjects()
{
    PrecacheModel( $"models/eden/eden_screen_tall.mdl" )

    CreateSimpleButton( < -3046, -186, 422 >, <0, 90, 0>, "to launch yourself", Yeet1, 5.0 )
    CreateSimpleButton( <1589, -185, 422>, <0, 90, 0>, "to launch yourself", Yeet2, 5.0 )

    entity mover = CreateExpensiveScriptMoverModel( $"models/props/turret_base/turret_base.mdl", <1589 - 100, -185, 422>, <0,0,0>, SOLID_VPHYSICS, 1000 )
    mover.SetScriptName( "eden2" )

    mover = CreateExpensiveScriptMoverModel( $"models/props/turret_base/turret_base.mdl", < -3046 + 100, -186, 422 >, <0,0,0>, SOLID_VPHYSICS, 1000 )
    mover.SetScriptName( "eden1" )

    CreateNessy( <1852, -1079, 106>, <0, 90, 0>, 1 )

    CreatePhaseTeleporter( < -2040.78, 2698.2, 168.738 >, < -3305.58, 596.523, 57.2551 > )
    CreatePhaseTeleporter( <612, -1032, 68>, <612, -1170, 68> )
    CreateSarahCoffeMaker( <2101, 151, 72>, <0,270,0> )
    CreateAshPeaceKraberSeller( <472, -1032, 88>, <0,-270,0> )

    CreatePropDynamic( $"models/eden/eden_screen_tall.mdl", <472, -840, 68>, <0,180,0>, SOLID_VPHYSICS )
    CreatePropDynamic( $"models/eden/eden_screen_tall.mdl", <680, -840, 68>, <0,180,0>, SOLID_VPHYSICS )
    
    AddCallback_EntitiesDidLoad( EntitiesDidLoad )
}

void function EntitiesDidLoad()
{
    CreateHiddenBar()

    if ( GetDisabledElements().contains( "missions_from_sarah" ) )
        return

    CreateHackPanel( < -1705, 2704, 305 >, <0,90,0>, OnPanelHacked )

    entity terminal = CreatePropDynamic( $"models/communication/terminal_com_station_tall.mdl", <8282, 8148, 3096>, <0,0,0>, SOLID_VPHYSICS, 10000 )

    entity triggerEnt = CreatePropDynamic( $"models/dev/editor_ref.mdl", terminal.GetOrigin() + <20,0,50>, <0,0,0>, SOLID_VPHYSICS, 10000 )
    triggerEnt.Hide()
    triggerEnt.SetUsePrompts( "Hold %use% to start hacking", "Press %use% to start hacking" )
    triggerEnt.UnsetUsable()

    file.triggerEnt = triggerEnt
}

void function Yeet1( entity button, entity player )
{
    if ( !IsValid( player ) || GetEntArrayByScriptName( "eden1" ).len() != 1  )
        return

    entity mover = GetEntArrayByScriptName( "eden1" )[0]
    
    player.SetOrigin( mover.GetOrigin() + <0,0,50> )
    player.SetParent( mover )
    mover.NonPhysicsMoveTo( mover.GetOrigin() + <500,0,0>, 0.2, 0, 0 )
    wait 0.2
    
    if ( IsValid( player ) )
    {
        player.ClearParent()
        player.SetVelocity( player.GetVelocity() + <600,0,200> )
    }

    mover.NonPhysicsMoveTo( mover.GetOrigin() - <500,0,0>, 0.2, 0, 0 )
}

void function Yeet2( entity button, entity player )
{
    if ( !IsValid( player ) || GetEntArrayByScriptName( "eden2" ).len() != 1  )
        return

    entity mover = GetEntArrayByScriptName( "eden2" )[0]
    
    player.SetOrigin( mover.GetOrigin() + <0,0,50> )
    player.SetParent( mover )
    mover.NonPhysicsMoveTo( mover.GetOrigin() - <500,0,0>, 0.2, 0, 0 )
    wait 0.2
    
    if ( IsValid( player ) )
    {
        player.ClearParent()
        player.SetVelocity( player.GetVelocity() + < -600,0,200 > )
    }

    mover.NonPhysicsMoveTo( mover.GetOrigin() + <500,0,0>, 0.2, 0, 0 )
}

function OnPanelHacked( panel, player )
{
    expect entity( panel )
	expect entity( player )
    print( panel + " was hacked by " + player )

    if ( file.mission_started )
        return
    file.mission_started = true

    array<entity> sarah = GetEntArrayByScriptName( "sarah_coffee" )
    if ( sarah.len() == 1 )
    {
        sarah[0].Hide()
        sarah[0].UnsetUsable()
    }

    thread HackingOperation( player )
}

void function HackingOperation( entity player )
{
    array<entity> ent_cleanup
    
    ShipStruct ship = SpawnCrowLight( CLVec( <1171,3505,1964> ), <0,90,0>, true )
    ShipSetInvulnerable( ship )
    DropshipAnimateOpen( ship, "right" )
    entity model = ship.model
    model.SetPusher( true )

    entity sarah = CreateNPC( "npc_soldier", player.GetTeam(), <1171,3505,1964>, <0,0,0> )
    SetSpawnOption_AISettings( sarah, "npc_soldier_hero_sarah")
    DispatchSpawn( sarah )
    ent_cleanup.append( sarah )

    GoblinRiderAnimate( sarah, model, 0, "RESCUE" )
    TakeAllWeapons( sarah )
    sarah.GiveWeapon( "mp_weapon_car" )
    sarah.ClearInvulnerable()

    entity grunt = CreateNPC( "npc_soldier", player.GetTeam(), <1171,3505,1964>, <0,0,0> )
    SetSpawnOption_AISettings( sarah, "npc_soldier")
    DispatchSpawn( grunt )
    ent_cleanup.append( grunt )

    GoblinRiderAnimate( grunt, model, 1, "RESCUE" )

    EndSignal( player, "OnDeath" )
    EndSignal( player, "OnDestroy" )

    OnThreadEnd(
		function() : ( player, ship, ent_cleanup )
		{
            foreach( entity ent in ent_cleanup )
            {
                if( IsValid( ent ) )
                    ent.Destroy()
            }

            if ( IsAlive( player ) )
                player.ClearParent()

			if ( IsValid( ship.mover ) )
				ship.mover.Destroy()
            
            if ( file.mission_started && IsValid( player ) && !IsAlive( player ) )
                Chat_ServerPrivateMessage( player, "You failed to the mission", false )
            else if ( IsValid( player ) )
            {
                SetMapMissionComple( player, 1 )
                StopSoundOnEntity( player, "Music_Beacon_27_FinalBattleReapersArrive" )
                StopSoundOnEntity( player, "Music_Beacon_29_FinalBattleEnds" )
            }
            
            file.mission_started = false
            file.triggerEnt.UnsetUsable()
            
            if ( GetEntArrayByScriptName( "sarah_coffee" ).len() == 0 )
                return

            entity sarah = GetEntByScriptName( "sarah_coffee" )
            sarah.Show()
            sarah.SetUsable()
		}
	)

    EmitSoundAtPosition( TEAM_UNASSIGNED, ship.mover.GetOrigin(), "dropship_warpin" )

    entity fx = PlayFX( TURBO_WARP_FX, ship.mover.GetOrigin(), <0,0,0> )
    fx.FXEnableRenderAlways()
    fx.DisableHibernation()

    EmitSoundOnEntity( model, "amb_emit_s2s_rushing_wind_strong_v2_02b" )

    ShipFlyToPos( ship, CLVec( < -1432, 3386, 552 > ), <0,180,0> )
    WaitSignal( ship, "Goal" )

    Chat_ServerPrivateMessage( player, "[Sarah] Get on the ship", false )


    waitthread WaitForPlayerToJumpOn( model, player )
    player.SetParent( model )

    wait 1

    StopSoundOnEntity( model, "amb_emit_s2s_rushing_wind_strong_v2_02b" )
    EmitSoundOnEntity( model, "amb_emit_s2s_rushing_wind_strong_v2_02b" )
    EmitSoundOnEntity( model, "amb_emit_s2s_distant_ambient_ships" )

    ShipFlyToPos( ship, CLVec( < -2750, 3386, 650 > ), <0,110,0> )
    WaitSignal( ship, "Goal" )

    ShipFlyToPos( ship, CLVec( < -1454, 6144, 967 > ), <0,70,0> )
    WaitSignal( ship, "Goal" )

    player.SetOutOfBoundsDeadTime( 0.0 )
    player.Signal( "BackInBounds" )

    ShipFlyToPos( ship, CLVec( < -1399,8471,967 > ), <0,90,0> )
    WaitSignal( ship, "Goal" )

    StopSoundOnEntity( model, "amb_emit_s2s_rushing_wind_strong_v2_02b" )
    EmitSoundOnEntity( model, "amb_emit_s2s_rushing_wind_strong_v2_02b" )
    EmitSoundOnEntity( model, "amb_emit_s2s_distant_ambient_ships" )

    ShipFlyToPos( ship, CLVec( < -1399,8471,100 > ), <0,0,0> )
    WaitSignal( ship, "Goal" )

    wait 1


    player.ClearParent()
    waitthread WaitForPlayerToJumpOff( model, player )

    entity fdrone = CreateNPC( "npc_drone", player.GetTeam(), sarah.GetOrigin(), <0,0,0> )
    SetSpawnOption_AISettings( fdrone, "npc_drone_beam" )
    DispatchSpawn( fdrone )
    ent_cleanup.append( fdrone )
    
    int followBehavior = GetDefaultNPCFollowBehavior( fdrone )
    fdrone.InitFollowBehavior( player, followBehavior )
    fdrone.EnableBehavior( "Follow" )

    Chat_ServerPrivateMessage( player, "[Sarah] We are giving you a drone.", false )
    Chat_ServerPrivateMessage( player, "[Sarah] Go North towards the tower and up the hill.", false )
    Chat_ServerPrivateMessage( player, "[Sarah] You will find a terminal to hack.", false )

    file.triggerEnt.SetUsable()


    ShipFlyToPos( ship, CLVec( <497,12419,1013> ), <0,70,0> )
    WaitSignal( ship, "Goal" )
    
    ShipFlyToPos( ship, CLVec( <6931,11262,2388> ), <0,-10,0> )

    WaitSignal( file.triggerEnt, "OnPlayerUse" )
    file.triggerEnt.UnsetUsable()
    
    EmitSoundOnEntity( file.triggerEnt, "dataknife_hackcomplete_console_pt1" )
    ShipFlyToPos( ship, CLVec( <8761,8779,3716> ), <0,-10,0> )

    wait 3


    Chat_ServerPrivateMessage( player, "[Sarah] Defend the terminal", false )
    EmitSoundOnEntityOnlyToPlayer( player, player, "Music_Beacon_27_FinalBattleReapersArrive" )

    ent_cleanup.extend( SpawnDrones( 10, player ) )

    waitthread WaitForDonesDeath()
    ent_cleanup.extend( SpawnDrones( 15, player ) )

    waitthread WaitForDonesDeath()
    ent_cleanup.extend( SpawnDrones( 20, player ) )

    waitthread WaitForDonesDeath()

    
    StopSoundOnEntity( player, "Music_Beacon_27_FinalBattleReapersArrive" )
    EmitSoundOnEntityOnlyToPlayer( player, player, "Music_Beacon_29_FinalBattleEnds" )

    Chat_ServerPrivateMessage( player, "[Sarah] Good job!", false )

    ShipFlyToPos( ship, CLVec( <8283, 9000, 2991> ), <0,-10,0> )
    WaitSignal( ship, "Goal" )
    Chat_ServerPrivateMessage( player, "[Sarah] We need to leave now", false )

    waitthread WaitForPlayerToJumpOn( model, player )
    player.SetParent( model )
    StopSoundOnEntity( player, "Music_Beacon_29_FinalBattleEnds" )
    EmitSoundOnEntity( model, "amb_emit_s2s_rushing_wind_strong_v2_02b" )
    EmitSoundOnEntity( model, "amb_emit_s2s_distant_ambient_ships" )

    ShipFlyToPos( ship, CLVec( <8283, 8588, 4000> ), <0,-90,0> )
    WaitSignal( ship, "Goal" )

    ShipFlyToPos( ship, CLVec( <5817, 2534, 2864> ), <0,-90,0> )
    WaitSignal( ship, "Goal" )

    ShipFlyToPos( ship, CLVec( <5205, -356, 639> ), <0,-90,0> )
    
    Chat_ServerPrivateMessage( player, "[Sarah] You can Go now.", false )
    player.ClearParent()
    waitthread WaitForPlayerToJumpOff( model, player )


    Chat_ServerPrivateMessage( player, "[Sarah] Good Bye", false )

    ShipFlyToPos( ship, CLVec( <5393,-2702,1660> ), <0,-90,0> )
    WaitSignal( ship, "Goal" )
    
    file.mission_started = false
}

void function WaitForPlayerToJumpOn( entity model, entity player )
{
    for(;;)
    {
        vector origin = player.GetOrigin()
        TraceResults traceResult = TraceLine( origin, origin + <0,0,-100>, [ player ], TRACE_MASK_SHOT, TRACE_COLLISION_GROUP_NONE )

        if ( traceResult.hitEnt == model && model.GetOrigin().z < origin.z )
            break
        
        wait 1
    }
}

void function WaitForPlayerToJumpOff( entity model, entity player )
{
    for(;;)
    {
        vector origin = player.GetOrigin()
        TraceResults traceResult = TraceLine( origin, origin + <0,0,-100>, [ player ], TRACE_MASK_SHOT, TRACE_COLLISION_GROUP_NONE )

        if ( traceResult.hitEnt != model && model.GetOrigin().z > origin.z )
            break
        
        wait 1
    }
}

array<entity> function SpawnDrones( int amount, entity enemy )
{
    array<entity> ents

    for( int x = 0; x < amount; x++ )
    {
        entity drone = CreateNPC( "npc_drone", 23, <8164,6898,2230>, <0,0,0> )
        SetSpawnOption_AISettings( drone, drones_settings.getrandom() )
        DispatchSpawn( drone )
        ents.append( drone )

        int followBehavior = GetDefaultNPCFollowBehavior( drone )
        drone.InitFollowBehavior( enemy, followBehavior )
        drone.EnableBehavior( "Follow" )

        drone.SetEnemy( enemy )

        thread DieIn30Seconds( drone )
    }

    return ents
}

void function DieIn30Seconds( entity drone )
{
    EndSignal( drone, "OnDeath" )
    wait 30
    drone.Die()
}

void function WaitForDonesDeath()
{
    while ( !DronesLeft() )
        wait 1
}

bool function DronesLeft()
{
    return GetNPCArrayOfTeam( 23 ).len() == 0
}