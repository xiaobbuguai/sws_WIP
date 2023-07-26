global function placeBoomTownObjects

struct {
    bool voper_fight_started = false
    entity wall
    array<entity> terminals
    int terminals_num = 3
    entity funny_spinny
} file

void function placeBoomTownObjects()
{
    PrecacheModel( $"models/communication/terminal_com_station_tall.mdl" )
    PrecacheModel( $"models/barriers/titan_target_01.mdl" )

    CreateNessy( <1050, -4888, 2464>, <0, 60, 0>, 10 )
    CreateSimpleButton( <3393, -3798, 2128>, <0, 90, 0>, "to spawn voper", callback_Voper2ButtonTriggered )
    CreateSimpleButton( <5662, -4270, 2860>, <0, 90, 0>, "to fly ;)", callback_AntiGravButtonTriggered, 5.0 )
    CreateSimpleButton( <6153, -1809, 2364>, <0, 90, 0>, "to launch yourself ;)", callback_AntiGravButtonTriggered, 5.0 )
    CreateSimpleButton( <2531, -5115, 2436>, <0, 90, 0>, "to launch yourselft", callback_AntiGravButtonTriggered, 5.0 )
    CreateSimpleButton( <8263, -3435, 2232>, <0, 90, 0>, "to put up a barrier", callback_SpinButtonTriggered, 5.0 )
    // CreateSimpleButton( <4633, -3626, 2333>, <0, 0, 0>, "to crush people below", callback_CrusherButtonTriggered, 10.0 )

    file.wall = CreateExpensiveScriptMoverModel( $"models/kodai_live_fire/grave_wall_gasket_512.mdl", <5000, -3752, 1974>, <0,180,0>, SOLID_VPHYSICS, 1000 )
    
    file.terminals.append( CreateExpensiveScriptMoverModel( $"models/communication/terminal_com_station_tall.mdl", <5985, -4390, 2257>, <0,180,0>, SOLID_VPHYSICS, 10000 ))
    file.terminals.append( CreateExpensiveScriptMoverModel( $"models/communication/terminal_com_station_tall.mdl", <11322, -1662, 1954>, <0,180,0>, SOLID_VPHYSICS, 10000 ))
    file.terminals.append( CreateExpensiveScriptMoverModel( $"models/communication/terminal_com_station_tall.mdl", < -2366, -1726, 1950 >, <0,180,0>, SOLID_VPHYSICS, 10000 ))
    
    SetupTerminals()
    HideTerminals()
    
    file.funny_spinny = CreateExpensiveScriptMoverModel( $"models/barriers/titan_target_01.mdl", <8263, -3535, 2200>, <0,180,180>, SOLID_VPHYSICS, 10000 )
}

void function callback_SpinButtonTriggered( entity panel, entity player )
{
    file.funny_spinny.NonPhysicsRotateTo( <180,0,0> + file.funny_spinny.GetAngles(), 0.5, 0.1, 0.1 )
}

void function callback_AntiGravButtonTriggered( entity panel, entity player )
{
    player.kv.gravity = -1.0
    player.SetVelocity( <0,0,400> )
    thread callback_AntiGravButtonTriggeredThreaded( player )
}

void function callback_AntiGravButtonTriggeredThreaded( entity player )
{
    player.EndSignal( "OnDeath" )
    player.EndSignal( "OnDestroy" )

    OnThreadEnd(
		function() : ( player )
		{
			if ( IsValid( player ) )
                player.kv.gravity = 0.0
		}
	)

    wait 1

    player.kv.gravity = 0.0
    player.SetVelocity(  player.GetForwardVector() * 1000 )
}

void function callback_CrusherButtonTriggered( entity panel, entity player )
{
    thread callback_CrusherButtonTriggeredThreaded( player )
}

void function callback_CrusherButtonTriggeredThreaded( entity player )
{
    file.wall.NonPhysicsMoveTo( file.wall.GetOrigin() - <1000,0,0>, 0.5, 0.1, 0.1 )

    wait 1

    file.wall.NonPhysicsMoveTo( file.wall.GetOrigin() + <1000,0,0>, 0.5, 0.1, 0.1 )
}

void function callback_Voper2ButtonTriggered( entity panel, entity player )
{
    if ( GetDisabledElements().contains( "voper2" ) )
    {
        NSSendPopUpMessageToPlayer( player, "voper 2 is disabled on this server D:" )
        return
    }

    if ( !HasAllNessies() )
    {
        foreach( entity p in GetPlayerArray() )
            NSSendPopUpMessageToPlayer( p, "You don't have all the nessies [" + CountNessy() + " out of 4 ]" )
        
        return
    }

    if ( file.voper_fight_started )
        return
    
    if ( GetMapName() != "mp_grave" && GAMETYPE != "tdm" && GAMETYPE != "aitdm" )
        return
    
    file.voper_fight_started = !file.voper_fight_started

    StartVoperBattle( 1 )

    ResetNessy()

    thread WaitForCameraEnd()
}

void function WaitForCameraEnd()
{
    entity voper = GetVoper()
    // DoomTitan( voper )

    WaitSignal( voper, "CameraHandleOver" )

    thread DropNukes()
    thread DropTitans()
    thread FlyVoper()

    foreach( entity player in GetPlayerArray() )
        NSSendInfoMessageToPlayer( player, "To kill Voper lower the 3 terminals around the map" )
    
    ShowTerminals()
    file.terminals_num = 3
}

void function DropNukes()
{
    entity voper = GetVoper()

    voper.EndSignal( "OnDeath" )
    voper.EndSignal( "OnDestroy" )
    voper.EndSignal( "FakeDeath" )
    
    int team = voper.GetTeam()
    vector SelectedPlace
    array<entity> titanSpawnPoints

    for(;;)
    {
        SelectedPlace = <0,0,0>
        titanSpawnPoints = SpawnPoints_GetTitan()
        foreach( entity player in GetPlayerArray() )
        {
            entity spawnpoint

            if ( IsValid( player ) )
                spawnpoint = GetClosest( titanSpawnPoints, player.GetOrigin(), 500 )
            
            if ( IsValid( spawnpoint ) )
            {
                SelectedPlace = spawnpoint.GetOrigin()
            }
        }

        if ( SelectedPlace != <0,0,0> )
        {
            entity nukeTitan = CreateNPCTitan( "npc_titan_ogre", team, SelectedPlace, <0,0,0>, [] ) // why do I need []
            SetSpawnOption_NPCTitan( nukeTitan, TITAN_HENCH )
            SetSpawnOption_AISettings( nukeTitan, "npc_titan_ogre_minigun_nuke" )
            SetSpawnOption_Warpfall( nukeTitan )
            DispatchSpawn( nukeTitan )

            NPC_SetNuclearPayload( nukeTitan )
            SetTeam( nukeTitan, team )

            thread KillOnLanding( nukeTitan )

            // Chat_ServerBroadcast( "droping the nuke" )
        }

        wait 5
    }
}

void function KillOnLanding( entity titan )
{
    while( IsValid( titan ) && !titan.IsOnGround() )
        WaitFrame()
    
    if ( IsValid( titan ) )
		thread AutoTitan_SelfDestruct( titan )
}

void function DropTitans() 
{
    entity voper = GetVoper()

    voper.EndSignal( "OnDeath" )
    voper.EndSignal( "OnDestroy" )
    voper.EndSignal( "FakeDeath" )
    
    int team = voper.GetTeam()
    vector SelectedPlace
    array<entity> titanSpawnPoints

    for(;;)
    {
        SelectedPlace = <0,0,0>
        titanSpawnPoints = SpawnPoints_GetTitan()
        entity spawnpoint

        if ( IsValid( voper ) )
            spawnpoint = GetClosest( titanSpawnPoints, voper.GetOrigin(), 100000 )
        
        if ( IsValid( spawnpoint ) )
            SelectedPlace = spawnpoint.GetOrigin()


        if ( SelectedPlace != <0,0,0> && GetEntArrayByScriptName( "ions" ).len() < 10 )
        {
            entity titan = CreateNPCTitan( "npc_titan_atlas", team, SelectedPlace, <0,0,0>, [] ) // why do I need []
            SetSpawnOption_NPCTitan( titan, 2 )
            SetSpawnOption_AISettings( titan, "npc_titan_atlas_stickybomb" )
            SetSpawnOption_Warpfall( titan )
            SetSpawnOption_CoreAbility( titan, "mp_titancore_laser_cannon" )
            DispatchSpawn( titan )

            titan.SetScriptName( "ions" )

            thread ResupplyCores( titan )
        }

        wait 5
    }
}

void function ResupplyCores( entity titan )
{
    titan.EndSignal( "OnDeath" )
    titan.EndSignal( "OnDestroy" )
    entity soul = titan.GetTitanSoul()

    for(;;)
    {
        SoulTitanCore_SetNextAvailableTime( soul, 1000.0 )

        SoulTitanCore_SetExpireTime( soul, Time() + 100.0 )
        soul.SetCoreChargeStartTime( Time() )

        titan.WaitSignal( "CoreBegin" )
        soul.SetCoreUseDuration( 100.0 )

        wait 1
    }
}

void function FlyVoper() 
{
    entity voper = GetVoper()
    ShipStruct ship = GetVoperShip()
    entity link = ship.model.GetParent()

    voper.EndSignal( "OnDeath" )
    voper.EndSignal( "OnDestroy" )
    voper.EndSignal( "FakeDeath" )

    for(;;)
    {
        entity enemy = ViperGetEnemy( voper )

        if ( !IsValid( enemy ) || !IsAlive( enemy ) )
            continue
        
        ShipFlyToPos( ship, CLVec( enemy.GetOrigin() + <0,0,300> + ( enemy.GetForwardVector() * 1000 ) ), enemy.GetAngles() + <0,180,0> )
        link.NonPhysicsRotateTo( enemy.GetAngles() + <0,180,0>, 0.00000001,0,0 )
        // WaitSignal( ship, "Goal" )

        if ( voper.IsOnGround() )
            voper.SetOrigin( voper.GetParent().GetOrigin() )

        if ( RandomIntRange( 0, 1000 ) < 5 )
            waitthread CoreFire()

        WaitFrame()
    }
}

void function SetupTerminals()
{
    foreach( terminal in file.terminals )
    {
        terminal.SetUsableByGroup( "pilot" )
        terminal.SetUsePrompts( "Hold %use% to lower the tower", "Press %use% to lower the tower" )
        terminal.SetUsable()
        SetTeam( terminal, 100 )
        Highlight_SetEnemyHighlight( terminal, "hunted_enemy" )
        
    }
}

void function WaitToHide( entity terminal )
{
    WaitSignal( terminal, "OnPlayerUse" )
    terminal.NonPhysicsMoveTo( terminal.GetOrigin() - <0,0,180>, 5, 1, 1 )
    terminal.UnsetUsable()
    Highlight_ClearEnemyHighlight( terminal )

    file.terminals_num -= 1

    if ( file.terminals_num <= 0 ) 
    {
        foreach( entity player in GetPlayerArray() )
            NSSendInfoMessageToPlayer( player, "Voper is now vulnerable" )

        GetVoper().ClearInvulnerable()
    }
}

void function HideTerminals()
{
    foreach( terminal in file.terminals )
    {
        terminal.NonPhysicsMoveTo( terminal.GetOrigin() - <0,0,180>, 5, 1, 1 )
        terminal.UnsetUsable()
        Highlight_ClearEnemyHighlight( terminal )
    }
}

void function ShowTerminals()
{
    foreach( terminal in file.terminals )
    {
        terminal.NonPhysicsMoveTo( terminal.GetOrigin() + <0,0,180>, 1, 0.5, 0.5 )
        terminal.SetUsable()
        Highlight_SetEnemyHighlight( terminal, "hunted_enemy" )
        thread WaitToHide( terminal )
    }
}